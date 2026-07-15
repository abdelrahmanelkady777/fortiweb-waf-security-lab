# Lesson 05 - Sanitized FortiWeb Objects

Lesson 5 adds bot-aware detection to the existing `Vip1` / `Test1_pol` path. It does not add a VIP, virtual server, or standalone server policy.

| Object type | Name | Critical value / attachment |
| --- | --- | --- |
| HTTP health check | `hc_bot_l5_http` | `GET /health`, expected `200` |
| Server pool | `pool_bot_l5` | `10.0.20.2:8004`, backend SSL disabled |
| Protected hostname | `bot.lab.local` | Accept in active hostname object |
| Content route | `route_bot_l5` | Host -> `pool_bot_l5` |
| Bot policy | `bot_policy_l5` | Selected in `clone_inline` |
| Biometric | `biometric_l5` | Browser interaction/trait evidence |
| Threshold | `threshold_l5` | Client-IP crawler/error and scraping thresholds |
| Known Bots | `known_bots_l5` | Crawler/scanner/crawler-identity handling |
| ML Bot Detection | `ml_bot_l5` | Separate `Test1_pol` Machine Learning lifecycle |

```text
Test1_pol
  +-- route_bot_l5 -> pool_bot_l5 -> 10.0.20.2:8004
  +-- clone_inline -> bot_policy_l5 -> biometric_l5 / threshold_l5 / known_bots_l5
  +-- Machine Learning -> ml_bot_l5
```

The final report records temporary enforcement followed by Alert-state recovery. The ML screenshot conflicts with the report on anomaly count and dynamic-update state; see the [configuration record](../../lessons/05-bot-mitigation/configs/bot-mitigation-settings.md).
