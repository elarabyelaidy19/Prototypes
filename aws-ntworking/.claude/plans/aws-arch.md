# AWS Cloud Networking — Complete Architecture

A single HTTP request touching every component we built across Labs 1-5.

---

## The Full Stack

```mermaid
graph TB
    subgraph Internet
        USER[User Browser<br/>Cairo, Egypt]
        DNS[DNS Resolution<br/>lab05-alb-xxx.elb.amazonaws.com<br/>→ 52.20.x.x, 54.85.x.x]
    end

    subgraph VPC["VPC: 10.0.0.0/16"]
        IGW[Internet Gateway<br/>lab05-igw]

        subgraph PUB["Public Subnets"]
            subgraph PUB1["Public Subnet 1<br/>10.0.1.0/24 · us-east-1a"]
                ALB1[ALB Node 1<br/>SG: lab05-alb-sg]
                NAT[NAT Gateway<br/>EIP: 44.194.x.x]
                BASTION[Bastion Host<br/>Public IP: 44.214.x.x]
            end
            subgraph PUB2["Public Subnet 2<br/>10.0.2.0/24 · us-east-1b"]
                ALB2[ALB Node 2<br/>SG: lab05-alb-sg]
            end
        end

        subgraph PRIV["Private Subnets"]
            subgraph PRIV1["Private Subnet 1<br/>10.0.10.0/24 · us-east-1a"]
                EC2A[EC2 Target 1<br/>nginx :80<br/>10.0.10.212<br/>SG: lab05-target-sg]
            end
            subgraph PRIV2["Private Subnet 2<br/>10.0.11.0/24 · us-east-1b"]
                EC2B[EC2 Target 2<br/>nginx :80<br/>10.0.11.173<br/>SG: lab05-target-sg]
            end
        end

        TG[Target Group<br/>lab05-targets<br/>Health: GET / every 10s]
    end

    USER -->|1. DNS lookup| DNS
    DNS -->|2. HTTP GET /| IGW
    IGW -->|3. Route to ALB| ALB1
    IGW -->|3. Route to ALB| ALB2
    ALB1 -->|4. Forward| TG
    ALB2 -->|4. Forward| TG
    TG -->|5. Round-robin| EC2A
    TG -->|5. Round-robin| EC2B
    EC2A -->|outbound| NAT
    EC2B -->|outbound| NAT
    NAT -->|egress| IGW

    style IGW fill:#f9a825,stroke:#f57f17,color:#000
    style NAT fill:#66bb6a,stroke:#2e7d32,color:#000
    style ALB1 fill:#42a5f5,stroke:#1565c0,color:#000
    style ALB2 fill:#42a5f5,stroke:#1565c0,color:#000
    style EC2A fill:#ef5350,stroke:#c62828,color:#fff
    style EC2B fill:#ef5350,stroke:#c62828,color:#fff
    style TG fill:#ab47bc,stroke:#6a1b9a,color:#fff
    style BASTION fill:#78909c,stroke:#37474f,color:#fff
```

---

## Component Inventory

```mermaid
graph LR
    subgraph "Lab 1: Foundation"
        VPC[VPC<br/>IP range + router]
        SUB[Subnets<br/>AZ-pinned slices]
        RT_LOCAL[Route: local<br/>intra-VPC traffic]
    end

    subgraph "Lab 2: Internet Access"
        IGW2[Internet Gateway<br/>VPC ↔ Internet bridge]
        RT_IGW[Route: 0.0.0.0/0 → IGW]
        PUB_IP[Public IP<br/>IGW NAT: private ↔ public]
    end

    subgraph "Lab 3: Private Egress"
        NAT2[NAT Gateway<br/>One-way valve]
        EIP[Elastic IP<br/>Stable public addr for NAT]
        RT_NAT[Route: 0.0.0.0/0 → NAT]
    end

    subgraph "Lab 4: Firewalls"
        SG[Security Group<br/>Stateful, allow-only]
        NACL[NACL<br/>Stateless, allow+deny]
    end

    subgraph "Lab 5: Load Balancing"
        ALB[ALB<br/>HTTP distribution]
        TG2[Target Group<br/>Health-checked pool]
        LISTENER[Listener<br/>Port 80 → forward]
    end

    VPC --> SUB --> RT_LOCAL
    RT_LOCAL --> IGW2 --> RT_IGW --> PUB_IP
    PUB_IP --> NAT2 --> EIP --> RT_NAT
    RT_NAT --> SG --> NACL
    NACL --> ALB --> LISTENER --> TG2

    style VPC fill:#e3f2fd,stroke:#1565c0
    style IGW2 fill:#fff3e0,stroke:#e65100
    style NAT2 fill:#e8f5e9,stroke:#2e7d32
    style SG fill:#fce4ec,stroke:#c62828
    style ALB fill:#e8eaf6,stroke:#283593
```

