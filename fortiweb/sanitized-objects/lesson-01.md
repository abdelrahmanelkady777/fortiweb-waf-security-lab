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

## Evidence coverage

| Record area | Screenshot status |
| --- | --- |
| EVE-NG links | Directly shown in `01-eve-ng-topology.png`; node roles and addresses are not visible |
| `port2` / `port3` addressing | Directly shown in `01-fortiweb-interface-addressing.png` |
| Network VIP `VIP1` | Directly shown in `01-network-vip-vip1.png` |
| Backend port `3000` | Directly shown as a published Docker port in `01-backend-juice-shop-container.png`; backend IP and pool membership are not visible |
| Client request to the VIP | Directly shown returning `200 OK` in `01-vip-http-200-response.png`; the response body is outside the capture |
| `Vip1`, `hc_icmp_juice`, `Juice_shop`, protected hostname, HTTP service, `Test1_pol` | Retained from the canonical Lesson 1 record; no supplied configuration-page screenshot directly proves these objects or attachments |

Evidence files are stored under [`../../lessons/01-reverse-proxy-foundation/evidence/`](../../lessons/01-reverse-proxy-foundation/evidence/).

The interface screenshot shows management `port1` at `192.168.1.41/24`, while the Lesson 1 narrative records `192.168.1.32`. The screenshot is treated as a later capture and is not used to replace the recorded management-plane value.
