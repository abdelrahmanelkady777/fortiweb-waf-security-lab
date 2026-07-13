# Lesson 02 - Sanitized FortiWeb Objects

Lesson 2 changed the existing `Test1_pol` into the shared HTTP content-routing policy; it did not add a competing VIP.

| Object type | Name | Critical value / attachment |
| --- | --- | --- |
| Server pool | `Juice_shop` | Members `10.0.20.2:3000` and `:3001` |
| Server pool | `web_goat` | `10.0.20.2:8080` |
| Protected hostnames | `host_lab_apps` | Includes Juice Shop and WebGoat hostnames |
| Content route | `route_juice` | Host `juice.lab.local` -> `Juice_shop` |
| Content route | `route_webgoat` | Host `webgoat.lab.local` -> `web_goat` |
| Persistence | `persist_source_ip` | Source IP `/32`, 300 seconds |
| X-Forwarded-For | `xff_original` | Append original client IP on the right |
| IP group | `ipgrp_kali_client` | `10.0.11.2/32` |
| Web Protection Profile | Initial inline profile | Selected in `Test1_pol` |
| HTTPS service/certificate | Lab HTTPS offload | TLS terminates at FortiWeb; backend remains HTTP |

Final routing model:

```text
Vip1 / 10.0.11.100 -> Test1_pol (HTTP Content Routing)
  +-- juice.lab.local   -> route_juice   -> Juice_shop
  +-- webgoat.lab.local -> route_webgoat -> web_goat
```

Private certificate keys are deliberately excluded.
