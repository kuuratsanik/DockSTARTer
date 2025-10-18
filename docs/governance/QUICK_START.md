# DockSTARTer Governance Quick Start

Welcome! This guide will get you up and running with the DockSTARTer governance framework in under 5 minutes.

---

## What You Get

✅ **Policy Framework** - Comprehensive governance charter (POLICIES.md)  
✅ **AI Agent Guidelines** - GitHub Copilot operational rules  
✅ **Compliance Automation** - GDPR, EU AI Act, security audits  
✅ **Lineage Logging** - Immutable audit trails for all actions  
✅ **Knowledge Sync** - Weekly updates from 100,000+ trusted sources  
✅ **K.I.T.T.-like CLI** - Intelligent, witty governance interface  

---

## Installation

### 1. Initialize Governance Infrastructure

```bash
cd /path/to/DockSTARTer
bash .scripts/governance_cli.sh init
```

This creates:
- `~/.config/dockstarter/governance/` - Main governance directory
- `~/.config/dockstarter/lineage/` - Audit trail storage
- `~/.config/dockstarter/knowledge/` - Knowledge sync cache
- `~/.config/dockstarter/compliance/` - Compliance reports

### 2. Run Initial Compliance Check

```bash
bash .scripts/governance_cli.sh compliance
```

Checks:
- Docker security configuration
- Data privacy settings
- Lineage logging status
- Self-healing capabilities

### 3. Set Up Automation (Optional)

#### Cron Jobs (Recommended)

```bash
# Copy cron template
sudo cp docs/governance/cron-template /etc/cron.d/dockstarter-governance

# Edit to set your installation path
sudo nano /etc/cron.d/dockstarter-governance

# Reload cron
sudo systemctl reload cron
```

#### Systemd Timers (Advanced)

See [`docs/governance/systemd-timers.md`](./systemd-timers.md) (TODO)

---

## Usage

### Governance CLI

```bash
# Show dashboard
bash .scripts/governance_cli.sh status

# Run compliance audit
bash .scripts/governance_cli.sh compliance

# View recent lineage events
bash .scripts/governance_cli.sh lineage list

# Perform knowledge sync
bash .scripts/governance_cli.sh knowledge sync

# View policy framework
bash .scripts/governance_cli.sh policy
```

### Manual Operations

#### Log a Lineage Event

```bash
source .scripts/lineage_log.sh

lineage_log \
  "deployment" \
  "Deployed Jellyfin with optimized config" \
  '["compose/jellyfin.yml"]' \
  "4.1 Automatic Operations" \
  "compliant" \
  "manual-deployment"
```

#### Run Compliance Check

```bash
# Full report
bash .scripts/compliance_check.sh report

# Individual checks
bash .scripts/compliance_check.sh docker
bash .scripts/compliance_check.sh privacy
bash .scripts/compliance_check.sh healing
```

#### Knowledge Sync

```bash
# Initialize
bash .scripts/knowledge_sync.sh init

# Run sync
bash .scripts/knowledge_sync.sh run

# Check status
bash .scripts/knowledge_sync.sh status
```

---

## Key Concepts

### Lineage Events

Every significant action generates an audit record:

```json
{
  "timestamp": "2025-10-18T14:32:00Z",
  "agent_id": "human-steward-alice",
  "action": "code_modification",
  "intent": "Added health checks to improve resilience",
  "files_modified": ["compose/plex.yml"],
  "policy_compliance": {
    "section": "4.1 Automatic Operations",
    "status": "compliant"
  }
}
```

### Compliance Status

- ✅ **Compliant** - Fully meets policy requirements
- 🟡 **Compliant with Exceptions** - Minor deviations documented
- ❌ **Non-Compliant** - Remediation required

### K.I.T.T.-like Communication

AI agents communicate intelligently and humorously:

> *"Good evening! I've detected a misconfiguration in your Proxmox cluster. Shall I initiate auto-healing protocols, or would you prefer to review the diagnostics first?"*

---

## File Structure

```
DockSTARTer/
├── POLICIES.md                          # Authoritative governance charter
├── CHANGELOG.md                         # Policy version history
├── .github/
│   └── copilot-instructions.md          # AI agent operational guide
├── .scripts/
│   ├── governance_cli.sh                # Main CLI interface
│   ├── lineage_log.sh                   # Audit trail logging
│   ├── knowledge_sync.sh                # Weekly knowledge updates
│   └── compliance_check.sh              # Automated compliance audits
└── docs/
    └── governance/
        ├── README.md                    # Governance hub
        ├── QUICK_START.md               # This file
        ├── cron-template                # Automation config
        ├── compliance/
        │   └── README.md                # GDPR, EU AI Act, security
        └── lineage/
            ├── README.md                # Audit trail documentation
            └── TEMPLATE.json            # Lineage event schema
```

---

## Common Tasks

### Add New Docker Container

```bash
# 1. Edit compose file
nano compose/myapp.yml

# 2. Log the change
source .scripts/lineage_log.sh
lineage_log "code_modification" "Added myapp container" '["compose/myapp.yml"]' "8.1 Technology Stack" "compliant" "user-request"

# 3. Deploy
docker-compose up -d myapp
```

### Review Compliance Report

```bash
# Generate latest report
bash .scripts/governance_cli.sh compliance

# View JSON details
cat ~/.config/dockstarter/governance/compliance/report_$(date -u +%Y-%m-%d).json | jq '.'
```

### Query Audit Trail

```bash
# List all events from today
cat ~/.config/dockstarter/lineage/$(date -u +%Y-%m-%d).jsonl | jq '.'

# Filter by action type
jq 'select(.action == "deployment")' ~/.config/dockstarter/lineage/*.jsonl

# Find non-compliant events
jq 'select(.policy_compliance.status != "compliant")' ~/.config/dockstarter/lineage/*.jsonl
```

---

## Troubleshooting

### "jq: command not found"

```bash
# Ubuntu/Debian
sudo apt install jq

# Alpine
sudo apk add jq

# macOS
brew install jq
```

### Permissions Error

```bash
# Fix ownership
chown -R $USER:$USER ~/.config/dockstarter/

# Fix permissions
chmod -R 755 ~/.config/dockstarter/
```

### Lineage Events Not Logging

```bash
# Check if function is loaded
declare -F lineage_log

# If not found, source manually
source .scripts/lineage_log.sh
```

---

## Next Steps

1. **Read the Policy Framework**: [`POLICIES.md`](../../POLICIES.md)
2. **Explore Compliance**: [`docs/governance/compliance/README.md`](./compliance/README.md)
3. **Understand Lineage**: [`docs/governance/lineage/README.md`](./lineage/README.md)
4. **Set Up Automation**: Configure cron jobs for weekly/monthly tasks
5. **Integrate with Git**: Add pre-commit hooks for lineage logging

---

## Support

- **Documentation**: [docs/governance/](.)
- **GitHub Issues**: Use `governance` label
- **Policy Questions**: Use `policy-question` label
- **Compliance Issues**: Use `compliance` label

---

## Philosophy

> *"Every action is auditable. Every decision is governed. Every interaction is an opportunity to demonstrate ethical, effective AI collaboration."*
> 
> — DockSTARTer Governance Charter

---

**Welcome to the future of self-governed, AI-enhanced infrastructure!** 🚀

*Last Updated: October 18, 2025*  
*Version: 1.0.0*
