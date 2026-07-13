# Backend Applications

This directory contains only the backend application definitions and test assets required to reproduce the FortiWeb lessons.

| Directory | Backend mapping | Introduced | Purpose |
| --- | --- | --- | --- |
| `juice-shop/` | `10.0.20.2:3000` and `:3001` | Lessons 1-2 | Vulnerable web app, pool, persistence, signatures, CORS, and parameter tests |
| `webgoat/` | `10.0.20.2:8080` | Lesson 2 | Second host-routed application |
| `lesson3-test-site/` | `10.0.20.2:8000` | Lesson 3 | Deterministic HTML, forms, DLP marker, scripts, and upload endpoint |
| `lesson4-api/` | `10.0.20.2:8002` | Lesson 4; reused by Lesson 7 | Deterministic JSON, XML, GraphQL, OpenAPI, JWT, rate-limit, and sensitive-log payload behavior |
| `lesson6-delivery/` | `10.0.20.2:8003` and LDAP `:389` | Lesson 6; reused by Lesson 7 | Rewriting/delivery features plus fast `/new` and slow `/slow` DoS test surfaces |

Lesson 7 added no backend application. The same backend host also served as the report-documented TCP/514 syslog receiver; no receiver configuration file was supplied, so the repository does not invent one.

Each application directory should include:

- A short README with start/stop and health-check commands
- Pinned image tags or dependency versions where possible
- The exact host port exposed to FortiWeb
- Non-secret test credentials, clearly labeled as lab-only
- A known-good local request
- Cleanup instructions

Never commit generated tokens, runtime logs containing session material, private keys, or a production-derived dataset.
