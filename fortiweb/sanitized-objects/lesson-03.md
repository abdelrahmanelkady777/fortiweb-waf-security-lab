# Lesson 03 - Sanitized FortiWeb Objects

| Object type | Name | Critical value / attachment |
| --- | --- | --- |
| Server pool | `pool_urlenc_test` | `10.0.20.2:8000` |
| Content route | `route_urlenc` | Host `urlenc.lab.local` -> Lesson 3 pool |
| Web Protection Profile | `clone_inline` | Active profile selected by `Test1_pol` |
| Signature Policy | `clone_standard` | Selected inside `clone_inline` |
| Custom group | `cgrp_lesson3_custom` | Contains path traversal and JSON SQLi signatures |
| Custom signature | `custom_path_traversal` | Request traversal patterns; Alert & Deny |
| Custom signature | `custom_json_sqli_login` | Request Raw Body target; Alert & Deny |
| URL Encryption | `urlenc_policy_lesson3` | Protects `/private/account.html` |
| Link Cloaking | `linkcloak_policy_lesson3` | Protects `/public/contact.html` |
| DLP | `dlp_policy_lesson3` | Response marker protection |
| HTTP headers | `hhs_lesson3_basic` | XFO, nosniff, Referrer Policy, CSP Report-Only |
| CORS | `cors_policy_lesson3` | `juice.lab.local/rest/*` |
| SRI | `sri_policy_lesson3` | `/public/app.js` |
| Additional profile controls | Lesson 3 rules | CSRF, parameter validation, hidden fields, file security, web-shell detection |

Attachment chain:

```text
Test1_pol
  -> clone_inline
       -> clone_standard
            -> cgrp_lesson3_custom
       -> CSRF / URL / DLP / header / CORS / SRI / input / file controls
```

The lightweight-JavaScript/client-side policy was unavailable in the tested trial image and is not marked as configured.