---

## A Single HTTP Request — Step by Step

```mermaid
sequenceDiagram
    participant B as Browser
    participant DNS as DNS
    participant IGW as Internet Gateway
    participant NACL as NACL (subnet)
    participant ALB as ALB
    participant SG_ALB as ALB Security Group
    participant SG_TGT as Target Security Group
    participant EC2 as EC2 Target (nginx)

    Note over B: User types URL in browser

    B->>DNS: 1. Resolve lab05-alb-xxx.elb.amazonaws.com
    DNS-->>B: 52.20.x.x (ALB node IP)

    B->>IGW: 2. TCP SYN → 52.20.x.x:80
    Note over IGW: IGW translates public IP<br/>to ALB's internal address

    IGW->>NACL: 3. Forward into VPC
    Note over NACL: Rule 100: ALLOW ALL inbound ✅<br/>(stateless — checks every packet)

    NACL->>SG_ALB: 4. Packet reaches ALB's ENI
    Note over SG_ALB: Ingress: tcp/80 from 0.0.0.0/0 ✅<br/>Adds to state table

    SG_ALB->>ALB: 5. Packet delivered to ALB

    Note over ALB: Listener: port 80 → forward<br/>to target group lab05-targets<br/><br/>Pick healthy target<br/>(round-robin: Target 2 this time)

    ALB->>SG_TGT: 6. Forward to 10.0.11.173:80
    Note over SG_TGT: Ingress: tcp/80 from lab05-alb-sg?<br/>Is source wearing that SG? YES ✅

    SG_TGT->>EC2: 7. Packet delivered to nginx

    Note over EC2: nginx processes GET /<br/>Returns HTML:<br/>"Instance: i-07e... AZ: us-east-1b"

    EC2->>SG_TGT: 8. Response (SG: stateful auto-allow ✅)
    SG_TGT->>ALB: 9. Response reaches ALB
    ALB->>SG_ALB: 10. ALB forwards response
    SG_ALB->>NACL: 11. (SG: stateful auto-allow ✅)
    NACL->>IGW: 12. (NACL: Rule 100 ALLOW ALL outbound ✅)
    Note over IGW: NAT: rewrite source<br/>from internal → public IP
    IGW-->>B: 13. HTTP 200 OK + HTML

    Note over B: Browser renders:<br/>"Lab 05 - ALB Target<br/>Instance: i-07e...<br/>AZ: us-east-1b"
```

---

## Route Tables — The Decision Engine

```mermaid
graph TB
    PACKET[Outbound Packet<br/>dst: 93.184.216.34]

    subgraph "VPC Router evaluates destination"
        CHECK1{"Match<br/>10.0.0.0/16?"}
        CHECK2{"Match<br/>0.0.0.0/0?"}
        DROP[DROP<br/>No matching route]
    end

    LOCAL[local<br/>Deliver within VPC]
    IGW_R[IGW<br/>Send to internet]
    NAT_R[NAT GW<br/>NAT then internet]

    PACKET --> CHECK1
    CHECK1 -->|Yes| LOCAL
    CHECK1 -->|No| CHECK2
    CHECK2 -->|"Public subnet<br/>→ IGW"| IGW_R
    CHECK2 -->|"Private subnet<br/>→ NAT GW"| NAT_R
    CHECK2 -->|"No route<br/>(Lab 1 island)"| DROP

    style LOCAL fill:#c8e6c9,stroke:#2e7d32
    style IGW_R fill:#fff3e0,stroke:#e65100
    style NAT_R fill:#e8f5e9,stroke:#2e7d32
    style DROP fill:#ffcdd2,stroke:#c62828
```

### Three subnet personalities from the same VPC

```mermaid
graph LR
    subgraph "Public Subnet (Lab 2)"
        PRT["10.0.0.0/16 → local<br/>0.0.0.0/0 → IGW"]
    end

    subgraph "Private Subnet (Lab 3)"
        PVRT["10.0.0.0/16 → local<br/>0.0.0.0/0 → NAT GW"]
    end

    subgraph "Island Subnet (Lab 1)"
        IRT["10.0.0.0/16 → local<br/>(no other routes)"]
    end

    PRT -->|"Direct internet<br/>in + out"| INET1[Internet]
    PVRT -->|"Outbound only<br/>via NAT"| INET2[Internet]
    IRT -->|"No internet<br/>at all"| NONE[Nowhere]

    style PRT fill:#c8e6c9,stroke:#2e7d32
    style PVRT fill:#fff9c4,stroke:#f9a825
    style IRT fill:#ffcdd2,stroke:#c62828
    style NONE fill:#ffcdd2,stroke:#c62828
```

