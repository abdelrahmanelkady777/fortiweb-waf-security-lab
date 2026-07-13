#!/usr/bin/env bash
set -euo pipefail

: "${LDAP_ADMIN_PASSWORD:?export LDAP_ADMIN_PASSWORD before running}"
: "${LESSON6_USER_PASSWORD:?export LESSON6_USER_PASSWORD before running}"

container="${LDAP_CONTAINER:-ldap-l6}"
username="${LESSON6_USER:-kady}"
display_name="${LESSON6_DISPLAY_NAME:-Kady}"

password_hash=$(
  docker exec "$container" slappasswd -s "$LESSON6_USER_PASSWORD"
)

docker exec -i "$container" ldapadd -x -H ldap://localhost \
  -D "cn=admin,dc=lab,dc=local" -w "$LDAP_ADMIN_PASSWORD" <<EOF
dn: ou=people,dc=lab,dc=local
objectClass: organizationalUnit
ou: people

dn: uid=${username},ou=people,dc=lab,dc=local
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: person
objectClass: top
uid: ${username}
cn: ${display_name}
sn: ${display_name}
userPassword: ${password_hash}
EOF

docker exec "$container" ldapwhoami -x -H ldap://localhost \
  -D "uid=${username},ou=people,dc=lab,dc=local" \
  -w "$LESSON6_USER_PASSWORD"
