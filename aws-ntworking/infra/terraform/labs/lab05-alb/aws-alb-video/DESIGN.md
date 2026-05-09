# Design System — AWS ALB Architecture Diagram

## Style Prompt
Technical infrastructure diagram with AWS branding. Clean, dark canvas with crisp lines and glowing network paths. Motion is precise and systematic — build-up reveals, flowing data packets, pulsing health checks.

## Colors
- `#232F3E` — AWS Dark (background, VPC boundary)
- `#FF9900` — AWS Orange (primary accent, AWS services, ALB)
- `#1B660F` — AWS Green (healthy targets, success states)
- `#3B48CC` — AWS Blue (networking, subnets, connections)
- `#D93025` — AWS Red (security groups, shields, unhealthy)
- `#F5F5F5` — Light text on dark backgrounds
- `#0D1117` — Deep background
- `#1A2332` — VPC fill
- `#243447` — Subnet fill (public)
- `#1A2B1A` — Subnet fill (private)
- `#FF990033` — Orange glow (data packets)

## Typography
- **Primary:** 'Inter', system-ui, sans-serif (labels, body)
- **Mono:** 'JetBrains Mono', 'Fira Code', monospace (IPs, CIDR, technical values)

## Motion Rules
- Build-up: elements appear layer by layer (outside-in)
- Data flow: glowing dots travel along paths
- Health checks: rhythmic pulse animation
- Security: shield/lock icons with brief glow on activation
- Easing: power2.out for entrances, power1.inOut for flows

## What NOT to Do
- No generic blue (#3b82f6) or default grays
- No bouncy/playful easing — keep it technical and precise
- No gradients on text — only on backgrounds/glows
- No rounded corners > 8px — keep it sharp and architectural
- No decorative elements that don't represent real AWS components
