# Lesson 01 - Sanitized FortiWeb Objects

| Object type | Name | Critical value / attachment |
| --- | --- | --- |
| Interface | `port2` | `10.0.11.1/24`, client side |
| Interface | `port3` | `10.0.20.1/24`, server side |
| Network VIP | `VIP1` | `10.0.11.100` on `port2` |
| Virtual server | `Vip1` | Uses `VIP1`; enabled |
| Health check | `hc_icmp_juice` | ICMP check for the initial backend |
| Server pool | `Juice_shop` | `10.0.20.2:3000` |
| Protected hostname | Initial lab hostname object | Includes `juice.lab.local` |
| HTTP service | Existing HTTP service | Client-side HTTP listener |
| Server policy | `Test1_pol` | `Vip1` -> Juice Shop pool; enabled |

Initial data path:

```text
Kali 10.0.11.2 -> VIP 10.0.11.100 -> Vip1 -> Test1_pol
  -> Juice_shop -> 10.0.20.2:3000
```

No credentials, certificates, or license material are included.