---

## Security Layers — Packet Gauntlet

```mermaid
graph TB
    subgraph "INBOUND (internet → instance)"
        direction TB
        IN_PKT[Packet arrives] --> IN_NACL
        IN_NACL["1. NACL Inbound<br/>Stateless<br/>Rule number order<br/>Can DENY"] --> IN_SG
        IN_SG["2. Security Group Ingress<br/>Stateful<br/>All rules checked<br/>Allow-only"] --> IN_EC2[Instance receives]
    end

    subgraph "OUTBOUND (instance → internet)"
        direction TB
        OUT_EC2[Instance sends] --> OUT_SG
        OUT_SG["1. Security Group Egress<br/>Stateful<br/>Return traffic auto-allowed"] --> OUT_NACL
        OUT_NACL["2. NACL Outbound<br/>Stateless<br/>Must allow explicitly<br/>Even for return traffic"] --> OUT_PKT[Packet leaves]
    end

    style IN_NACL fill:#fff3e0,stroke:#e65100
    style IN_SG fill:#e8f5e9,stroke:#2e7d32
    style OUT_SG fill:#e8f5e9,stroke:#2e7d32
    style OUT_NACL fill:#fff3e0,stroke:#e65100
```

### What we proved empirically

```mermaid
graph LR
    subgraph "Lab 4 Experiment 1"
        E1_SG["SG egress removed"] --> E1_SSH["SSH: ✅ survived<br/>(stateful return)"]
        E1_SG --> E1_CURL["curl: ❌ hung<br/>(new outbound blocked)"]
    end

    subgraph "Lab 4 Experiment 2"
        E2_NACL["NACL outbound removed"] --> E2_SSH["SSH: ❌ froze<br/>(stateless, no return)"]
        E2_NACL --> E2_ALL["Everything: ❌ dead"]
    end

    style E1_SSH fill:#c8e6c9,stroke:#2e7d32
    style E1_CURL fill:#ffcdd2,stroke:#c62828
    style E2_SSH fill:#ffcdd2,stroke:#c62828
    style E2_ALL fill:#ffcdd2,stroke:#c62828
```

---

## NAT Chain — Private Instance Reaching Internet

```mermaid
sequenceDiagram
    participant EC2 as EC2 Private<br/>10.0.10.212
    participant VPC as VPC Router
    participant NAT as NAT Gateway<br/>EIP: 44.194.162.244
    participant IGW as Internet Gateway
    participant WEB as ifconfig.me

    EC2->>VPC: src: 10.0.10.212<br/>dst: 93.184.x.x
    Note over VPC: Route table:<br/>0.0.0.0/0 → NAT GW

    VPC->>NAT: Forward to NAT Gateway
    Note over NAT: SNAT: rewrite src<br/>10.0.10.212 → 44.194.162.244<br/>Remember mapping

    NAT->>IGW: src: 44.194.162.244<br/>dst: 93.184.x.x
    Note over IGW: EIP is already public<br/>No translation needed

    IGW->>WEB: Packet reaches internet
    WEB-->>IGW: Response to 44.194.162.244

    IGW-->>NAT: Forward to NAT GW
    Note over NAT: DNAT: rewrite dst<br/>44.194.162.244 → 10.0.10.212<br/>Using remembered mapping

    NAT-->>VPC: dst: 10.0.10.212
    Note over VPC: 10.0.10.0/24 → local

    VPC-->>EC2: Delivered

    Note over EC2: curl ifconfig.me<br/>returns: 44.194.162.244<br/>(NAT GW's EIP, not mine)
```

---

## ALB Health Check & Failover

```mermaid
sequenceDiagram
    participant ALB as ALB
    participant T1 as Target 1<br/>10.0.10.212
    participant T2 as Target 2<br/>10.0.11.173

    Note over ALB: Normal operation: round-robin

    ALB->>T1: Health check: GET /
    T1-->>ALB: 200 OK ✅
    ALB->>T2: Health check: GET /
    T2-->>ALB: 200 OK ✅

    ALB->>T1: User request → Target 1
    ALB->>T2: User request → Target 2

    Note over T1: nginx crashes!

    ALB->>T1: Health check: GET /
    T1--xALB: Connection refused ❌ (strike 1/2)

    Note over ALB: Still sending traffic to T1<br/>Users get 502 Bad Gateway

    ALB->>T1: Health check: GET /
    T1--xALB: Connection refused ❌ (strike 2/2)

    Note over ALB: Target 1 marked UNHEALTHY<br/>Removed from rotation

    ALB->>T2: ALL traffic → Target 2 only
    ALB->>T2: ALL traffic → Target 2 only
    ALB->>T2: ALL traffic → Target 2 only

    Note over ALB: 503 if ALL targets unhealthy<br/>502 during detection window
```

