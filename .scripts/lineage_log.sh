#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# Lineage Event Logger
# Generates immutable audit records for all significant actions
# Compliant with POLICIES.md Section 7.3

lineage_log() {
    local ACTION="${1:?Action required}"
    local INTENT="${2:?Intent required}"
    local FILES_MODIFIED="${3:-[]}"
    local POLICY_SECTION="${4:-}"
    local POLICY_STATUS="${5:-compliant}"
    
    local TIMESTAMP
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    local AGENT_ID="dockstarter-shell-$(hostname)"
    
    local AUDIT_TRAIL="${6:-N/A}"
    
    # Create lineage event JSON
    local LINEAGE_EVENT
    LINEAGE_EVENT=$(cat <<EOF
{
  "timestamp": "${TIMESTAMP}",
  "agent_id": "${AGENT_ID}",
  "action": "${ACTION}",
  "intent": "${INTENT}",
  "files_modified": ${FILES_MODIFIED},
  "policy_compliance": {
    "section": "${POLICY_SECTION}",
    "status": "${POLICY_STATUS}"
  },
  "audit_trail": "${AUDIT_TRAIL}"
}
EOF
)
    
    # Log to file (create directory if needed)
    local LINEAGE_DIR="${DETECTED_HOMEDIR}/.config/dockstarter/lineage"
    mkdir -p "${LINEAGE_DIR}"
    
    local LINEAGE_FILE="${LINEAGE_DIR}/$(date -u +"%Y-%m-%d").jsonl"
    echo "${LINEAGE_EVENT}" >> "${LINEAGE_FILE}"
    
    # Also log to syslog if available
    if command -v logger &> /dev/null; then
        logger -t dockstarter-lineage -p user.info "ACTION=${ACTION} INTENT=${INTENT}"
    fi
    
    # Output to stdout for debugging
    if [[ ${DS_DEBUG:-false} == true ]]; then
        echo "Lineage Event Logged:" >&2
        echo "${LINEAGE_EVENT}" | jq '.' 2>/dev/null || echo "${LINEAGE_EVENT}" >&2
    fi
}

# Export function for use in other scripts
export -f lineage_log

# If script is executed directly (not sourced), run test
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Testing lineage_log function..."
    lineage_log "code_modification" "Test lineage event" '["test.sh"]' "7.3 Auditability" "compliant" "test-run"
    echo "Lineage event logged successfully!"
fi
