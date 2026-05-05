# AWS Cloud Networking — Hands-On Labs

**Goal:** Build cloud networking intuition by deploying a Rails 8 app to AWS, one networking primitive at a time.

**Approach:** `predict → build → verify → break → fix` for every lab.

**Strategy:** Hybrid — LocalStack for fast iteration on Labs 1–4 (free), real AWS from Lab 5 (free tier + tight budget alarms).

---

## Lab 0 — Setup & Safety Rails

Goal: Make it safe to experiment without surprise bills or blast-radius incidents.

- [ ] Create an IAM user (`networking-lab`) with an Admin policy attached; generate access keys
- [ ] Configure AWS CLI profile `lab` with the new keys
- [ ] **Stop using root credentials** for the rest of this practice
- [ ] Enable MFA on the root account
- [ ] Set up **AWS Budgets** alarm at $5 and $10 (email)
- [ ] Set up **CloudWatch Billing alarm** ($1, $5)
- [ ] Install Terraform (≥1.6)
- [ ] Install LocalStack (Docker) + `tflocal` wrapper
- [ ] Pick AWS region — recommend `us-east-1` (cheapest, most services)
- [ ] Create `infra/` directory in repo with `terraform/` and `scripts/` subdirs
- [ ] `terraform init` smoke test against LocalStack

**Success criteria:** `aws --profile lab sts get-caller-identity` returns IAM user (not root). `tflocal init` succeeds. Budget alarm visible in console.

---

## Lab 1 — VPC + Subnets (Islands, no internet)

**Concept:** A VPC is just an IP range. Subnets carve that range, each pinned to one AZ. Without gateways, subnets are isolated islands.

**Predict:**
- VPC `10.0.0.0/16` → how many IPs?
- Subnet `10.0.1.0/24` → how many *usable* IPs (AWS reserves 5)?
- EC2 in subnet, no IGW — can your laptop SSH in?
- Same EC2 — can it reach `8.8.8.8`?
- Same EC2 — can it reach a peer in `10.0.2.0/24` same VPC?

**Build:** VPC + 2 subnets (different AZs) + 2 t3.micro EC2s.

**Verify:** From inside one EC2 (via Session Manager), ping the peer's private IP. Try `curl https://google.com` — fails (good).

**Break:** Change subnet 2 CIDR to `10.1.2.0/24` (outside VPC range). Read the error.

**Fix:** Restore CIDR. Bonus: try `10.0.1.128/25` overlapping with subnet 1 — read that error too.

---

## Lab 2 — Public Subnet (IGW + Route Tables)

**Concept:** An Internet Gateway is a VPC-level component. A subnet only becomes "public" when its route table has `0.0.0.0/0 → IGW`. Public IP is separate again.

**Predict:**
- Add IGW + route. Can EC2 (no public IP) reach internet? Why not?
- Assign public IP. Can it reach internet now? What about ingress from your laptop?
- Why did egress need both a route AND a public IP, but ingress also needs a Security Group rule?

**Build:** Convert subnet 1 to public (IGW + route + auto-assign public IP). Add SG allowing SSH from your IP.

**Verify:** SSH from laptop. `curl ifconfig.me` from EC2 returns its public IP.

**Break:** Remove the `0.0.0.0/0` route. SSH still works from laptop — *why?* (Stateful gateway + return path.) Now try `curl google.com` from inside.

**Fix + Concept lock:** Restore route. Diagram which packet went which direction.

---

## Lab 3 — Private Subnet + NAT Gateway

**Concept:** Private subnets need outbound internet (gem install, OS updates) but no inbound. NAT Gateway = a one-way valve in a public subnet.

**Predict:**
- EC2 in private subnet, no NAT yet — does `apt update` work?
- After NAT — does `apt update` work? Does ingress from internet work?
- Why does NAT live in a *public* subnet, not private?
- Cost: NAT Gateway is ~$0.045/hr ≈ $32/mo + data processing. When would you use a NAT *instance* (EC2) instead?

**Build:** NAT Gateway in public subnet, route in private subnet RT.

**Verify:** From private EC2 via SSM, run `curl ifconfig.me` — returns NAT's EIP, not the EC2's.

**Break:** Delete the route. Observe `curl` hang. Add it back.

---

## Lab 4 — Security Groups vs NACLs

**Concept:** SGs are stateful (allow-only, return traffic auto-allowed). NACLs are stateless (must explicitly allow both directions, evaluated by rule number).

**Predict:**
- SG allows SSH inbound from your IP, no outbound rules. Can SSH packets respond?
- (Default SG outbound is "allow all" — change it to "allow none". Now?)
- NACL allows SSH inbound but denies all outbound. Will SSH work?
- Order of evaluation: NACL first or SG first?

