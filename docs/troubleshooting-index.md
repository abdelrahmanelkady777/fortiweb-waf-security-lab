# Troubleshooting Index

| Symptom | High-probability check | Lesson |
| --- | --- | ---: |
| VIP hangs | VIP, virtual server, HTTP service, policy status | [1](../lessons/01-reverse-proxy-foundation/README.md) |
| Pool is down | Backend local service, host port, gateway, pool member | [1](../lessons/01-reverse-proxy-foundation/README.md) |
| One hostname routes incorrectly | Protected hostname and Host-match route | [2](../lessons/02-content-routing-and-delivery/README.md) |
| Backend lacks original client IP | Attach XFF; do not confuse with Client Real IP | [2](../lessons/02-content-routing-and-delivery/README.md) |
| HTTPS fails while HTTP works | HTTPS service/certificate and backend SSL setting | [2](../lessons/02-content-routing-and-delivery/README.md) |
| Custom signature never fires | Verify the entire signature-to-policy chain | [3](../lessons/03-web-application-protection/README.md) |
| JSON SQLi passes | Inspect Request Raw Body | [3](../lessons/03-web-application-protection/README.md) |
| CSRF/hidden-field false result | Preserve the same page-load/session cookie | [3](../lessons/03-web-application-protection/README.md) |
| Empty backend reply | Align the server process and pool port | [3](../lessons/03-web-application-protection/README.md) |
| JSON violations reach API | Attach JSON policy to `clone_inline`; re-save `Test1_pol` | [4](../lessons/04-api-protection/README.md) |
| GraphQL introspection still allowed | Disable the allow-style introspection toggle | [4](../lessons/04-api-protection/README.md) |
| API discovery remains zero | Record image/trial limitation; use manual controls | [4](../lessons/04-api-protection/README.md) |

