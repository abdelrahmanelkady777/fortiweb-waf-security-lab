# Changelog

All notable changes to this lab repository are recorded here. The project is published lesson by lesson so the history shows the environment growing over time.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and uses small milestone versions:

- Minor version: a completed lesson, for example `v0.3.0`
- Patch version: a correction or evidence improvement that does not add a lesson, for example `v0.3.1`
- `v1.0.0`: the reviewed, fully reproducible lab portfolio release

## [Unreleased]

### Added

- Root MIT license covering the repository's original code and documentation.
- Five curated Lesson 1 implementation captures covering the EVE-NG topology, FortiWeb data-plane interfaces, backend Juice Shop container, Network VIP, and successful HTTP response through the VIP.
- Eleven curated Lesson 2 captures covering backend services, shared-VIP hostname resolution, pools, content routes, integrated policy state, WebGoat routing, X-Forwarded-For, the Kali IP group, and signature-event logs.

### Changed

- Added claim-specific captions, an evidence index, and explicit proof limitations to the Lesson 1 README and sanitized object record.
- Preserved the management-address discrepancy between the Lesson 1 narrative (`192.168.1.32`) and the later interface capture (`192.168.1.41/24`) without changing the documented data path.
- Added Lesson 2 evidence captions/index entries and reconciled capture-time `Juice_shpool`, `kali_ip`, later `clone_inline`, mixed-date attack logs, and the temporarily unhealthy WebGoat container without rewriting the single-VIP design.

### Evidence notes

- The supplied Lesson 2 screenshots do not directly prove pool-member details, persistence behavior, protected-hostname membership, certificate/TLS negotiation, or the HTTP backend leg after offload; those capabilities remain repository-recorded.

## [0.9.0] - 2026-07-15

### Added

- Lesson 5 integrated bot-mitigation backend on `10.0.20.2:8004` and `bot.lab.local` behind the existing VIP.
- Biometric, threshold, Known Bots, and ML bot-detection records; focused route validation and private-lab traffic helpers.
- Eight curated Lesson 5 captures with direct-proof captions and a sanitized FortiWeb object record.

### Changed

- Extended the root architecture, hostname helper, smoke test, object inventory, troubleshooting index, backend-purpose index, repository map, and FortiWeb record index through Lesson 5.

### Validated

- Supplied captures directly show local valid/invalid backend login, routed `cookiesession1`, biometric/threshold/known-bot attack-log events, and capture-time configuration values.
- The report records browser, threshold, Known Bots, ML, temporary-enforcement, recovery, and cross-route regression results where raw captures were not supplied.

### Evidence notes

- The ML capture shows anomaly count `1` with dynamic updates enabled; the final report records threshold `2` and dynamic updates disabled during the controlled anomaly test. Both are retained without asserting an unsupported final value.
- The Known Bots settings capture shows temporary `Alert & Deny`; the report records the non-disruptive operating state as Alert after the proof.

### Fixed

- Nothing yet.

## [0.8.0] - 2026-07-14

### Added

- Lesson 8 compliance and assessment documentation covering PCI DSS 4.0.1, OWASP Top 10 - 2021, and OWASP API Security Top 10 - 2023.
- Web Vulnerability Scan workflow, scan-evidence worksheet, sanitized assessment record, and safe pre-scan readiness/regression validation.
- Eight supplied course screenshots plus four target-specific FortiWeb lab screenshots with explicit evidence captions and proof limitations.
- FortiDAST/Security Fabric scan-to-defense workflow documentation without claiming a FortiDAST deployment.

### Changed

- Extended the cumulative architecture, object inventory, troubleshooting index, hosts helper, smoke tests, backend-purpose index, repository map, and FortiWeb record index through Lesson 8.
- Recorded that Lesson 8 reused the single VIP and existing published applications without adding a backend, pool, route, hostname, attack script, or runtime protection.

### Validated

- Lab evidence verifies Web Vulnerability Scan visibility and the built-in Full Audit, Fast Scan, Brute Force, and OWASP Top 10 templates.
- Lab evidence verifies profile `Test1`, target `http://juice.lab.local`, selected template `OWASP Top 10`, policy `TestOwasp10`, `Run Now`, and captured status `Starting`.
- Existing Lesson 1-7 routes remain in the safe regression set; the Lesson 8 script does not start an active scan.

### Evidence notes

- Compliance/OWASP/FortiDAST captures are course knowledge evidence, not proof of organizational compliance or a deployed external scanner.
- The target-specific lab captures document the implemented scan chain from feature visibility through the `Starting` state.

## [0.7.0] - 2026-07-13

### Added

- Lesson 7 session-aware and source-IP request/connection controls in combined policy `POLHTTP7`.
- Layer 3 Fragment Protection, local Event/Attack/Traffic logging, TCP/JSON syslog forwarding, and sensitive-data masking records.
- Focused Lesson 7 safe validation and isolated-lab attack scripts.
- Curated Lesson 7 evidence with explicit screenshot/report proof boundaries.

### Changed

- Extended the cumulative architecture, object inventory, troubleshooting index, smoke tests, repository map, and backend-purpose index through Lesson 7.
- Recorded that Lesson 7 reused the Lesson 4/6 backends and added no new application or hostname.
- Restored the missing Lesson 3 README that the root index and later lessons already referenced.

### Validated

