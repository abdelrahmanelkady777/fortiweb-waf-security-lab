# FortiWeb WAF Security Lab

Hands-on FortiWeb WAF lab built in EVE-NG as an NSE 5/FortiWeb self-study project. The repository documents an incrementally constructed reverse-proxy and application-security environment: every lesson keeps the working delivery path and adds another protection layer to it.

> This is an independent educational lab, not official Fortinet course material. All attack traffic targets deliberately vulnerable applications inside an isolated environment.

## What this repository demonstrates

- Reverse-proxy publishing through a dedicated FortiWeb VIP
- Multiple applications behind one VIP using HTTP `Host`-based content routing
- Load balancing, health checks, source-IP persistence, and `X-Forwarded-For`
- HTTPS offloading at FortiWeb with HTTP between FortiWeb and the backends
- Signature-based and application-aware controls for web traffic
- API contract enforcement for JSON, XML, GraphQL, and OpenAPI traffic
- Repeatable positive, negative, and regression tests from a Kali client
- Real troubleshooting notes, including misattachments, port mismatches, session requirements, and trial-license limitations

## Final integrated architecture

```mermaid
flowchart TB
    K["Kali client / attacker<br/>10.0.11.2"] -->|"HTTP/HTTPS<br/>Host-based requests"| F["FortiWeb<br/>port2 10.0.11.1<br/>VIP 10.0.11.100<br/>Vip1 / Test1_pol / clone_inline"]
    F -->|"port3 10.0.20.1"| J["Juice Shop pool<br/>10.0.20.2:3000, :3001"]
    F --> W["WebGoat pool<br/>10.0.20.2:8080"]
    F --> L3["Lesson 3 test site<br/>10.0.20.2:8000"]
    F --> A["Lesson 4 API<br/>10.0.20.2:8002"]
```

FortiWeb exposes one client-side entry point and selects the backend from the request hostname:

| Hostname | Content route | Backend purpose |
| --- | --- | --- |
| `juice.lab.local` | `route_juice` | Juice Shop vulnerability and pool tests |
| `webgoat.lab.local` | `route_webgoat` | WebGoat training application |
| `urlenc.lab.local` | `route_urlenc` | Deterministic Lesson 3 HTML, form, script, DLP, and upload tests |
| `api.lab.local` | `route_api_lesson4` | Deterministic Lesson 4 JSON, XML, GraphQL, JWT, and OpenAPI tests |

Client-side name resolution used in the lab:

```text
10.0.11.100 juice.lab.local webgoat.lab.local urlenc.lab.local api.lab.local
```

## Core network and policy chain

| Component | Lab value |
| --- | --- |
| Kali client | `10.0.11.2/24`, gateway `10.0.11.1` |
| FortiWeb client interface | `port2`, `10.0.11.1/24` |
| FortiWeb VIP | `10.0.11.100` |
| Virtual server | `Vip1` |
| FortiWeb server interface | `port3`, `10.0.20.1/24` |
| Backend Ubuntu/Docker host | `10.0.20.2/24`, gateway `10.0.20.1` |
| Main server policy | `Test1_pol` |
| Deployment mode | HTTP Content Routing |
| Active cloned web protection profile | `clone_inline` |
| Active cloned signature policy | `clone_standard` |

The reusable enforcement chain is:

```text
Test1_pol
  -> clone_inline (Web Protection Profile)
       -> clone_standard (Signature Policy)
            -> custom signature groups and signatures
       -> CSRF, URL encryption, DLP, CORS, input/file controls
       -> JSON, XML, GraphQL, OpenAPI, and rate-limit controls
```

This attachment chain matters: creating an object does not enforce it until it is linked into the active profile and the profile is selected by the server policy.

## Lessons

| Lesson | Lab status | Repository write-up | Main outcome |
| --- | --- | --- | --- |
| [01 - Reverse Proxy Foundation](lessons/01-reverse-proxy-foundation/README.md) | Complete | Complete | Dedicated VIP, virtual server, health check, pool, protected hostname, HTTP service, and working Juice Shop reverse proxy |
| [02 - Content Routing and Delivery](lessons/02-content-routing-and-delivery/README.md) | Complete | Complete | Second application, two-host routing, second Juice Shop member, persistence, XFF, IP group, WAF enforcement, and HTTPS offload |
| [03 - Web Application Protection](lessons/03-web-application-protection/README.md) | Complete | Complete | Known/custom signatures, CSRF, URL controls, DLP, headers, CORS, SRI, input validation, hidden fields, file security, and web-shell detection |
| [04 - API Protection](lessons/04-api-protection/README.md) | Complete | Complete | Integrated API backend, JSON/XML/GraphQL/OpenAPI enforcement, JWT flow, method control, and rate limiting |

