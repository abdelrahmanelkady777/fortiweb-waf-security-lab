# Lesson 5 Sanitized Configuration Record

This rebuild record retains traffic-relevant object names, settings, attachment paths, and evidence boundaries. It is not a raw FortiWeb export.

## Route and attachment chain

| Object type | Name/value | Attachment or purpose |
| --- | --- | --- |
| Health check | `hc_bot_l5_http` | `GET /health`, expected `200` |
| Server pool | `pool_bot_l5` | `10.0.20.2:8004`, backend SSL disabled, uses `hc_bot_l5_http` |
| Protected hostname | `bot.lab.local` | Accept in active hostname object |
| Content route | `route_bot_l5` | `bot.lab.local` -> `pool_bot_l5` |
| Bot policy | `bot_policy_l5` | Selected in `clone_inline` |
| Conventional controls | `biometric_l5`, `threshold_l5`, `known_bots_l5` | Children of `bot_policy_l5` |
| ML control | `ml_bot_l5` | `Test1_pol` > Machine Learning > Bot Detection |

```text
Vip1 / 10.0.11.100 -> Test1_pol
  +-- route_bot_l5 -> pool_bot_l5 -> 10.0.20.2:8004
  +-- clone_inline -> bot_policy_l5
  |                    +-- biometric_l5
  |                    +-- threshold_l5
  |                    +-- known_bots_l5
  +-- Machine Learning -> ml_bot_l5
```

## Report-recorded settings

| Control | Values | Action sequence |
| --- | --- | --- |
| `biometric_l5` | `bot.lab.local` / `/`; mouse, focus, click, keyboard, scroll; touch where supported; Bot Trait Checking `2`; collection `10 s`, wait `10 s`, effective `60 s`; High | Alert -> temporary Alert & Deny -> Alert |
| `threshold_l5` | Client IP; crawler `5` in `10 s`; content scraping `8` in `15 s`; High | Alert -> temporary deny/block -> Alert |
| `known_bots_l5` | Malicious bots enabled, High; known/likely-good crawler handling enabled according to predefined lists | Alert -> temporary Alert & Deny -> Alert |
| `ml_bot_l5` | Source `10.0.11.2/32`; IP + User-Agent; vector `1 minute`; `20` samples/client/hour; initial target `10`; Moderate; Real Browser Enforcement | Alert -> temporary Alert & Deny -> Alert |

## Source discrepancies and limits

| Source | Directly visible | Difference/boundary | Treatment |
| --- | --- | --- | --- |
| `05-ml-bot-model-settings.png` | Moderate, IP + User-Agent, one-minute vector, 20 samples/hour, initial `10`, Real Browser Enforcement, Alert | Shows anomaly count `1` and dynamic update enabled; final report records threshold `2` and dynamic update disabled during controlled anomaly test | Both records retained; no unsupported single final value claimed |
| `05-known-bots-action-settings.png` | Malicious categories `Alert & Deny`; captured Known Good Bots use `Bypass` | Capture is enforcement state; report records return to Alert in the shared-lab operating state | Screenshot proves capture state; final reversion is report-recorded |
| `05-threshold-detection-settings.png` | Crawler `5/10 s`, scraping `8/15 s`, Alert, High; Vulnerability Scanning Detection visibly enabled at `100/10 s` | Report does not describe a separate vulnerability-scanning-detection test/final state | Not claimed as separately validated |
| Supplied captures | Settings/attack-log views | No raw route/pool/attachment page, backend log, ML attack log, ML final-status, or final Alert-state capture | Those claims are labelled report-recorded |
