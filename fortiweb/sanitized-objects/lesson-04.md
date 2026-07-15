# Lesson 04 - Sanitized FortiWeb Objects

| Object type | Name | Critical value / attachment |
| --- | --- | --- |
| Server pool | `pool_api_lesson4` | `10.0.20.2:8002`; later capture shows pool name `API_lesson4` |
| Content route | `route_api_lesson4` | Host `api.lab.local` -> API pool |
| JSON Schema | `json_schema_register_lesson4` | Draft-07 registration schema |
| JSON policy | `policy_l4` | Attached to `clone_inline`; later capture shows `policy_L4` |
| XML Schema | `xml_schema_user_lesson4` | User-upload XSD |
| XML policy | `xml_policy_lesson4` | Limits and forbidden entities; attached to `clone_inline`; later capture shows `POLXML` |
| GraphQL rule | Lesson 4 GraphQL rule | Host `api.lab.local`, URL `/graphql`, introspection/fragments denied; later attachment shows `QL4` |
| OpenAPI definition | `openapi_lesson4` | Uploaded controlled API contract |
| OpenAPI policy | `openapi_policy_lesson4` | Attached to `clone_inline`; later attachment shows `openAPI` |
| HTTP Access Limit | `rate_login_lesson4` | POST `/api/login`, 5 requests per 10 seconds |
| DoS policy | `dos_policy_lesson4` | Attached directly to `Test1_pol` |

Attachment chain:

```text
Test1_pol
  +-- route_api_lesson4 -> pool_api_lesson4 -> 10.0.20.2:8002
  +-- clone_inline -> JSON / XML / GraphQL / OpenAPI policies
  +-- dos_policy_lesson4 -> rate_login_lesson4
```

ML/API discovery ran but collected zero APIs in the tested image. FortiWeb JWT/mobile validation was not exposed; backend JWT validation is documented separately and not misrepresented here.

## Evidence coverage

| Record area | Screenshot status |
| --- | --- |
| Backend and routed health | Listener on `0.0.0.0:8002` and routed `api.lab.local/health` `200` are directly shown |
| Server pool | Later capture shows `API_lesson4`, member `10.0.20.2:8002`, HTTP/Reverse Proxy, Round Robin, `Juice_health`, and `ip_presist`; narrative name differs |
| Protected hostname | Later shared `Juice_shpool` capture directly includes `api.lab.local`; later hostnames and open edit state are visible |
| Inline API attachments | Later capture shows `POLXML`, `policy_L4`, `QL4`, and `openAPI`; it also shows Lesson 5 bot policy and omits the inline-profile name/save result |
| JSON | Rule capture shows `/api/*`, Alert & Deny, Medium; response/log captures show blocking and JSON Validation events, but schema/policy mapping is not visible |
| XML/XXE | Endpoint block page and XML External Entity Violation log are directly shown without a shared request ID |
| GraphQL | Endpoint block page and GraphQL Introspection Violation log are directly shown without a shared request ID |
| OpenAPI | Attack log shows an OpenAPI Validation Violation; definition, rule, URL/method, action, and response are not visible |
| HTTP Access Limit | Twenty login requests all return `500`; this does not prove the recorded 5-in-10-second threshold or distinguish WAF from backend failure |
| Content route, schemas, JWT, ML, methods, regression | No supplied screenshot directly proves these records |

Evidence files are stored under [`../../lessons/04-api-protection/evidence/`](../../lessons/04-api-protection/evidence/).

The names in the primary table retain the repository's canonical Lesson 4 narrative. Capture-time names and scope differences are recorded above rather than silently replacing that narrative.
