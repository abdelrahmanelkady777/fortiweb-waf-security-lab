# Cumulative FortiWeb Object Inventory

| First lesson | Object type | Name | Critical value / attachment |
| ---: | --- | --- | --- |
| 1 | Network VIP | `VIP1` | `10.0.11.100` on `port2` |
| 1 | Virtual Server | `Vip1` | Uses `VIP1`; enabled |
| 1 | Health Check | `hc_icmp_juice` | ICMP |
| 1 | Server Pool | `Juice_shop` | `10.0.20.2:3000`; later `:3001` added |
| 1 | Server Policy | `Test1_pol` | Main policy retained across all lessons |
| 2 | Server Pool | `web_goat` | `10.0.20.2:8080` |
| 2 | Protected Hostnames | `host_lab_apps` | Juice Shop and WebGoat; later Lesson 3/4 names added |
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

See each lesson for complete child-rule settings and validation evidence.

