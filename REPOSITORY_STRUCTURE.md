# Repository Structure and Publishing Rules

## Recommended tree

```text
fortiweb-waf-security-lab/
├── README.md
├── CHANGELOG.md
├── LICENSE
├── SECURITY.md
├── .gitignore
├── docs/
│   ├── architecture.md
│   ├── object-inventory.md
│   ├── troubleshooting-index.md
│   └── images/
│       └── topology/
├── lessons/
│   ├── _template/
│   │   └── README.md
│   ├── 01-reverse-proxy-foundation/
│   │   ├── README.md
│   │   ├── configs/
│   │   └── evidence/
│   ├── 02-content-routing-and-delivery/
│   │   ├── README.md
│   │   ├── configs/
│   │   └── evidence/
│   ├── 03-web-application-protection/
│   │   ├── README.md
│   │   ├── configs/
│   │   └── evidence/
│   ├── 04-api-protection/
│   │   ├── README.md
│   │   ├── configs/
│   │   └── evidence/
│   └── 06-application-delivery/
│       ├── README.md
│       ├── configs/
│       │   └── lua_header_l6.lua
│       └── evidence/
├── vuln-sites/
│   ├── README.md
│   ├── juice-shop/
│   │   └── compose.yaml
│   ├── webgoat/
│   │   └── compose.yaml
│   ├── lesson3-test-site/
│   │   ├── README.md
│   │   ├── upload_server.py
│   │   ├── index.html
│   │   ├── private/
│   │   └── public/
│   ├── lesson4-api/
│   │   ├── README.md
│   │   ├── api_server.py
│   │   ├── schemas/
│   │   └── openapi.json
│   └── lesson6-delivery/
│       ├── README.md
│       ├── delivery_server.py
│       ├── static/
│       └── ldap/
├── fortiweb/
│   ├── README.md
│   ├── sanitized-objects/
│   │   ├── lesson-01.md
│   │   ├── lesson-02.md
│   │   ├── lesson-03.md
│   │   ├── lesson-04.md
│   │   └── lesson-06.md
├── scripts/
│   ├── client/
│   │   └── setup-hosts.sh
│   ├── attacks/
│   │   ├── lesson-03.sh
│   │   └── lesson-04.sh
│   └── validation/
│       ├── smoke-test.sh
│       └── lesson-06.sh
└── evidence/
    ├── lesson-01/
    ├── lesson-02/
    ├── lesson-03/
    └── lesson-04/
```

## Directory ownership

| Path | Purpose | Rule |
| --- | --- | --- |
| `lessons/NN-name/README.md` | Canonical narrative for one lesson | Keep all commands, payloads, issues, and final validation here |
| `lessons/NN-name/configs/` | Lesson-specific schemas, object tables, or sanitized exports | Add only files introduced or changed in that lesson |
| `lessons/NN-name/evidence/` | Selected screenshots or compact output excerpts | Use descriptive names; never upload a screenshot dump |
| `vuln-sites/` | Reproducible backend application files | Organize by application, not by screenshot/date |
| `fortiweb/sanitized-objects/` | Version-neutral object inventories | Never commit raw secrets or private certificate material |
| `scripts/attacks/` | Repeatable lab-only negative tests | Keep scope warnings and safe defaults in every script |
| `scripts/validation/` | Known-good and regression checks | Run after every lesson to prove older routes still work |
| `docs/` | Cross-lesson explanations | Do not duplicate the full lesson narratives here |
| `evidence/` | Optional project-wide raw evidence | Prefer lesson-local evidence for anything cited directly |

## Incremental publishing unit

One lesson publication should normally contain exactly:

```text
lessons/NN-name/**
vuln-sites/<backend-added-by-this-lesson>/**   # when applicable
fortiweb/sanitized-objects/lesson-NN.md
scripts/attacks/lesson-NN.sh                  # when applicable
scripts/validation/lesson-NN.sh               # when the lesson has a focused test suite
scripts/validation/smoke-test.sh              # updated regression checks
README.md                                     # progress table/link only
CHANGELOG.md                                  # one new release entry
```

Do not pre-create empty future lesson directories. Git does not track empty directories, and publishing them early weakens the lesson-by-lesson history. Copy `lessons/_template/` only when starting the next lesson.

## Naming conventions

- Lesson directories: `NN-kebab-case-title`
- Images: `NN-control-test-result.png`, for example `03-csrf-missing-token-block.png`
- Evidence outputs: `NN-test-name-response.txt`
- FortiWeb objects: keep the real lab object name in backticks, even if the file has a descriptive name
- Sanitized secrets: `<REDACTED>`, `<TOKEN>`, `<COOKIE>`, or `<PRIVATE_KEY_REMOVED>`
- Commands: use fenced `bash`, `json`, `xml`, or `graphql` blocks rather than screenshots of terminals

## Suggested supporting documents

- `docs/architecture.md`: expanded topology, traffic flow, and trust boundaries
- `docs/object-inventory.md`: cumulative table of object name, type, attachment point, first lesson, and current status
- `docs/troubleshooting-index.md`: issue-to-fix index linking back to each lesson
- `SECURITY.md`: lab-only scope, disclosure contact, and secret-reporting instructions
- `LICENSE`: choose a license before public release; consider separating documentation and code licenses if desired
