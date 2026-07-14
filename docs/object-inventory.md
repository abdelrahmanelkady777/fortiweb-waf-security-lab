# Cumulative FortiWeb Object Inventory

| First lesson | Object type | Name | Critical value / attachment |
| ---: | --- | --- | --- |
| 1 | Network VIP | `VIP1` | `10.0.11.100` on `port2` |
| 1 | Virtual Server | `Vip1` | Uses `VIP1`; enabled |
| 1 | Health Check | `hc_icmp_juice` | ICMP |
| 1 | Server Pool | `Juice_shop` | `10.0.20.2:3000`; later `:3001` added |
| 1 | Server Policy | `Test1_pol` | Main policy retained across all lessons |
| 2 | Server Pool | `web_goat` | `10.0.20.2:8080` |
| 2 | Protected Hostnames | `host_lab_apps` | Juice Shop and WebGoat; later Lesson 3/4/6 names added |
| 2 | Content Route | `route_juice` | Host `juice.lab.local` -> Juice Shop pool |
| 2 | Content Route | `route_webgoat` | Host `webgoat.lab.local` -> WebGoat pool |
| 2 | Persistence | `persist_source_ip` | Source IP `/32`, 300 seconds |
| 2 | X-Forwarded-For | `xff_original` | Append original IP on right |
| 2 | IP Group | `ipgrp_kali_client` | `10.0.11.2/32` |
| 3 | Web Protection Profile | `clone_inline` | Active profile selected by `Test1_pol` |
| 3 | Signature Policy | `clone_standard` | Selected by `clone_inline` |
| 3 | Custom Signature Group | `cgrp_lesson3_custom` | Traversal and JSON SQLi signatures |
| 3 | Content Route | `route_urlenc` | `urlenc.lab.local` -> test pool `:8000` |
| 3 | DLP Policy | `dlp_policy_lesson3` | Response marker protection |
| 3 | HTTP Header Policy | `hhs_lesson3_basic` | XFO, nosniff, Referrer Policy, CSP Report-Only |
| 3 | CORS Policy | `cors_policy_lesson3` | `juice.lab.local/rest/*` |
| 3 | SRI Policy | `sri_policy_lesson3` | Protects `/public/app.js` |
| 4 | Server Pool | `pool_api_lesson4` | `10.0.20.2:8002` |
| 4 | Content Route | `route_api_lesson4` | Host `api.lab.local` -> API pool |
| 4 | JSON Policy | `policy_l4` | Registration JSON Schema; attached to `clone_inline` |
| 4 | XML Policy | `xml_policy_lesson4` | XSD, limits, forbidden entities |
| 4 | OpenAPI Policy | `openapi_policy_lesson4` | Contract enforcement |
| 4 | DoS Policy | `dos_policy_lesson4` | Login HTTP Access Limit; attached to `Test1_pol` |
| 6 | Health Check | `hc_delivery_l6_http` | HTTP `GET /` on the Lesson 6 backend |
| 6 | Server Pool | `pool_delivery_l6` | `10.0.20.2:8003` |
| 6 | Content Route | `route_delivery_l6` | Host `delivery.lab.local` -> Lesson 6 pool |
| 6 | Content Route | `route_reports_l6` | Host `reports.lab.local` -> same pool |
| 6 | URL Rewriting Policy | `urlrewrite_policy_l6` | Redirect, internal request rewrite, and response `Location` rewrite |
| 6 | LDAP Query | `ldap_l6` | `10.0.20.2:389`, identifier `uid`, Lesson 6 search base |
| 6 | Authentication Pool | `auth_pool_l6` | Contains `ldap_l6` |
| 6 | Site Publish Rules | `first_site_pub`, `reports_site_pub` | HTML form authentication and `.lab.local` SSO |
| 6 | Compression Policy | `compress_l6` / captured `policy1` | Gzip text content; selected through `clone_inline` |
| 6 | Web Cache Rule | Host/path-scoped rule | `delivery.lab.local/static/`, GET/HEAD, 60-minute inactive expiry |
| 6 | Acceleration Policy | `acc_1` | HTML/JS/CSS/image optimization; attached to `Test1_pol` |
| 6 | Lua Script | `lua_header_l6` | Adds `X-Lesson6-Lua: active` to delivery responses |
| 6 | Waiting Room | `waiting_room_l6` | `/sale`, 1 active user; selected through `clone_inline` |
| 7 | HTTP Flood Prevention | `FP_1` | 3 req/sec per session per URL; selected by `POLHTTP7` |
| 7 | HTTP Access Limit | `HAL_7` | 5 req/sec standalone IP, 10 shared IP; selected by `POLHTTP7` |
| 7 | Malicious IPs | `MALIP_7` | 5 concurrent TCP connections per HTTP session; selected by `POLHTTP7` |
| 7 | TCP Flood Prevention | `TCPFP_7` | 5 fully formed TCP connections per source IP; selected by `POLHTTP7` |
| 7 | DoS Protection Policy | `POLHTTP7` | Four child rules plus final Layer 3 Fragment Protection; attached to `Test1_pol` |
| 7 | Syslog Policy | `syslogssss` | `10.0.20.2:514/TCP`, JSON; Event/Attack/Traffic at Information |
| 7 | Sensitive Data Logging | `sensitive_l7` | General Masks for password, token, and card-like JSON values |
| 8 | Feature Visibility | Web Vulnerability Scan | Enabled; exposes scan profile/template/schedule/history/integration/reporting workflow |
| 8 | Scan Template | `OWASP Top 10` | Selected by scan profile `Test1` |
| 8 | Scan Profile | `Test1` | Target `http://juice.lab.local`; uses `OWASP Top 10` |
| 8 | Web Vulnerability Scan Policy | `TestOwasp10` | `Run Now`; profile `Test1`; captured status `Starting` |

See each lesson for complete child-rule settings and validation evidence.

Lesson 7 evidence note: the supplied policy screenshot is an intermediate capture with `accLim1`, `MalIP`, and Fragment Protection off. The final report records `HAL_7`/`MALIP_7`, and the lab operator confirmed Fragment Protection was enabled afterward.

Lesson 8 evidence note: lab screenshots verify feature visibility, built-in templates, profile `Test1`, target `http://juice.lab.local`, template `OWASP Top 10`, policy `TestOwasp10`, `Run Now`, and status `Starting`. The assessment workflow adds no enforcement attachment.
