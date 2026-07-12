# Changelog

All notable changes to this lab repository are recorded here. The project is published lesson by lesson so the history shows the environment growing over time.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and uses small milestone versions:

- Minor version: a completed lesson, for example `v0.3.0`
- Patch version: a correction or evidence improvement that does not add a lesson, for example `v0.3.1`
- `v1.0.0`: the reviewed, fully reproducible lab portfolio release

## [Unreleased]

### Added

- Nothing yet.

### Changed

- Nothing yet.

### Fixed

- Nothing yet.

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

`lesson-01`, `lesson-02`, `lesson-03`, `lesson-04`, `backend`, `fortiweb`, `evidence`, `readme`, and `release`.

Examples:

```text
feat(lesson-01): publish reverse-proxy foundation
feat(lesson-02): add host-based routing and TLS offload
feat(lesson-03): document layered web protections
fix(lesson-03): inspect JSON SQLi in request raw body
feat(lesson-04): enforce API schemas and OpenAPI contract
test(lesson-04): add login burst and regression checks
docs(readme): mark lesson 4 complete
chore(release): tag v0.4.0
```

Prefer one complete lesson commit over many commits named `update`, `changes`, or `final`. If a lesson is too large for one commit, split it by meaningful outcome, such as backend, FortiWeb objects, tests, and documentation.

