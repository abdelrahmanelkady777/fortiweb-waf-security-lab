# Lesson 04 - Sanitized FortiWeb Objects

| Object type | Name | Critical value / attachment |
| --- | --- | --- |
| Server pool | `pool_api_lesson4` | `10.0.20.2:8002` |
| Content route | `route_api_lesson4` | Host `api.lab.local` -> API pool |
| JSON Schema | `json_schema_register_lesson4` | Draft-07 registration schema |
| JSON policy | `policy_l4` | Attached to `clone_inline` |
| XML Schema | `xml_schema_user_lesson4` | User-upload XSD |
| XML policy | `xml_policy_lesson4` | Limits and forbidden entities; attached to `clone_inline` |
| GraphQL rule | Lesson 4 GraphQL rule | Host `api.lab.local`, URL `/graphql`, introspection/fragments denied |
| OpenAPI definition | `openapi_lesson4` | Uploaded controlled API contract |
| OpenAPI policy | `openapi_policy_lesson4` | Attached to `clone_inline` |
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
