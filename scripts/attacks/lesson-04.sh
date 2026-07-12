#!/usr/bin/env bash
set -u

api="${API_URL:-http://api.lab.local}"

echo "Authorized isolated-lab tests only."

run() {
  local name="$1"
  shift
  echo
  echo "== $name =="
  curl -sS -o /dev/null -w 'HTTP %{http_code}\n' "$@"
}

run "Valid registration" -X POST "$api/api/register" \
  -H "Content-Type: application/json" \
  --data '{"username":"kady","email":"kady@example.com","password":"Pass123!","age":22}'
run "Missing required age" -X POST "$api/api/register" \
  -H "Content-Type: application/json" \
  --data '{"username":"kady","email":"kady@example.com","password":"Pass123!"}'
run "Wrong age type" -X POST "$api/api/register" \
  -H "Content-Type: application/json" \
  --data '{"username":"kady","email":"kady@example.com","password":"Pass123!","age":"twenty"}'
run "Extra role field" -X POST "$api/api/register" \
  -H "Content-Type: application/json" \
  --data '{"username":"kady","email":"kady@example.com","password":"Pass123!","age":22,"role":"admin"}'

run "Valid XML" -X POST "$api/api/xml/upload" \
  -H "Content-Type: application/xml" \
  --data '<user><name>kady</name><id>1</id></user>'
run "Invalid XML type" -X POST "$api/api/xml/upload" \
  -H "Content-Type: application/xml" \
  --data '<user><name>kady</name><id>abc</id></user>'
run "XXE payload" -X POST "$api/api/xml/upload" \
  -H "Content-Type: application/xml" \
  --data '<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><user><name>&xxe;</name><id>1</id></user>'

run "Valid GraphQL" -X POST "$api/graphql" \
  -H "Content-Type: application/json" \
  --data '{"query":"{ user { id username } }"}'
run "GraphQL introspection" -X POST "$api/graphql" \
  -H "Content-Type: application/json" \
  --data '{"query":"{ __schema { queryType { name } } }"}'
run "GraphQL fragment" -X POST "$api/graphql" \
  -H "Content-Type: application/json" \
  --data '{"query":"fragment UserFields on User { id username } query { user { ...UserFields } }"}'

run "Unknown OpenAPI path" "$api/api/admin/deleteEverything"
run "Wrong OpenAPI method" -X DELETE "$api/api/users/1"
run "TRACE method" -X TRACE "$api/api/register"

echo
echo "== Login rate-limit burst =="
for i in {1..20}; do
  curl -s -o /dev/null -w "$i %{http_code}\n" \
    -X POST "$api/api/login" \
    -H "Content-Type: application/json" \
    --data '{"username":"bad","password":"bad"}'
done

