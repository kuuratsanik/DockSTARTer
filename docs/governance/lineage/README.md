# Lineage Events & Audit Trails

This directory contains the lineage event logging infrastructure for DockSTARTer. Every significant action taken by AI agents, automated systems, or human contributors generates an immutable audit record.

---

## Overview

**Lineage events** are structured JSON records that document:

- **WHO** performed the action (agent ID or user)
- **WHAT** action was taken
- **WHEN** it occurred (UTC timestamp)
- **WHY** it was done (intent/justification)
- **WHERE** it was applied (files modified, resources affected)
- **COMPLIANCE** status (policy section reference)

---

## Event Schema

See [`TEMPLATE.json`](./TEMPLATE.json) for the complete JSON schema.

### Example Event

```json
{
  "timestamp": "2025-10-18T14:32:00Z",
  "agent_id": "copilot-dockstarter-001",
  "action": "code_modification",
  "intent": "Add health check to Jellyfin container to improve auto-healing resilience",
  "files_modified": ["compose/jellyfin.yml"],
  "policy_compliance": {
    "section": "4.1 Automatic Operations - Self-Healing",
    "status": "compliant"
  },
  "audit_trail": "https://github.com/GhostWriters/DockSTARTer/pull/1234"
}

```

---

## Storage

Lineage events are stored in **JSON Lines** (`.jsonl`) format:

- **Location**: `~/.config/dockstarter/lineage/`
- **Filename**: `YYYY-MM-DD.jsonl` (one file per day)
- **Format**: One JSON object per line (newline-delimited)

### Why JSON Lines?

- ✅ **Append-only**: New events are added without rewriting entire file
- ✅ **Streamable**: Can process large files line-by-line
- ✅ **Queryable**: Easy to filter with `jq`, `grep`, or log aggregators

---

## Logging Events

### From Shell Scripts

```bash

# Source the lineage logging function
source .scripts/lineage_log.sh

# Log an event
lineage_log \
  "deployment" \
  "Deployed Plex container with updated config" \
  '["compose/plex.yml", ".env"]' \
  "4.1 Automatic Operations" \
  "compliant" \
  "manual-deployment"

```

### From Python (future)

```python
import json
from datetime import datetime

def lineage_log(action, intent, files_modified=None, policy_section="", status="compliant", audit_trail=""):
    event = {
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "agent_id": "python-script",
        "action": action,
        "intent": intent,
        "files_modified": files_modified or [],
        "policy_compliance": {
            "section": policy_section,
            "status": status
        },
        "audit_trail": audit_trail
    }

    with open(f"~/.config/dockstarter/lineage/{datetime.utcnow().strftime('%Y-%m-%d')}.jsonl", "a") as f:
        f.write(json.dumps(event) + "\n")

```

---

## Querying Events

### List Recent Events

```bash

# Last 10 events
cat ~/.config/dockstarter/lineage/$(date -u +%Y-%m-%d).jsonl | tail -n 10 | jq '.'

# Events from specific date
jq '.' ~/.config/dockstarter/lineage/2025-10-18.jsonl

```

### Filter by Action Type

```bash

# All code modifications
jq 'select(.action == "code_modification")' ~/.config/dockstarter/lineage/*.jsonl

```

### Filter by Policy Compliance

```bash

# Non-compliant events
jq 'select(.policy_compliance.status != "compliant")' ~/.config/dockstarter/lineage/*.jsonl

```

### Generate Compliance Report

```bash

# Count events by action type
jq -r '.action' ~/.config/dockstarter/lineage/*.jsonl | sort | uniq -c

```

---

## Retention Policy

- **Short-term**: 90 days in local JSON files
- **Long-term**: Archived to external storage (optional)
- **Blockchain anchoring**: Future feature (Q1 2026)

### Manual Archive

```bash

# Compress old logs
tar -czf lineage-archive-2025-Q3.tar.gz ~/.config/dockstarter/lineage/2025-0[789]-*.jsonl

# Upload to backup storage
rclone copy lineage-archive-2025-Q3.tar.gz remote:backups/lineage/

```

---

## Compliance Integration

Lineage events are referenced in compliance reports:

```bash

# Check if lineage logging is active
bash .scripts/compliance_check.sh lineage

```

Expected output:

```json
{
  "check": "lineage_logging",
  "status": "compliant",
  "issues": [],
  "policy_ref": "Section 7.3 - Auditability"
}

```

---

## Blockchain Anchoring (Roadmap)

**Status**: Planned for Q1 2026

**Concept**: Daily lineage event batches will be hashed and anchored on-chain for tamper-proof audit trails.

**Benefits**:

- ✅ Cryptographic proof of event sequence
- ✅ Immutable audit history
- ✅ Compliance with DAO governance requirements

**Implementation**:
```bash

# Future: Anchor daily batch to blockchain
lineage_anchor --batch ~/.config/dockstarter/lineage/2025-10-18.jsonl --chain ethereum

```

---

## Troubleshooting

### Events Not Being Logged

**Check 1: Lineage directory exists**
```bash
ls -la ~/.config/dockstarter/lineage/

```

**Check 2: Permissions**
```bash
chmod 755 ~/.config/dockstarter/lineage/

```

**Check 3: Lineage logging function loaded**
```bash
declare -F lineage_log
# Should output: lineage_log

```

### Invalid JSON Format

**Validate with jq**:
```bash
jq empty ~/.config/dockstarter/lineage/*.jsonl
# No output = valid JSON
# Error output = fix the malformed line

```

---

## Best Practices

1. **Always log significant actions**: Code changes, deployments, config updates
2. **Use descriptive intents**: Future you (or auditors) will thank you
3. **Reference policy sections**: Links actions to governance framework
4. **Include audit trails**: GitHub PR URLs, commit SHAs, issue numbers
5. **Monitor compliance status**: Run monthly compliance checks

---

## Resources

- [JSON Lines Spec](https://jsonlines.org/)
- [jq Manual](https://stedolan.github.io/jq/manual/)
- [POLICIES.md Section 7.3](../../POLICIES.md#73-auditability)
- [Governance CLI](../../.scripts/governance_cli.sh)

---

**Questions?** File an issue with the `lineage` label.

**Suggestions?** We welcome improvements to the lineage logging system!

---

*Last Updated: October 18, 2025*
*Schema Version: 1.0.0*
