# Lesson 8 - Sanitized FortiWeb Assessment Record

Lesson 8 added an assessment capability, not a runtime enforcement object. This record contains only sanitized, screenshot-verified scan values.

## Assessment components

| Component | Name/value retained | Purpose | Evidence boundary |
| --- | --- | --- | --- |
| Feature Visibility | Web Vulnerability Scan enabled | Exposes scan profile, template, schedule, history, integration, and reporting menus | Toggle selection and resulting menus are lab-screenshot-verified |
| Scan Template | `OWASP Top 10` | Defines scan techniques/categories | Selected by profile `Test1`; lab-screenshot-verified |
| Scan Profile | `Test1` -> `http://juice.lab.local` | Binds the existing Juice Shop target to the selected template | Lab-screenshot-verified |
| Web Vulnerability Scan Policy | `TestOwasp10` -> `Run Now` -> `Test1` | Launches the configured assessment | Lab-screenshot-verified |
| Captured runtime state | `Starting` | Confirms the scan entered its start state | Lab-screenshot-verified |

## Workflow chain

```text
Feature Visibility
  -> Web Vulnerability Scan menus
  -> Scan Template: OWASP Top 10
  -> Scan Profile: Test1 -> http://juice.lab.local
  -> Scan Policy: TestOwasp10 -> Run Now -> captured Starting state
  -> Scan History and reporting workflow
  -> validate -> remediate -> regression test -> rescan
```

This chain does not attach to `clone_inline`, `POLHTTP7`, or `Test1_pol`. The target `http://juice.lab.local` remains reachable through the existing `10.0.11.100` / `Vip1` / `Test1_pol` data plane and `route_juice`.

## Explicitly unchanged

| Object class | Lesson 8 change |
| --- | --- |
| Backend process | None |
| Server pool / health check | None |
| Protected hostname | None |
| Content route | None |
| VIP / Virtual Server | None |
| Server policy / web protection profile | No new attachment |
| DoS policy | No change |
| Attack script | None |
| FortiDAST integration object | None; conceptual topic only |

See the [Lesson 8 README](../../lessons/08-compliance-and-vulnerability-scanning/README.md) for the compliance mappings, operational procedure, evidence index, and proof limitations.
