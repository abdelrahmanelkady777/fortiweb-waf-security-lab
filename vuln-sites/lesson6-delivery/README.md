# Lesson 6 Application-Delivery Backend

This dependency-free Python service provides deterministic endpoints for URL rewriting, Site Publishing, compression, caching, acceleration, Lua response manipulation, and Waiting Room validation.

Lesson 7 reuses `/new` for request-rate tests, `/slow` for overlapping-connection tests, and `/headers` for fresh-session recovery checks. No Lesson 7 backend code change is required.

## Run the application

```bash
cd vuln-sites/lesson6-delivery
chmod +x delivery_server.py
nohup python3 delivery_server.py > delivery_server.log 2>&1 &
echo $! > delivery_server.pid

sudo ss -lntp | grep ':8003'
curl -i http://127.0.0.1:8003/
```

The service listens on `0.0.0.0:8003`. On first start it generates `static/large.txt` from a fixed 700-line pattern so the compression and cache object remains reproducible without storing a large generated file in Git.

FortiWeb mapping:

```text
delivery.lab.local -> route_delivery_l6 -> pool_delivery_l6 -> 10.0.20.2:8003
reports.lab.local  -> route_reports_l6  -> pool_delivery_l6 -> 10.0.20.2:8003
```

## Endpoint map

| Path | Purpose |
| --- | --- |
| `/` | Main page and acceleration target |
| `/old` / `/new` | FortiWeb-generated redirect source and destination |
| `/legacy/page` / `/modern/page` | Silent internal request-rewrite pair |
| `/backend-links` | Body containing private backend links |
| `/backend-redirect` | Backend `302` with a private `Location` header |
| `/private/` | Site Publishing and SSO target |
| `/counter` | Backend-hit counter |
| `/headers` | Headers and client address seen by the backend |
| `/slow` | Three-second response |
| `/sale` | Eight-second Waiting Room target |
| `/static/*` | Compression, cache, and acceleration resources |

## Run the isolated LDAP identity source

This lab uses clear-text LDAP only on the isolated backend segment. Do not copy this setup into production.

```bash
cd vuln-sites/lesson6-delivery/ldap
export LDAP_ADMIN_PASSWORD='<LAB_ADMIN_PASSWORD>'
export LESSON6_USER_PASSWORD='<LAB_USER_PASSWORD>'

docker compose up -d
./bootstrap-user.sh
```

The bootstrap script creates `ou=people`, adds `uid=kady`, and proves the bind with `ldapwhoami`. Passwords are supplied through environment variables and are not stored in the repository.

FortiWeb LDAP values:

```text
Server:      10.0.20.2:389
Base DN:     ou=people,dc=lab,dc=local
Identifier:  uid
Admin DN:    cn=admin,dc=lab,dc=local
User DN:     uid=kady,ou=people,dc=lab,dc=local
```

## Stop and clean up

```bash
kill "$(cat delivery_server.pid)"
rm -f delivery_server.pid delivery_server.log static/large.txt

cd ldap
docker compose down
```

Runtime logs, PID files, generated static content, and credentials must not be committed.
