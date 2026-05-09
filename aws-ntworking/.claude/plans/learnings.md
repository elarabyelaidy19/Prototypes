# AWS Cloud Networking — Learnings Journal

A running record of what's been built, what was proven, and the mental models that crystallized along the way. Read this if you've stepped away from the lab for a week and need to remember why things behave the way they do.

---

## Table of contents

1. [Lab 0 — Setup & Safety Rails](#lab-0--setup--safety-rails)
2. [Lab 1 — VPC + Subnets (Islands)](#lab-1--vpc--subnets-islands)
3. [Mental models locked in](#mental-models-locked-in)
4. [Gotchas / surprises encountered](#gotchas--surprises-encountered)
5. [Lab 2 — Public Subnet (IGW + Route Tables)](#lab-2--public-subnet-igw--route-tables)
6. [Lab 3 — Private Subnet + NAT Gateway](#lab-3--private-subnet--nat-gateway)
7. [Lab 4 — Security Groups vs NACLs](#lab-4--security-groups-vs-nacls)
8. [Lab 5 — Application Load Balancer](#lab-5--application-load-balancer)

---

## Lab 0 — Setup & Safety Rails

### What we did

| Step | Outcome |
|---|---|
| Created IAM user `networking-lab` with `AdministratorAccess` | Stopped using root credentials for daily work |
| Configured AWS CLI profile `lab` | All commands now scoped to that user |
| Set AWS Budget alarms ($5, $10) | Email warning if costs spike |
| Installed Terraform 1.15.1 | IaC tool of choice |
| Installed LocalStack 3.8 (community) + `tflocal` wrapper | Free local AWS-emulator for fast iteration |
| Picked region `us-east-1` | Cheapest, most services |
| Smoke-tested with `lab00-smoke` (single VPC against LocalStack) | Toolchain validated end-to-end |

### Why root → IAM matters

```
                  Without IAM user                With IAM user
                  ─────────────────               ─────────────
                                                  
   You ──key──> AWS                       You ──key──> IAM user ──> AWS
                 │                                       │
                 ▼                                       ▼
            FULL ACCOUNT                            Scoped permissions
            (incl. billing,                         (no billing,
             closing account,                        no key rotation
             root-only ops)                          on root, etc.)
            
   If keys leak: catastrophic            If keys leak: bad, but
                                          revocable; root is safe
```

The root account should **only** be used for: enabling MFA on root, account closure, and a handful of root-only ops. Everything else uses IAM identities.

### LocalStack wrinkles encountered

- `:latest` and `:stable` tags are now Pro-gated (need an auth token).
- Pinned to `:3.8` (community) → works.
- The `awscli-local` Python wrapper had a missing `botocore[crt]` dep when run through the `granted` CLI wrapper — solved with an `awslab` shell function that bypasses `granted` and sets explicit env vars.

---

## Lab 1 — VPC + Subnets (Islands)

### The central claim

> A VPC + subnets, with no gateways, are completely isolated from the internet — but instances inside the same VPC can talk to each other via an *implicit* local route that AWS auto-creates.

We proved this empirically. Here's how.

### Architecture deployed

```
                              AWS account 382884104985
   ┌─────────────────────────────────────────────────────────────────────┐
   │                                                                     │
   │   VPC: lab01-vpc   (10.0.0.0/16)   — 65,536 addresses                │
   │   ┌─────────────────────────────────────────────────────────────┐    │
   │   │                                                             │    │
   │   │   Subnet A (10.0.1.0/24, AZ us-east-1a)                     │    │
   │   │   ┌──────────────────────────┐   ┌──────────────────────┐   │    │
   │   │   │  EC2-A (t3.micro)        │   │  EICE                │   │    │
   │   │   │  AL2023                  │   │  (control-plane SSH) │   │    │
   │   │   │  private IP 10.0.1.110   │◀──│  no public IP        │   │    │
   │   │   │  no public IP            │   │                      │   │    │
   │   │   │  SG: lab01-instance-sg   │   │  SG: lab01-eice-sg   │   │    │
   │   │   └──────────────────────────┘   └──────────────────────┘   │    │
   │   │                                                             │    │
   │   ├─────────────────────────────────────────────────────────────┤    │
   │   │                                                             │    │
   │   │   Subnet B (10.0.2.0/24, AZ us-east-1b)                     │    │
   │   │   ┌──────────────────────────┐                              │    │
   │   │   │  EC2-B (t3.micro)        │                              │    │
   │   │   │  AL2023                  │                              │    │
   │   │   │  private IP 10.0.2.x     │                              │    │
   │   │   │  no public IP            │                              │    │
   │   │   │  SG: lab01-instance-sg   │                              │    │
   │   │   └──────────────────────────┘                              │    │
   │   │                                                             │    │
   │   └─────────────────────────────────────────────────────────────┘    │
   │                                                                      │
   │   Main route table (auto-created with VPC):                          │
   │   ┌─────────────────────────────────────┐                            │
   │   │  Destination    │  Target           │                            │
   │   ├─────────────────┼───────────────────┤                            │
   │   │  10.0.0.0/16    │  local            │   ← THE ONLY RULE          │
   │   └─────────────────────────────────────┘                            │
   │                                                                      │
   │   No IGW.  No NAT.  No custom RT.  No peering.                       │
   └──────────────────────────────────────────────────────────────────────┘

                             ▲
                             │  (control-plane only, via AWS API)
                             │
                       ┌─────┴─────┐
                       │  Laptop   │
                       │  (you)    │
                       └───────────┘
```

### Resources created (12 total)

| # | Type | Name |
|---|---|---|
| 1 | `aws_vpc` | lab01-vpc |
| 2 | `aws_subnet` | lab01-subnet-a |
| 3 | `aws_subnet` | lab01-subnet-b |
| 4 | `aws_security_group` | lab01-instance-sg |
| 5 | `aws_security_group` | lab01-eice-sg |
| 6 | `aws_vpc_security_group_ingress_rule` | ssh_from_eice (SG-to-SG) |
| 7 | `aws_vpc_security_group_ingress_rule` | icmp_from_vpc |
| 8 | `aws_vpc_security_group_egress_rule` | all_out (instance) |
| 9 | `aws_vpc_security_group_egress_rule` | eice_to_instances |
| 10 | `aws_instance` | lab01-ec2-a |
| 11 | `aws_instance` | lab01-ec2-b |
| 12 | `aws_ec2_instance_connect_endpoint` | lab01-eice |

### CIDR math we worked out

```
10.0.0.0/16 = "first 16 bits fixed, last 16 bits free"
            = 10.0.<anything>.<anything>
            = 65,536 total IPs
            = ~65,531 usable (5 reserved per subnet)

10.0.1.0/24 = "first 24 bits fixed, last 8 free"
            = 10.0.1.<anything>
            = 256 total IPs
            = 251 usable

AWS-reserved IPs in EVERY subnet:
   .0    network address          (e.g. 10.0.1.0)
   .1    VPC router               (e.g. 10.0.1.1)
   .2    DNS resolver hint        (e.g. 10.0.1.2)
   .3    reserved for future use  (e.g. 10.0.1.3)
   .255  broadcast address        (e.g. 10.0.1.255)
```

(There's also a magic VPC-wide DNS resolver at `vpc_base + 2`, e.g. `10.0.0.2` — separate from the per-subnet `.2`.)

### Behavioral tests run — predictions vs reality

| # | Test | Predicted | Actual | Verdict |
|---|---|---|---|---|
| 1 | SSH to EC2-A via EICE | ✅ works | `ec2-user@ip-10-0-1-110` prompt | ✅ |
| 2a | `ping 10.0.1.0` from EC2-A | ❌ fails (network address, reserved) | `Destination Host Unreachable` | ✅ predicted, taught us what reserved IPs *feel* like |
| 2b | `ping <EC2-B private IP>` from EC2-A | ✅ works (implicit local route) | (pending re-run) | — |
| 3 | `ping 8.8.8.8` from EC2-A | ❌ fails (no IGW) | 100% packet loss | ✅ |
| 4 | `curl https://example.com` | ❌ fails | DNS **resolved**, but TCP timed out | ✅ + bonus insight |
| 5 | `ip route` inside EC2-A | default via `.1`, only own subnet directly attached | exactly that | ✅ |
| 6 | Examine main route table | only `10.0.0.0/16 → local` | confirmed | ✅ |

### The `curl example.com` "aha" moment

```
$ curl -m 5 -v https://example.com
* Host example.com:443 was resolved.            ← DNS WORKED
* IPv4: 172.66.147.243, 104.20.23.154
* Trying 172.66.147.243:443...
* Connection timed out after 5002 milliseconds   ← TCP DIDN'T
```

**Why DNS worked:** The VPC has a magic resolver at `10.0.0.2`. Because we set `enable_dns_support = true`, the EC2 was configured to use it via DHCP. That resolver lives *inside* the VPC fabric — packets to `10.0.0.2` match the `local` route. **No internet needed for DNS.**

**Why TCP failed:** Once curl had `172.66.147.243`, it tried to open a TCP connection. There's no route in the table that matches `172.66.147.243`, so the kernel sends the packet to the default gateway (`10.0.1.1`). The VPC router sees a packet for an external IP, has no IGW route to forward to, and silently drops it. Five seconds later: timeout.

**The lesson:** *DNS resolution and network reachability are independent.* Engineers debug "the DNS is broken" all the time when actually DNS is fine and the network path is broken. Always test both layers separately.

### The `ip route` smoking gun

Inside EC2-A:

```
default via 10.0.1.1 dev ens5 proto dhcp src 10.0.1.110 metric 512
10.0.0.2 via 10.0.1.1 dev ens5 proto dhcp src 10.0.1.110 metric 512
10.0.1.0/24 dev ens5 proto kernel scope link src 10.0.1.110 metric 512
10.0.1.1 dev ens5 proto dhcp scope link src 10.0.1.110 metric 512
```

Read line by line:

```
default via 10.0.1.1
    "Anything I don't otherwise know about? Send to 10.0.1.1 (subnet gateway)."

10.0.0.2 via 10.0.1.1
    "DNS resolver lives at 10.0.0.2 — go through the gateway to reach it."
    (DHCP told us this explicitly.)

10.0.1.0/24 dev ens5
    "My own subnet. Anything in 10.0.1.x? Just shout on the wire (ARP)."

10.0.1.1 dev ens5
    "The gateway itself is reachable directly."
```

**Notice what's missing:** *No route for `10.0.2.0/24`.* Yet EC2-A *can* reach EC2-B. How?

Because the **default route** sends any unknown destination to `10.0.1.1` — the VPC's router. That router is AWS-managed and *knows* the entire VPC's CIDR (`10.0.0.0/16`). When it sees a packet for `10.0.2.x`, it forwards it through the VPC fabric to subnet B. The kernel doesn't need a route — AWS does the routing upstream.

```
   EC2-A kernel                  AWS VPC router                EC2-B
   ─────────────                 ────────────────              ──────
                                                                    
   pkt for 10.0.2.5         "match 10.0.0.0/16             receive
   "I don't know that  ──>   → local; forward to    ──>    pkt
    IP, send to default       subnet B's wire"
    gateway 10.0.1.1"
                                                                    
   ip route does NOT          AWS routing tables              No special
   list 10.0.2.0/24            DO list it                     setup needed
```

This is the core "implicit local route" mechanic the lab was designed to expose.

### Security Group design

```
   Laptop ──API──> EICE ──SSH(22)──> EC2-instance-sg
                    │
                    SG-to-SG reference
                    (NOT a CIDR rule)


   lab01-eice-sg                lab01-instance-sg
   ─────────────                ─────────────────
   Egress: tcp/22 →             Ingress: tcp/22 ←
     (referenced SG:               (referenced SG:
      lab01-instance-sg)            lab01-eice-sg)

                                Ingress: icmp from 10.0.0.0/16
                                Egress:  all (still no internet
                                              without IGW!)
```

**Why SG-to-SG references beat CIDR rules:** the EICE's IP could change (re-creation, AZ swap), but its SG identity is stable. Saying "whoever wears this SG, let them in" is more durable than "let in whatever's at 10.0.1.42 today."

**Pedagogical note:** The instance SG has `egress: all`. The instance *still* can't reach the internet. SGs are **necessary but not sufficient** for connectivity — you also need a route. People conflate "open the firewall" with "make it work." They are different problems.

### Break/fix exercise

We changed `subnet_b_cidr` to `10.0.1.0/24` (overlapping subnet A) and ran `terraform plan`. Predict where the failure shows up:

- **Terraform locally?** No — Terraform doesn't enforce CIDR uniqueness.
- **AWS API at apply time?** Yes — `InvalidSubnet.Conflict` because subnet CIDRs within a VPC must not overlap.

We reverted before applying (good hygiene: prove the prediction logic, don't actually break state).

### Destroy

```
Destroy complete! Resources: 12 destroyed.
```

Cost incurred: $0 (free tier). Time the resources lived: ~30 minutes.

---

## Mental models locked in

### 1. The VPC is just an IP range + a router

```
   ┌──────────────────────────────────────┐
   │  VPC: an IP block + an invisible     │
   │       router that knows that block   │
   │                                      │
   │  Everything else (subnets, IGW,      │
   │  NAT, peering) is just configuration │
   │  on top of that one router.          │
   └──────────────────────────────────────┘
```

### 2. A subnet is "an AZ-pinned slice of the VPC's IP range, with a route table"

The route table is the *contract* with the VPC router. It's the only thing that decides whether a subnet is "private," "public," "reaches NAT," "talks to a peer VPC," etc. Subnets aren't intrinsically anything — their **route table** makes them what they are.

### 3. Connectivity = route + permission + reachability

Three independent layers. *All* must be true:

```
   ┌─ ROUTE      "Is there a path? (route table)"        ──┐
   │                                                       │
   ├─ PERMISSION "Is the bouncer letting us through?       │  ALL
   │              (Security Group, NACL)"                  │  must be
   │                                                       │  TRUE
   └─ REACHABILITY "Does the destination exist & respond?  │
                   (target alive, listening, etc.)"      ──┘
```

Lab 1 had **permission** (egress all + ICMP-VPC ingress) but no **route** to the internet → connectivity failed.

### 4. The implicit `local` route is the engine of intra-VPC traffic

Every VPC ships with one route: `vpc_cidr → local`. Every subnet's route table inherits it (you can't remove or override it). It's why EC2s in different subnets, different AZs, different route tables can all talk to each other by default.

### 5. DNS is a layer above networking

DNS works inside a VPC even when you have no internet, because the resolver lives *in* the VPC. Don't conflate "I can resolve a name" with "I can reach the host."

### 6. EICE is a control-plane back door

It is **not** a route. It does not give the EC2 internet. It tunnels SSH from your laptop → AWS API → into the instance over the VPC fabric. The instance never knows the public internet exists.

```
        Your laptop                AWS control plane              Instance
        ───────────                ─────────────────              ────────
                                                                       
   aws ec2-instance-      ─TLS─>   API call ──VPC─>            sshd on
   connect ssh                     forwards SSH                 :22 inside
                                   into VPC fabric              VPC

   No public IP needed on instance.  No IGW needed.  No NAT needed.
```

---

## Gotchas / surprises encountered

| Gotcha | Resolution |
|---|---|
| LocalStack `:latest` / `:stable` are Pro-gated | Pinned to `:3.8` community |
| `granted` wrapper intercepts default profile | Used explicit `awslab` shell fn with `command aws` |
| AWS rejected em-dash (`—`) in SG description | ASCII-only descriptions |
| AWS rejected `>` in SG rule description | Stricter charset for `*_security_group_*_rule` than for SG itself |
| Stray `y` typed into `variables.tf` (meant for the `apply` prompt) | Removed and re-applied |
| EICE quota error on first apply | Resolved on retry (transient) |
| Pinged `10.0.1.0` as if it were an instance | It's the network address (reserved). Lesson: always use `terraform output` for actual IPs |
| Default Terraform AWS provider doesn't enable VPC DNS | Must set `enable_dns_support` and `enable_dns_hostnames` explicitly |

---

## Lab 2 — Public Subnet (IGW + Route Tables)

### The central claim

> A subnet becomes "public" ONLY when three things align: an IGW attached to the VPC, a route table entry `0.0.0.0/0 → IGW`, and a public IP on the instance. Remove any one of these three and internet connectivity breaks.

### Architecture deployed

```
                              AWS account 382884104985
   ┌──────────────────────────────────────────────────────────────────────┐
   │                                                                      │
   │   VPC: lab02-vpc   (10.0.0.0/16)                                      │
   │                                                                      │
   │   ┌──── Internet Gateway (lab02-igw) ────┐                            │
   │   │  Performs 1:1 NAT:                   │                            │
   │   │  10.0.1.77 <-> 44.195.62.23         │                            │
   │   └──────────────┬──────────────────────┘                            │
   │                  │                                                    │
   │   ┌──────────────┼──────────────────────────────────────────────┐    │
   │   │              ▼                                              │    │
   │   │   Subnet A (10.0.1.0/24, AZ us-east-1a) — PUBLIC            │    │
   │   │   Route table: lab02-public-rt                               │    │
   │   │   ┌───────────────────────┬───────────────┐                 │    │
   │   │   │ Destination           │ Target        │                 │    │
   │   │   ├───────────────────────┼───────────────┤                 │    │
   │   │   │ 10.0.0.0/16          │ local         │                 │    │
   │   │   │ 0.0.0.0/0            │ igw-xxx  ◄────── THE NEW ROW    │    │
   │   │   └───────────────────────┴───────────────┘                 │    │
   │   │                                                             │    │
   │   │   ┌──────────────────────────┐                              │    │
   │   │   │  EC2-A (t3.micro)        │                              │    │
   │   │   │  private: 10.0.1.77      │                              │    │
   │   │   │  public:  44.195.62.23   │                              │    │
   │   │   │  SG: lab02-public-sg     │                              │    │
   │   │   │  SSH from 156.206.x.x    │                              │    │
   │   │   └──────────────────────────┘                              │    │
   │   │                                                             │    │
   │   ├─────────────────────────────────────────────────────────────┤    │
   │   │                                                             │    │
   │   │   Subnet B (10.0.2.0/24, AZ us-east-1b) — PRIVATE           │    │
   │   │   Route table: main (default, auto-created)                  │    │
   │   │   ┌───────────────────────┬───────────────┐                 │    │
   │   │   │ Destination           │ Target        │                 │    │
   │   │   ├───────────────────────┼───────────────┤                 │    │
   │   │   │ 10.0.0.0/16          │ local         │  ← ONLY rule    │    │
   │   │   └───────────────────────┴───────────────┘                 │    │
   │   │                                                             │    │
   │   │   ┌──────────────────────────┐                              │    │
   │   │   │  EC2-B (t3.micro)        │                              │    │
   │   │   │  private: 10.0.2.190     │                              │    │
   │   │   │  NO public IP            │                              │    │
   │   │   │  SG: lab02-private-sg    │                              │    │
   │   │   │  SSH from public SG only │                              │    │
   │   │   └──────────────────────────┘                              │    │
   │   │                                                             │    │
   │   └─────────────────────────────────────────────────────────────┘    │
   └──────────────────────────────────────────────────────────────────────┘

               ▲                                         ▲
               │ SSH direct (port 22)                    │ SSH via -J jump
               │ + all internet traffic                  │ (tunneled through
               │                                         │  EC2-A)
         ┌─────┴─────┐                            ┌─────┴─────┐
         │  Laptop   │────────────────────────────►│  Laptop   │
         │  (you)    │  SG locked to your IP       │  (you)    │
         └───────────┘  156.206.107.137/32         └───────────┘
```

### Resources created (17 total)

| # | Type | Name | New in Lab 2? |
|---|---|---|---|
| 1 | `aws_vpc` | lab02-vpc | |
| 2 | `aws_subnet` | lab02-subnet-a-public | |
| 3 | `aws_subnet` | lab02-subnet-b-private | |
| 4 | `aws_internet_gateway` | lab02-igw | **YES** |
| 5 | `aws_route_table` | lab02-public-rt | **YES** |
| 6 | `aws_route_table_association` | subnet_a_public | **YES** |
| 7 | `aws_security_group` | lab02-public-sg | |
| 8 | `aws_security_group` | lab02-private-sg | |
| 9-14 | SG ingress/egress rules | (6 rules) | |
| 15 | `aws_key_pair` | lab02-key | **YES** |
| 16 | `aws_instance` | lab02-ec2-a-public | |
| 17 | `aws_instance` | lab02-ec2-b-private | |

### Prediction answers (with corrections)

> **Q1.** IGW attached but no route table change — does EC2-A get internet?
>
> **Answer: No.** The IGW is just a door. Without a route pointing to it (`0.0.0.0/0 → igw-xxx`), no traffic walks through it. **Verified:** this is how the VPC behaved before we added the custom route table.

> **Q2.** Route `0.0.0.0/0 → IGW` exists but EC2-A has no public IP — can it reach `8.8.8.8`?
>
> **Answer: No.** The IGW performs 1:1 NAT. Without a public IP to rewrite the source to, the IGW can't translate the outbound packet. The internet can't route responses back to a private `10.x.x.x` address.

> **Q3.** EC2-A has public IP + route. `curl ifconfig.me` reports which IP?
>
> **Answer: Public IP (44.195.62.23).** The IGW rewrites source `10.0.1.77` → `44.195.62.23` on the way out. ifconfig.me sees the public IP and reports it. The instance itself never knows — `ip addr` only shows `10.0.1.77`. **Verified:** `curl ifconfig.me` returned `44.195.62.23`, `ip addr show ens5` showed only `10.0.1.77/24`.

> **Q4.** Three things for inbound SYN + three for outbound SYN-ACK?
>
> **Inbound (SYN):**
> 1. EC2-A has a public IP (so IGW can translate destination)
> 2. NACL allows inbound TCP/22
> 3. SG allows inbound TCP/22 from your IP
>
> **Outbound (SYN-ACK):**
> 1. Route table has `0.0.0.0/0 → IGW` (so VPC router can forward response)
> 2. NACL allows outbound ephemeral ports (stateless — must allow explicitly)
> 3. SG auto-allows (stateful — return traffic is free)

> **Q5.** Remove route while SSH'd in — session survives?
>
> **Answer: Session freezes, then dies.** The VPC router has no route for return traffic → packets dropped → one-way glass. TCP retransmits for ~30-60s, then gives up. NOT stateful — the IGW doesn't "remember" connections. **Verified:** session froze immediately, recovered when route was restored before TCP timeout.

> **Q6.** Subnet A public, subnet B untouched. EC2-B internet / EC2-A / laptop SSH?
>
> **Answer: No / Yes / No.**
> - Internet: No — subnet B's route table has no `0.0.0.0/0` route
> - EC2-A: Yes — `10.0.0.0/16 → local` still works both ways
> - Laptop SSH: No — even with a public IP, without an IGW route in B's route table, return traffic can't reach the IGW
>
> **Verified:** `ping 8.8.8.8` from EC2-B → 100% loss. `ping 10.0.1.77` from EC2-B → 3/3 received. `yum install` hung (no internet for package repos).

### The IGW NAT diagram

```
  OUTBOUND (curl ifconfig.me from EC2-A):
  
  EC2-A kernel          VPC router           IGW                  Internet
  ──────────            ──────────           ───                  ────────
  src: 10.0.1.77        "0.0.0.0/0?          "10.0.1.77 owns      ifconfig.me
  dst: 93.184.x.x  ──>  route says    ──>    public IP            sees src
                         send to IGW"         44.195.62.23.   ──> 44.195.62.23
                                              Rewrite src."

  INBOUND (response comes back):
  
  Internet              IGW                  VPC router           EC2-A kernel
  ────────              ───                  ──────────           ──────────
  dst: 44.195.62.23     "44.195.62.23        "10.0.1.77?          receives
                   ──>   maps to       ──>    10.0.1.0/24    ──> response
                         10.0.1.77.           is local. 
                         Rewrite dst."        Deliver."
```

### The break/fix proof — route removal kills SSH

```
  BEFORE (route present):
  
  EC2-A ──response──> VPC router ──0.0.0.0/0──> IGW ──NAT──> laptop
                                    ✅ match                    ✅ received
  
  AFTER (route deleted):
  
  EC2-A ──response──> VPC router ──0.0.0.0/0──> ???
                                    ❌ no match
                                    packet dropped
  
  laptop ──keystrokes──> IGW ──> EC2-A     (inbound still works!)
  EC2-A ──response──> VPC router ──> DROP   (outbound broken)
  
  Result: one-way glass. Session freezes.
  
  RESTORED (route re-added):
  
  TCP retransmits queued up during outage → flush through → session resumes
```

### The jump host pattern

```
  Laptop                      EC2-A (public)              EC2-B (private)
  ──────                      ──────────────              ───────────────
  ssh -J ec2-user@            "Forward this               "SSH connection
       44.195.62.23    ──>     SSH connection     ──>      from 10.0.1.77"
       ec2-user@               to 10.0.2.190"              
       10.0.2.190                                         ✅ SG allows SSH
                              Acts as jump host            from public SG
  Keys stay on laptop.        (like a relay)
  No keys copied to EC2-A.
```

The `-J` flag creates a ProxyJump — your laptop opens an SSH channel through EC2-A, then opens a second SSH channel inside that tunnel to EC2-B. EC2-B's SG uses a SG-to-SG reference: "allow SSH from whoever wears the `lab02-public-sg`." This is the manual precursor to a bastion host.

### New mental models from Lab 2

### 7. The "three pillars" of public internet access

```
  ┌─ IGW attached to VPC           "the door exists"         ──┐
  │                                                            │  ALL
  ├─ Route: 0.0.0.0/0 → IGW       "sign pointing to door"    │  THREE
  │                                                            │  required
  └─ Public IP on instance         "return address on packet" ──┘
```

Remove any one and connectivity breaks. Lab 1 had zero of these. Lab 2 gives all three to subnet A and zero to subnet B.

### 8. The IGW is a stateless NAT, not a stateful firewall

It translates IPs (public <-> private) on every packet independently. It doesn't "remember" connections. If the route to the IGW disappears, return traffic dies — even for established TCP sessions.

### 9. Subnets aren't intrinsically public or private

The same subnet becomes public or private based solely on its **route table**. There's no checkbox. It's just: does the route table have `0.0.0.0/0 → IGW`?

---

## Lab 3 — Private Subnet + NAT Gateway

### The central claim

> A NAT Gateway gives private-subnet instances outbound internet access (yum install, curl, DNS) while blocking all inbound from the internet. It's a one-way valve that lives in the public subnet.

### Architecture deployed

```
                              AWS account 382884104985
   ┌──────────────────────────────────────────────────────────────────────┐
   │                                                                      │
   │   VPC: lab03-vpc   (10.0.0.0/16)                                      │
   │                                                                      │
   │   ┌──── Internet Gateway (lab03-igw) ────┐                            │
   │   │                                      │                            │
   │   └──────────────┬───────────────────────┘                            │
   │                  │                                                    │
   │   ┌──────────────┼──────────────────────────────────────────────┐    │
   │   │              ▼                                              │    │
   │   │   Public Subnet (10.0.1.0/24, us-east-1a)                    │    │
   │   │   RT: 0.0.0.0/0 → IGW                                       │    │
   │   │                                                             │    │
   │   │   ┌──────────────────┐    ┌───────────────────────────┐     │    │
   │   │   │  EC2-public      │    │  NAT Gateway              │     │    │
   │   │   │  10.0.1.153      │    │  EIP: 44.194.162.244      │     │    │
   │   │   │  pub: 98.80.x    │    │                           │     │    │
   │   │   └──────────────────┘    │  Receives traffic from    │     │    │
   │   │                           │  private subnet, rewrites │     │    │
   │   │                           │  src IP to its EIP, then  │     │    │
   │   │                           │  forwards through IGW     │     │    │
   │   │                           └─────────▲─────────────────┘     │    │
   │   │                                     │                       │    │
   │   ├─────────────────────────────────────┼───────────────────────┤    │
   │   │                                     │                       │    │
   │   │   Private Subnet (10.0.2.0/24, us-east-1b)                  │    │
   │   │   RT: 0.0.0.0/0 → nat-xxx    ◄──── POINTS UP TO NAT GW     │    │
   │   │       10.0.0.0/16 → local                                   │    │
   │   │                                                             │    │
   │   │   ┌──────────────────┐                                      │    │
   │   │   │  EC2-private     │                                      │    │
   │   │   │  10.0.2.236      │                                      │    │
   │   │   │  NO public IP    │                                      │    │
   │   │   └──────────────────┘                                      │    │
   │   │                                                             │    │
   │   └─────────────────────────────────────────────────────────────┘    │
   └──────────────────────────────────────────────────────────────────────┘
```

### The double-NAT chain

```
  EC2-B (private)         NAT Gateway              IGW               Internet
  ─────────────          ───────────              ───               ────────
  
  OUTBOUND:
  src: 10.0.2.236        "Rewrite src to         "EIP is already    ifconfig.me
  dst: 93.184.x.x  ──>   my EIP                  public — no  ──> sees src
                          44.194.162.244.    ──>   translation       44.194.162.244
                          Remember this            needed."
                          connection."

  INBOUND (return):
  dst: 44.194.162.244    "That's my EIP.         "44.194.162.244
                    ◄──   I have a mapping  ◄──   is in this   ◄── response
                          for this flow.          VPC. Route
                          Rewrite dst to          to NAT GW."
                          10.0.2.236."
```

### Behavioral tests — Lab 2 vs Lab 3 comparison

| Test from EC2-B | Lab 2 (no NAT) | Lab 3 (with NAT) |
|---|---|---|
| `curl ifconfig.me` | timeout | `44.194.162.244` (NAT EIP) |
| `yum install tree` | hung forever | installed successfully |
| `ping 8.8.8.8` | 100% loss | 3/3 received |
| `ping 10.0.1.x` (EC2-A) | 3/3 received | 3/3 received |

### Break/fix results

| Test | Route deleted | Route restored |
|---|---|---|
| `curl ifconfig.me` | timeout | `44.194.162.244` |
| `ping 10.0.1.153` | ✅ works (local route) | ✅ works |

Same pattern as Labs 1 and 2: removing `0.0.0.0/0` kills internet but `local` route is untouchable.

### Resources created (21 total)

New pieces beyond Lab 2:

| Resource | Purpose |
|---|---|
| `aws_eip` | Public IP for NAT Gateway |
| `aws_nat_gateway` | One-way valve in public subnet |
| `aws_route_table` (private) | `0.0.0.0/0 → nat-xxx` for private subnet |
| `aws_route_table_association` (private) | Associates private subnet with its RT |

### New mental models from Lab 3

### 10. NAT Gateway = one-way valve

```
  Internet ──X──> NAT GW    (inbound initiated connections: BLOCKED)
  
  EC2-B ──────> NAT GW ──> IGW ──> Internet    (outbound: ALLOWED)
  Internet ──> IGW ──> NAT GW ──> EC2-B        (return traffic: ALLOWED)
                                                 (because NAT GW is stateful,
                                                  remembers the outbound flow)
```

Unlike the IGW (stateless translator), the NAT Gateway IS stateful — it tracks connections to map return traffic. But it only tracks connections initiated from inside.

### 11. NAT GW must live in a public subnet

The NAT GW needs to reach the internet itself (via IGW). If it were in the private subnet, it would have the same problem as the instances it's trying to help — no route out.

```
  ┌─ NAT GW in public subnet ──> has IGW route ──> can forward to internet ✅
  └─ NAT GW in private subnet ──> no IGW route ──> stuck ❌
```

### 12. Two route tables, two personalities, one VPC

```
  Public RT:    10.0.0.0/16 → local    +    0.0.0.0/0 → IGW        (direct internet)
  Private RT:   10.0.0.0/16 → local    +    0.0.0.0/0 → NAT GW    (NAT'd internet)
```

Both share `local` (intra-VPC always works). They differ only in where `0.0.0.0/0` points. That single row is the entire personality difference between "public" and "private."

### 13. Cost awareness: NAT GW is the first resource that costs real money

| Resource | Cost |
|---|---|
| NAT Gateway | $0.045/hr = $32/mo |
| Data processing | $0.045/GB through NAT |
| EIP (while attached) | free |
| EIP (unattached) | $0.005/hr |

Cheaper alternative: NAT instance (t3.nano ~$3.50/mo) with source/dest check disabled. Tradeoff: you manage HA, patching, scaling yourself.

---

## Lab 4 — Security Groups vs NACLs

### The central claim

> SGs are stateful (return traffic auto-allowed). NACLs are stateless (every packet evaluated independently). NACLs sit at the subnet boundary OUTSIDE the SG. A NACL deny overrides a SG allow.

### Architecture deployed

```
                           Internet
                              │
                              ▼
                     ┌──── IGW ────┐
                     └──────┬──────┘
                            │
   ┌────────────────────────┼────────────────────────────────┐
   │  Subnet (10.0.1.0/24)  │                                │
   │                        │                                │
   │  ┌──── NACL ───────────┼──────────────────────────┐     │
   │  │  (subnet boundary)  │                          │     │
   │  │                     ▼                          │     │
   │  │  ┌──── Security Group ──────────────────┐      │     │
   │  │  │  (instance boundary)                 │      │     │
   │  │  │                                      │      │     │
   │  │  │  ┌────────────────────────────────┐  │      │     │
   │  │  │  │  EC2 (lab04-ec2)               │  │      │     │
   │  │  │  │  10.0.1.218                    │  │      │     │
   │  │  │  │  pub: 100.24.119.63            │  │      │     │
   │  │  │  └────────────────────────────────┘  │      │     │
   │  │  │                                      │      │     │
   │  │  └──────────────────────────────────────┘      │     │
   │  │                                                │     │
   │  └────────────────────────────────────────────────┘     │
   └─────────────────────────────────────────────────────────┘
```

### Experiment 1 — SG egress removed (stateful proof)

```
  Removed: SG "all egress" rule
  Kept:    NACL allow-all both directions
  
  SSH session:    ✅ SURVIVED (SG remembered the inbound connection)
  curl ifconfig:  ❌ HUNG (new outbound connection, no egress rule)
```

Stateful means: "I remember who started the conversation. If you came in on an allowed rule, your replies go free." But NEW outbound conversations still need an egress rule.

```
  SSH (inbound-initiated):              curl (outbound-initiated):
  
  Laptop ──SYN──> SG ingress ✅         EC2 ──SYN──> SG egress ❌
  EC2 ──reply──> SG: "I remember        (no rule = blocked, stateful
                 this connection,         doesn't help here because
                 auto-allow" ✅           EC2 initiated it)
```

### Experiment 2 — NACL egress removed (stateless proof)

```
  Restored: SG "all egress" rule
  Removed:  NACL outbound rule 100
  
  SSH session:    ❌ FROZE (NACL killed return packets)
  Everything:     ❌ DEAD
```

The SG said "yes, return traffic, auto-allow." But the packet then hit the NACL at the subnet boundary — and the NACL has no memory, no state table, nothing. No outbound rule = implicit deny = packet dropped.

```
  SSH return packet's journey:
  
  EC2 sends reply
       │
       ▼
  SG egress: "all out? ✅"           ← SG says yes
       │
       ▼
  NACL outbound: "any rule?          ← NACL says no
                  rule 100? deleted.
                  implicit deny ❌"
       │
       ▼
  DROPPED. Never leaves the subnet.
```

### Packet evaluation order (proven)

```
  INBOUND:                          OUTBOUND:
  
  Internet                          EC2 instance
     │                                  │
     ▼                                  ▼
  1. NACL inbound  ──first──>       1. SG egress   ──first──>
     │                                  │
     ▼                                  ▼
  2. SG ingress    ──second──>      2. NACL outbound ──second──>
     │                                  │
     ▼                                  ▼
  EC2 instance                      Internet
  
  Packet must pass BOTH layers in BOTH directions.
  NACL wraps the subnet. SG wraps the instance.
```

### New mental models from Lab 4

### 14. SG stateful ≠ "all outbound works"

Stateful only auto-allows RETURN traffic for allowed inbound connections. New outbound connections still need an egress rule. This is the nuance engineers miss.

### 15. NACL can override SG

Even when the SG says "allow," the NACL can drop the packet. The NACL is the outer wall — if it blocks, nothing gets through regardless of SG rules.

### 16. NACLs exist for one reason: DENY rules

SGs can only ALLOW. If you need to block a specific IP, port range, or pattern, you need a NACL. Use case: blocking a known-bad IP (`Rule 50: DENY from 203.0.113.50`) before the ALLOW-all rule.

### 17. NACL rule number = priority

Lowest number evaluated first. First match wins, evaluation stops. A DENY at rule 50 beats an ALLOW at rule 100 — the ALLOW is never reached.

```
  Rule 50:  DENY tcp/22    ← wins (evaluated first)
  Rule 100: ALLOW tcp/22   ← never reached
  Rule *:   DENY all       ← implicit, can't delete
```

---

## Lab 5 — Application Load Balancer

### The central claim

> An ALB distributes HTTP traffic across targets in multiple AZs, health-checks them automatically, and routes around failures — all using the same networking primitives from Labs 1-4.

### Architecture deployed

```
  Internet
     │
     ▼
  ALB (lab05-alb)
  ├── public-subnet-1 (10.0.1.0/24, us-east-1a)
  └── public-subnet-2 (10.0.2.0/24, us-east-1b)
       │
       │  SG-to-SG: tcp/80 from lab05-alb-sg
       │  local route (same VPC)
       ▼
  Target Group (lab05-targets)
  ├── EC2 target-1 (10.0.10.212, private-subnet-1, us-east-1a) → nginx
  └── EC2 target-2 (10.0.11.173, private-subnet-2, us-east-1b) → nginx
       │
       │  0.0.0.0/0 → NAT GW (for yum install nginx)
       ▼
  NAT Gateway → IGW → Internet
```

### Behavioral tests

| Test | Result |
|---|---|
| `curl alb-url` (first) | target-2: i-07e... AZ us-east-1b |
| `curl alb-url` (second) | target-1: i-001... AZ us-east-1a |
| Stop nginx on target-1 | ALB detected failure in ~20s |
| `curl alb-url` x4 after | ALL hit target-2 only |

### Terraform patterns introduced

**`count` + `cidrsubnet()`** — dynamic subnet creation:
```
cidrsubnet("10.0.0.0/16", 8, 1)  → 10.0.1.0/24
cidrsubnet("10.0.0.0/16", 8, 10) → 10.0.10.0/24
```

**`user_data`** — bootstrap script that runs once at instance launch (installs nginx, writes HTML).

**Self-referencing SG** — bastion and targets share the same SG; a self-ref rule allows SSH between them.

### Gotcha: bastion SSH jump failed

The target SG allowed SSH from the operator's public IP, but the bastion-to-target connection uses the bastion's private IP. Fixed with a self-referencing SG rule: "allow SSH from anyone wearing this same SG."

### New mental models from Lab 5

### 18. ALB = fleet of nodes behind a DNS name

Not a single machine. AWS scales the fleet up/down based on traffic. That's why you get a DNS name, not a static IP — the IPs can change as nodes are added/removed.

### 19. Health checks are the ALB's eyes

Without health checks, the ALB blindly sends traffic to dead targets (502s). Health checks let it detect failures and route around them — but there's always a detection delay (interval x unhealthy threshold).

### 20. Everything from Labs 1-4 combined

The ALB lab used every concept so far:
- VPC + subnets (Lab 1)
- IGW + public route table (Lab 2)
- NAT Gateway for private egress (Lab 3)
- SG-to-SG references (Lab 1 EICE, now ALB→target)
- Multiple AZs for redundancy

---

## Cumulative cost

| Lab | $ spent | Time alive |
|---|---|---|
| Lab 0 | $0 | n/a |
| Lab 1 | $0 (free tier) | ~30 min |
| Lab 2 | $0 (free tier) | ~45 min |
| Lab 3 | ~$0.01 (NAT GW) | ~15 min |
| Lab 4 | $0 (free tier) | ~20 min |
| Lab 5 | ~$0.03 (ALB + NAT) | ~30 min |
| **Total** | **~$0.04** | — |

---

*Last updated: 2026-05-10 — after Lab 5 destroy.*