The lesson documents are intentionally independent. A reader can stop after any lesson and still have a valid lab state.

## Repository layout

```text
.
├── README.md
├── CHANGELOG.md
├── REPOSITORY_STRUCTURE.md
├── docs/
│   ├── architecture.md
│   ├── object-inventory.md
│   ├── troubleshooting-index.md
│   └── images/
├── lessons/
│   ├── _template/README.md
│   ├── 01-reverse-proxy-foundation/
│   ├── 02-content-routing-and-delivery/
│   ├── 03-web-application-protection/
│   └── 04-api-protection/
├── vuln-sites/
│   ├── juice-shop/
│   ├── webgoat/
│   ├── lesson3-test-site/
│   └── lesson4-api/
├── fortiweb/
│   ├── sanitized-objects/
│   └── screenshots/
├── scripts/
│   ├── client/
│   ├── attacks/
│   └── validation/
└── evidence/
    ├── lesson-01/
    ├── lesson-02/
    ├── lesson-03/
    └── lesson-04/
```

See [REPOSITORY_STRUCTURE.md](REPOSITORY_STRUCTURE.md) for ownership rules and the exact files that should accompany each lesson commit.

## How to read a lesson

Each lesson follows the same evidence-first structure:

1. Scope and prerequisite state
2. Architecture delta from the previous lesson
3. Backend files or services added
4. FortiWeb objects and attachment chain
5. Exact configuration sequence
6. Baseline request
7. Attack commands and payloads
8. Observed FortiWeb and backend results
9. Debugging issues and fixes
10. Positive, negative, and regression validation

Use [`lessons/_template/README.md`](lessons/_template/README.md) when publishing another lesson.

## Reproducing the lab

Prerequisites:

- EVE-NG with a FortiWeb virtual appliance available under a valid license or trial
- A Kali Linux client on `10.0.11.0/24`
- An Ubuntu backend host on `10.0.20.0/24`
- Docker for Juice Shop and WebGoat
- `curl` for deterministic request/response validation

Recommended validation order:

```bash
# 1. Confirm the backend service locally on Ubuntu.
curl -i http://127.0.0.1:<backend-port>/<health-or-test-path>

# 2. Confirm FortiWeb can reach the backend pool member.
# Check the pool/health status in FortiWeb.

# 3. Confirm routing through the VIP from Kali.
curl -i -H "Host: <hostname>" http://10.0.11.100/<path>

# 4. Run one known-good request.
# 5. Run one deliberately invalid request.
# 6. Confirm the FortiWeb action/log and verify whether the backend saw it.
# 7. Re-test all earlier hostnames.
```

## Evidence standard

Every claimed control should include:

- The exact request, including headers, method, encoding, body, and session-cookie handling
- The expected outcome before the test
- The observed HTTP status and relevant response fragment
- The FortiWeb event or attack-log evidence
- Backend evidence when needed to distinguish a WAF block from an application rejection
- A known-good control request showing legitimate traffic still works

Screenshots support the write-up; they do not replace commands and recorded results.

## Known environment limitations

- Lesson 3 lightweight JavaScript/client-side policy creation was unavailable in the trial image, so the concept was documented without claiming a completed configuration.
- Lesson 4 ML/API discovery entered a running state but its API collection remained at zero in the tested image.
- FortiWeb mobile/JWT validation was not exposed in the GUI; JWT issuance and verification were implemented and validated at the backend instead.
- Object labels can differ between FortiWeb versions. The write-ups preserve both the object purpose and the values that affect traffic.

## Responsible use and sanitization

Do not commit private keys, license files, real credentials, management-session cookies, bearer tokens, password hashes, or unsanitized FortiWeb configuration exports. Replace temporary lab tokens and cookie values with placeholders while preserving the command structure.

Attack commands in this repository are for the isolated lab only. Do not use them against systems without explicit authorization.

## Project history

The repository is released lesson by lesson. See [CHANGELOG.md](CHANGELOG.md) for the release convention and milestone record.
