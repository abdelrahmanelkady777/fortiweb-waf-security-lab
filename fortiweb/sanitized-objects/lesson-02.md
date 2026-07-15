# Lesson 02 - Sanitized FortiWeb Objects

Lesson 2 changed the existing `Test1_pol` into the shared HTTP content-routing policy; it did not add a competing VIP.

| Object type | Name | Critical value / attachment |
| --- | --- | --- |
| Server pool | `Juice_shop` | Members `10.0.20.2:3000` and `:3001` |
| Server pool | `web_goat` | `10.0.20.2:8080` |
| Protected hostnames | `host_lab_apps` | Includes Juice Shop and WebGoat hostnames; later policy capture shows `Juice_shpool` instead |
| Content route | `route_juice` | Host `juice.lab.local` -> `Juice_shop` |
| Content route | `route_webgoat` | Host `webgoat.lab.local` -> `web_goat` |
| Persistence | `persist_source_ip` | Source IP `/32`, 300 seconds |
| X-Forwarded-For | `xff_original` | Append original client IP on the right |
| IP group | `ipgrp_kali_client` | `10.0.11.2/32`; supplied configuration capture shows object name `kali_ip` |
| Web Protection Profile | Initial inline profile | Selected in `Test1_pol`; later cumulative capture shows `clone_inline` |
| HTTPS service/certificate | Lab HTTPS offload | TLS terminates at FortiWeb; backend remains HTTP |

Final routing model:

```text
Vip1 / 10.0.11.100 -> Test1_pol (HTTP Content Routing)
  +-- juice.lab.local   -> route_juice   -> Juice_shop
  +-- webgoat.lab.local -> route_webgoat -> web_goat
```

Private certificate keys are deliberately excluded.

## Evidence coverage

| Record area | Screenshot status |
| --- | --- |
| Hostname resolution | Directly shown for both Lesson 2 hostnames resolving to `10.0.11.100` |
| Backend containers | Ports `3000`, `3001`, `8080`, and `9090` shown; WebGoat is `unhealthy` at capture and later containers are also visible |
| Pool and route objects | Pool names/types and both exact Host-prefix route mappings directly shown; pool members and persistence are not visible |
| `Test1_pol` integration | Later capture shows `Vip1`, HTTP Content Routing, the inherited Lesson 2 routes, HTTP/HTTPS, and Client Real IP off alongside later routes |
| Protected hostnames | Later policy capture shows `Juice_shpool`; no supplied object page proves membership or the narrative name `host_lab_apps` |
| IP group | Direct capture shows `kali_ip` containing `10.0.11.2`; narrative `ipgrp_kali_client` and `/32` are not visible |
| X-Forwarded-For | Configuration and backend packet capture directly prove `xff_original` settings and runtime `X-Forwarded-For: 10.0.11.2` |
| Web protection | Later capture shows `clone_inline`; mixed attack log shows signature events, but not the original profile, test payload, action, response, URL, or attack ID |
| WebGoat routing | Directly shown returning `302` to `/WebGoat/login` with a FortiWeb session cookie |
| Persistence and HTTPS offload | No supplied screenshot directly proves persistence behavior, certificate details, TLS handshake, or the HTTP backend leg after offload |

Evidence files are stored under [`../../lessons/02-content-routing-and-delivery/evidence/`](../../lessons/02-content-routing-and-delivery/evidence/).

The later policy capture uses protected-hostname object `Juice_shpool`, the IP-group capture uses `kali_ip`, and the security-profile capture shows later `clone_inline`. These capture-time values are retained alongside the repository narrative rather than silently replacing it.
