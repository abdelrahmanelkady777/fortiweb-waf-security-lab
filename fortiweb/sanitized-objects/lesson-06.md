# Lesson 06 - Sanitized FortiWeb Objects

## Routing and identity

| Object type | Name | Critical value / attachment |
| --- | --- | --- |
| HTTP health check | `hc_delivery_l6_http` | `GET /` |
| Server pool | `pool_delivery_l6` | `10.0.20.2:8003` |
| Content route | `route_delivery_l6` | Host `delivery.lab.local` -> Lesson 6 pool |
| Content route | `route_reports_l6` | Host `reports.lab.local` -> same pool |
| LDAP query | `ldap_l6` | `10.0.20.2:389`, identifier `uid`, base `ou=people,dc=lab,dc=local` |
| Authentication pool | `auth_pool_l6` | Contains `ldap_l6` |
| Site Publish rule | `first_site_pub` | `delivery.lab.local/private/`, HTML Form Authentication |
| Site Publish rule | `reports_site_pub` | `reports.lab.local/private/`, HTML Form Authentication |
| SSO domain | Both publish rules | `.lab.local` |

Passwords and generated LDAP hashes are deliberately excluded.

## Delivery controls

| Object type | Name | Critical value / attachment |
| --- | --- | --- |
| URL redirect rule | `rule1L6` | `/old` -> public `/new`, temporary `302` |
| Internal rewrite | `rewrite_legacy_to_modern_l6` | `/legacy/page` -> backend `/modern/page` |
| Response rewrite | `rewrite_location_l6` | Private backend `Location` -> public hostname |
| URL Rewriting policy | `urlrewrite_policy_l6` | Selected through `clone_inline` |
| Compression policy | `compress_l6` in report; `policy1` in screenshot | Gzip text/HTML/CSS/JavaScript; selected through `clone_inline` |
| Web Cache rule | Direct `Test1_pol` cache configuration | `delivery.lab.local/static/`, GET/HEAD, `200`, 60-minute inactive expiry |
| Acceleration policy | `acc_1` | HTML/JS/CSS/image optimization; direct `Test1_pol` attachment |
| Lua script | `lua_header_l6` | Adds `X-Lesson6-Lua: active` only for `delivery.lab.local` |
| Waiting Room | `waiting_room_l6` | `/sale`, 1 active user, 1 new user/minute; selected through `clone_inline` |

Source-evidence note: the cache screenshot shows all file-type boxes selected, while the report records the intended final type as `Text`. The lesson write-up recommends the tighter `Text` scope and preserves the screenshot discrepancy.

## Final attachment chain

```text
Test1_pol
  +-- HTTP Content Routing
  |     +-- route_delivery_l6 -> pool_delivery_l6 -> 10.0.20.2:8003
  |     +-- route_reports_l6  -> pool_delivery_l6 -> 10.0.20.2:8003
  +-- clone_inline
  |     +-- urlrewrite_policy_l6
  |     +-- compression policy
  |     +-- waiting_room_l6
  +-- Site Publish policy -> first_site_pub / reports_site_pub
  +-- Web Cache rule
  +-- acc_1
  +-- lua_header_l6
```