- The supplied attack log directly shows HTTP Flood Prevention, HTTP Access Limit, and Malicious IPs subtypes for `10.0.11.2` against `delivery.lab.local/new`.
- The supplied global settings show Information-level disk/syslog logging for Event, Attack, and Traffic with policy `syslogssss` and local use 7.
- The Syslog Policy figure embedded in the supplied report directly shows `10.0.20.2:514/TCP` with JSON format.
- TCP Flood Prevention, fragment detection, receiver-side syslog receipt, value masking, timer recovery, and session-separation outcomes remain report-recorded where no raw screenshot was supplied.

### Evidence notes

- The supplied `POLHTTP7` image is a pre-final capture. It shows `accLim1`, `MalIP`, and Fragment Protection off; the final report records `HAL_7`/`MALIP_7`, and the lab operator confirmed Fragment Protection was enabled afterward.
- The active combined-policy record flags a carry-forward re-test for the earlier Lesson 4 login limit rather than claiming two simultaneous DoS-policy attachments without evidence.

## [0.6.0] - 2026-07-13

### Added

- Lesson 6 controlled application-delivery backend on `10.0.20.2:8003`.
- `delivery.lab.local` and `reports.lab.local` routes behind the existing `10.0.11.100` VIP.
- URL redirect, internal request rewrite, and response `Location` rewrite controls.
- LDAP-backed Site Publishing with HTML-form authentication and cross-host SSO.
- Gzip compression, host/path-scoped caching, acceleration, Lua response scripting, and Waiting Room admission control.
- Curated Lesson 6 screenshots, a focused automated validation script, and sanitized FortiWeb object records for the published lessons.

### Changed

- Extended the cumulative architecture, hostname mapping, hosts helper, smoke tests, object inventory, and troubleshooting index through Lesson 6.
- Reconciled source-evidence differences for the compression object name and cache file-type scope instead of silently normalizing them.

### Validated

- Rewriting changed the intended request/response elements while preserving public application behavior.
- LDAP authentication protected `/private/`; one SSO login covered both Lesson 6 hostnames.
- Compression, cache, acceleration, Lua header injection, and Waiting Room behavior were verified with curl, backend logs, or independent browser sessions.
- Existing Lesson 1-4 routes remained in the regression set.

## [0.4.0] - 2026-07-08

### Added

- Lesson 4 controlled API backend on `10.0.20.2:8002`.
- `api.lab.local` route behind the existing `10.0.11.100` VIP.
- JSON Schema, XML, GraphQL, OpenAPI, method-control, and rate-limit tests.
- Backend JWT login/profile validation and documented FortiWeb feature limitations.

### Validated

- Known-good API requests remained available.
- Invalid schemas, unknown paths, wrong methods, abnormal GraphQL operations, and login bursts were detected or denied according to the active action.
- Earlier application hostnames continued to route correctly.

## [0.3.0] - 2026-07-06

### Added

- Lesson 3 deterministic test site on backend port `8000`.
- Cloned signature and web-protection policy chain.
- Known-attack and custom-signature tests.
- CSRF, URL encryption, link cloaking, DLP, HTTP header, CORS, SRI, parameter, hidden-field, file-security, and web-shell controls.

### Fixed

- Used the complete policy attachment chain for custom signatures.
- Changed JSON signature inspection to request raw body.
- Corrected backend pool/server port mismatches during response-rewriting tests.

### Limited

- Client-side lightweight JavaScript policy creation was unavailable in the tested trial image.

## [0.2.0] - 2026-07-05

### Added

- Host-based content routing for Juice Shop and WebGoat behind one VIP.
- Second Juice Shop pool member on port `3001`.
- Source-IP persistence and original-client-IP forwarding with `X-Forwarded-For`.
- Kali client IP group, initial inline WAF enforcement, and HTTPS offloading.

### Changed

- Converted the Lesson 1 server policy to HTTP Content Routing instead of creating a competing policy on the same VIP and service.

## [0.1.0] - 2026-07-05

### Added

- Initial EVE-NG topology and IP plan.
- FortiWeb interfaces, dedicated VIP `10.0.11.100`, virtual server `Vip1`, ICMP health check, and Juice Shop pool.
- Server policy `Test1_pol` and first successful reverse-proxy validation.

## Commit style

Use Conventional Commits with a lesson or component scope:

```text
<type>(<scope>): <imperative summary>
```

Recommended types:

| Type | Use |
| --- | --- |
| `feat` | A lesson, backend, WAF object, protection, or meaningful validation is added |
| `fix` | A command, port, attachment point, result, or configuration is corrected |
| `docs` | Narrative, diagram, evidence caption, or index-only change |
| `test` | Attack, positive-control, or regression test change |
| `refactor` | Reorganization without changing documented behavior |
| `chore` | Release tags, formatting, repository maintenance |

Recommended scopes:

`lesson-01`, `lesson-02`, `lesson-03`, `lesson-04`, `lesson-06`, `lesson-07`, `lesson-08`, `backend`, `fortiweb`, `evidence`, `readme`, and `release`.

Examples:

```text
feat(lesson-01): publish reverse-proxy foundation
feat(lesson-02): add host-based routing and TLS offload
feat(lesson-03): document layered web protections
fix(lesson-03): inspect JSON SQLi in request raw body
feat(lesson-04): enforce API schemas and OpenAPI contract
test(lesson-04): add login burst and regression checks
feat(lesson-06): add integrated application-delivery controls
feat(lesson-07): add layered DoS protection and logging
feat(lesson-08): document compliance and vulnerability scanning
docs(readme): mark lesson 4 complete
chore(release): tag v0.4.0
```

Prefer one complete lesson commit over many commits named `update`, `changes`, or `final`. If a lesson is too large for one commit, split it by meaningful outcome, such as backend, FortiWeb objects, tests, and documentation.
