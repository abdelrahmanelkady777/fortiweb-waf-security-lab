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
| Lesson 6 routes fail after reboot | Restart the Python `:8003` service; verify HTTP health and pool status | [6](../lessons/06-application-delivery/README.md) |
| Rewrite object has no effect | Verify rule -> rewriting policy -> `clone_inline` -> `Test1_pol` | [6](../lessons/06-application-delivery/README.md) |
| Private path remains public | Check Site Publish host/path, auth pool, and direct `Test1_pol` attachment | [6](../lessons/06-application-delivery/README.md) |
| SSO prompts twice | Align both rules and `.lab.local`; clear stale cookies | [6](../lessons/06-application-delivery/README.md) |
| Compression/cache is absent | Check feature visibility, client encoding, content type, host/path, and cache key | [6](../lessons/06-application-delivery/README.md) |
| Lua header or Waiting Room is absent | Verify direct scripting list or profile-layer queue attachment and exact host/path | [6](../lessons/06-application-delivery/README.md) |
| Several DoS subtypes fire on one burst | Keep non-target rules in Alert and enforce one low-threshold child at a time | [7](../lessons/07-dos-and-logging/README.md) |
| Connection-limit test never crosses threshold | Use `/slow`; fast responses close before connections overlap | [7](../lessons/07-dos-and-logging/README.md) |
| Session-aware DoS result is inconsistent | Deliberately reuse one cookie or separate two cookie jars | [7](../lessons/07-dos-and-logging/README.md) |
| Fresh cookie remains blocked | HTTP Access Limit keys on source IP; wait for the period block to expire | [7](../lessons/07-dos-and-logging/README.md) |
| Fragment test produces no event | Confirm final `POLHTTP7` saved state, fragmentation, VIP/port, and Attack-log filter | [7](../lessons/07-dos-and-logging/README.md) |
| Syslog receiver is empty | Match `514/TCP`, allow FortiWeb's source, and generate fresh selected log categories | [7](../lessons/07-dos-and-logging/README.md) |
| Sensitive values remain in logs | Enable the rule, generate a new request, and inspect the new packet log rather than history | [7](../lessons/07-dos-and-logging/README.md) |
| Lesson 4 login limit disappears after Lesson 7 | Migrate the earlier rule into the active combined DoS policy if only one selector is available | [7](../lessons/07-dos-and-logging/README.md) |