**Build:** Tighten SG (deny default outbound, allow only return + DNS). Add a permissive NACL. Then add a NACL rule that *denies* outbound 1024-65535 — observe the breakage.

**Verify + Break + Fix:** Use `tcpdump` or VPC Flow Logs to see what got dropped where.

---

## Lab 5 — Application Load Balancer (Real AWS from here)

**Concept:** ALB lives in ≥2 public subnets across AZs. Routes HTTP(S) to a target group. Target group health checks gate traffic.

**Predict:**
- ALB in 1 AZ — what does AWS say?
- Targets in private subnets, ALB in public — what allows ALB → target traffic? (SG referencing SG.)
- Health check fails — does ALB return 503 or 502?

**Build:** ALB in 2 public subnets, target group, 2 nginx EC2s in private subnets serving a tiny page. SG-from-SG reference.

**Verify:** Hit ALB DNS → see page. Stop nginx on one target → ALB drains it.

**Break:** Make health check path return 500. Watch CloudWatch + target group UI.

---

## Lab 6 — RDS Postgres in Private Subnets

**Concept:** RDS needs a *DB Subnet Group* (≥2 private subnets across AZs). Multi-AZ = synchronous standby in second AZ. Public access is a setting (default: off, keep it off).

**Predict:**
- Connect from EC2 in app subnet — works? What SG rule is needed?
- Connect from your laptop directly — works? Why not?
- Failover: how long does Multi-AZ failover take? What's the connection-string impact?

**Build:** `db.t4g.micro` (free tier eligible), Multi-AZ off (cost), DB subnet group, SG allowing 5432 from app SG only.

**Verify:** `psql` from app EC2. Confirm fail from laptop.

---

## Lab 7 — VPC Endpoints

**Concept:** Endpoints keep AWS-service traffic on AWS's backbone instead of via NAT/internet. **Gateway endpoints (S3, DynamoDB) are free.** Interface endpoints cost ~$7/mo each + data.

**Predict:**
- S3 upload from private EC2 today goes through... ? (NAT.)
- After gateway endpoint, route table changes how?
- Why is S3 a gateway endpoint but Secrets Manager an interface endpoint?

**Build:** S3 gateway endpoint. Secrets Manager interface endpoint (or skip to save $).

**Verify:** Watch NAT data-transfer drop after enabling. Inspect route table — see the `pl-xxx` prefix list.

---

## Lab 8 — VPC Peering (Optional advanced)

**Concept:** Two VPCs talk privately. CIDR ranges *must not overlap*. Both sides need routes. Transitive peering doesn't work (A→B→C does NOT mean A→C).

**Predict:**
- Two VPCs, `10.0.0.0/16` and `10.1.0.0/16`. Peer them. From an EC2 in VPC-A, can you ping an EC2 in VPC-B?
- What if both were `10.0.0.0/16`?
- Add VPC-C and peer it to VPC-B only — can A reach C?

---

## Lab 9 — Deploy this Rails app end-to-end

Bring it all together: ECS Fargate (or EC2+Kamal) in private subnets, ALB in public, RDS for Postgres + Solid Queue/Cache/Cable, S3 + endpoint for Active Storage, Secrets Manager for `RAILS_MASTER_KEY`, Route 53 + ACM for HTTPS, CloudWatch Logs.

Health check target: Rails 8's built-in `/up`.

---

## Cost Guardrails (running tally goal: <$10/mo)

| Resource | Cost | Mitigation |
|---|---|---|
| NAT Gateway | $32/mo | Destroy nightly via `terraform destroy` |
| ALB | $16/mo | Same |
| RDS db.t4g.micro | Free tier 750h/mo | Single AZ, stop when not in use |
| EC2 t3.micro | Free tier 750h/mo | Stop when not in use |
| Data transfer | Variable | Negligible at this scale |
| S3 / CloudWatch | Pennies | — |

**Golden rule:** End every session with `terraform destroy` on AWS-side stacks. LocalStack-side, just `docker compose down -v`.

---

## Progress

- [x] Lab 0 — IAM user, budgets, Terraform, LocalStack smoke
- [x] Lab 1 — VPC + 2 subnets + 2 EC2s + EICE; verified intra-VPC reachability, no internet egress, route table = single `local` rule; destroyed cleanly (12 resources)
- [x] Lab 2 — IGW + custom route table + public IP; proved three pillars of public access, IGW NAT, jump host to private subnet, break/fix (route removal froze SSH); destroyed cleanly (17 resources)
- [ ] Lab 3
- [ ] Lab 3
- [ ] Lab 4
- [ ] Lab 5
- [ ] Lab 6
- [ ] Lab 7
- [ ] Lab 8
- [ ] Lab 9
