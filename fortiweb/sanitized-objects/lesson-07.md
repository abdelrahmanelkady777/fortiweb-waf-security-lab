# Lesson 07 - Sanitized FortiWeb Objects

## DoS controls

| Object type | Final report name | Critical value / attachment |
| --- | --- | --- |
| HTTP Flood Prevention | `FP_1` | 3 requests/sec per session per URL; Bot Confirmation off; High; Alert baseline; 30-second Period Block test |
| HTTP Access Limit | `HAL_7` | 5 requests/sec standalone IP; 10 requests/sec shared IP; Bot Confirmation off; High |
| Malicious IPs | `MALIP_7` | 5 TCP connections per HTTP session; High; Alert baseline and enforcement exercise |
| TCP Flood Prevention | `TCPFP_7` | 5 fully formed TCP connections per source IP; High |
| DoS Protection Policy | `POLHTTP7` | Selects all four child controls; Layer 3 Fragment Protection enabled in the final state; attached to `Test1_pol` |

The supplied `POLHTTP7` screenshot is an intermediate capture: it shows `accLim1`, `MalIP`, and Layer 3 Fragment Protection off. The final report records `HAL_7` and `MALIP_7`, and the lab operator confirmed Fragment Protection was enabled after the capture. Preserve the image as pre-final evidence rather than treating it as the final object state.

## Logging controls

| Object type | Name | Critical value / attachment |
| --- | --- | --- |
| Local disk logging | Global Log Settings | Information; Event, Attack, and Traffic; overwrite oldest when full |
| Syslog policy | `syslogssss` | `10.0.20.2:514/TCP`; JSON; selected in Global Log Settings |
| Syslog global settings | Global Log Settings | Information; local use 7; Event, Attack, and Traffic |
| Sensitive-data logging | `sensitive_l7` | General Masks for password, token, and card-like JSON values |

Secrets, real card data, receiver credentials, raw configuration exports, and management-session material are deliberately excluded.

## Final attachment chain

```text
Test1_pol
  +-- POLHTTP7
  |    +-- HTTP Session Based Prevention -> FP_1 + MALIP_7
  |    +-- HTTP DoS Prevention -> HAL_7 + TCPFP_7
  |    +-- Layer 3 Fragment Protection
  +-- Disk logging -> Event + Attack + Traffic
  +-- Syslog -> syslogssss -> 10.0.20.2:514/TCP, JSON
  +-- Sensitive Data Logging -> sensitive_l7
```

Cross-lesson note: Lesson 4 previously used `dos_policy_lesson4`. If the appliance exposes only one DoS-policy selector, the Lesson 4 login limit must be migrated into the active combined policy and re-tested; simultaneous attachment is not claimed without evidence.

## Evidence boundaries

- The supplied attack screenshot directly shows HTTP Flood Prevention, HTTP Access Limit, and Malicious IPs detections.
- The supplied global-settings screenshot directly shows enabled disk/syslog categories, Information level, `syslogssss`, and local use 7.
- The Syslog Policy screenshot embedded in the report directly shows `10.0.20.2:514/TCP` and JSON format.
- TCP Flood Prevention, fragment detection, receiver-side syslog receipt, sensitive-value masking, timer recovery, and two-cookie separation are documented by the final report but are not independently shown in the supplied screenshots.