---

## SG-to-SG References — Identity-Based Security

```mermaid
graph LR
    subgraph "Instead of IP-based (fragile)"
        BAD_RULE["Allow tcp/80<br/>from 10.0.1.42/32"] -->|"Breaks if<br/>IP changes"| BAD[❌]
    end

    subgraph "Use SG-based (durable)"
        GOOD_RULE["Allow tcp/80<br/>from sg-alb-xxx"] -->|"Works regardless<br/>of IP"| GOOD[✅]
    end

    subgraph "Who used this pattern"
        L1["Lab 1: EICE → Instance"]
        L5A["Lab 5: ALB → Targets"]
        L5B["Lab 5: Bastion → Targets (self-ref)"]
    end

    style BAD fill:#ffcdd2,stroke:#c62828
    style GOOD fill:#c8e6c9,stroke:#2e7d32
```

---

## Evolution Across Labs

```mermaid
graph TB
    subgraph "Lab 1 — Island"
        L1[VPC + 2 Subnets<br/>Route: local only<br/>No internet at all]
    end

    subgraph "Lab 2 — Bridge"
        L2[+ IGW<br/>+ Public route table<br/>+ Public IP<br/>Direct internet access]
    end

    subgraph "Lab 3 — Valve"
        L3[+ NAT Gateway<br/>+ Private route table<br/>Outbound-only internet]
    end

    subgraph "Lab 4 — Walls"
        L4[+ Custom NACL<br/>SG stateful vs NACL stateless<br/>Deny capability]
    end

    subgraph "Lab 5 — Load Balancer"
        L5[+ ALB + Target Group<br/>+ Health Checks<br/>+ Multi-AZ redundancy<br/>+ Bastion jump host]
    end

    L1 -->|"Add one<br/>route table row"| L2
    L2 -->|"Add NAT GW<br/>in public subnet"| L3
    L3 -->|"Add NACL<br/>rules"| L4
    L4 -->|"Add ALB<br/>in front"| L5

    style L1 fill:#ffcdd2,stroke:#c62828
    style L2 fill:#fff9c4,stroke:#f9a825
    style L3 fill:#c8e6c9,stroke:#2e7d32
    style L4 fill:#e8eaf6,stroke:#283593
    style L5 fill:#e1f5fe,stroke:#0277bd
```

---

## Quick Reference — What Lives Where

```mermaid
graph TB
    subgraph "VPC Level (one per VPC)"
        IGW_REF[Internet Gateway]
        NACL_REF[NACLs]
        SG_REF[Security Groups]
        RT_REF[Route Tables]
    end

    subgraph "Subnet Level (per subnet)"
        RT_ASSOC[Route Table Association<br/>1 RT per subnet]
        NACL_ASSOC[NACL Association<br/>1 NACL per subnet]
        NAT_REF[NAT Gateway<br/>lives in a specific subnet]
    end

    subgraph "Instance Level (per ENI)"
        SG_ATTACH[SG Attachment<br/>multiple SGs per instance]
        PUB_IP_REF[Public IP<br/>per instance, optional]
    end

    subgraph "Multi-Subnet (spans AZs)"
        ALB_REF[ALB<br/>requires 2+ subnets]
        TG_REF[Target Group<br/>targets across subnets]
    end

    style IGW_REF fill:#fff3e0,stroke:#e65100
    style NAT_REF fill:#e8f5e9,stroke:#2e7d32
    style SG_ATTACH fill:#fce4ec,stroke:#c62828
    style ALB_REF fill:#e8eaf6,stroke:#283593
```

---

## The One Rule That Explains Everything

Every networking behavior we observed comes down to the **route table**:

| Route Table Entry | What It Enables | Lab |
|---|---|---|
| `10.0.0.0/16 → local` | Intra-VPC traffic (always present) | Lab 1 |
| `0.0.0.0/0 → igw-xxx` | Direct internet (public subnet) | Lab 2 |
| `0.0.0.0/0 → nat-xxx` | NAT'd internet (private subnet) | Lab 3 |
| (no 0.0.0.0/0 route) | No internet at all (island) | Lab 1 |

Routes decide **where packets go**. SGs/NACLs decide **if packets are allowed**. Both must say yes.

```
Connectivity = Route (path exists) + Permission (SG/NACL allow) + Reachability (target alive)
```
