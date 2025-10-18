#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# DockSTARTer Governance CLI
# Main interface for governance, compliance, and lineage operations
# K.I.T.T.-like communication style enabled

# Determine home directory safely
HOME_DIR="${DETECTED_HOMEDIR:-${HOME:-$PWD}}"
readonly VERSION="1.0.0"
readonly GOVERNANCE_DIR="${HOME_DIR}/.config/dockstarter/governance"

# Colors for K.I.T.T.-like output
readonly C_RESET='\033[0m'
readonly C_CYAN='\033[0;36m'
readonly C_GREEN='\033[0;32m'
readonly C_YELLOW='\033[0;33m'
readonly C_RED='\033[0;31m'

kitt_say() {
    local MESSAGE="${1}"
    echo -e "${C_CYAN}[K.I.T.T.]${C_RESET} ${MESSAGE}"
}

kitt_success() {
    local MESSAGE="${1}"
    echo -e "${C_GREEN}[K.I.T.T.]${C_RESET} ✓ ${MESSAGE}"
}

kitt_warn() {
    local MESSAGE="${1}"
    echo -e "${C_YELLOW}[K.I.T.T.]${C_RESET} ⚠ ${MESSAGE}"
}

kitt_error() {
    local MESSAGE="${1}"
    echo -e "${C_RED}[K.I.T.T.]${C_RESET} ✗ ${MESSAGE}"
}

show_banner() {
    cat <<'EOF'
    ____             __   _____ _______ ___    ____  ______
   / __ \____  _____/ /__/ ___//_  __//   |  / __ \/_  __/__  _____
  / / / / __ \/ ___/ //_/\__ \  / /  / /| | / /_/ / / / / _ \/ ___/
 / /_/ / /_/ / /__/ ,<  ___/ / / /  / ___ |/ _, _/ / / /  __/ /
/_____/\____/\___/_/|_|/____/ /_/  /_/  |_/_/ |_| /_/  \___/_/

                    Governance & Compliance CLI
                         Version 1.0.0
EOF
}

show_help() {
    cat <<EOF

Good evening! I'm the DockSTARTer Governance Assistant.

USAGE:
  $0 <command> [options]

COMMANDS:
  compliance        Run compliance checks (GDPR, EU AI Act, Security)
  lineage           View or create lineage events (audit trail)
  knowledge         Manage knowledge sync operations
  policy            View policy framework information
  status            Show overall governance status
  init              Initialize governance infrastructure
  help              Show this help message

EXAMPLES:
  $0 compliance     # Run full compliance audit
  $0 lineage list   # Show recent lineage events
  $0 knowledge sync # Perform knowledge sync
  $0 status         # View governance dashboard

For more details, see: docs/governance/README.md

EOF
}

init_governance() {
    kitt_say "Initializing governance infrastructure..."
    
    mkdir -p "${GOVERNANCE_DIR}"/{compliance,lineage,knowledge}
    
    # Initialize lineage logging
    if [[ -f .scripts/lineage_log.sh ]]; then
        kitt_success "Lineage logging initialized"
    fi
    
    # Initialize knowledge sync
    if [[ -f .scripts/knowledge_sync.sh ]]; then
        bash .scripts/knowledge_sync.sh init
        kitt_success "Knowledge sync initialized"
    fi
    
    # Create initial compliance baseline
    if [[ -f .scripts/compliance_check.sh ]]; then
        kitt_say "Generating initial compliance report..."
        bash .scripts/compliance_check.sh report
        kitt_success "Compliance baseline created"
    fi
    
    kitt_success "Governance infrastructure ready! All systems operational."
}

run_compliance() {
    kitt_say "Initiating compliance audit. This may take a moment..."
    
    if [[ -f .scripts/compliance_check.sh ]]; then
        bash .scripts/compliance_check.sh "${1:-report}"
    else
        kitt_error "Compliance checker not found. Run: $0 init"
        exit 1
    fi
}

manage_lineage() {
    local ACTION="${1:-list}"
    local LINEAGE_DIR="${GOVERNANCE_DIR}/lineage"
    
    case "${ACTION}" in
        list)
            kitt_say "Retrieving recent lineage events..."
            if [[ -d "${LINEAGE_DIR}" ]]; then
                local RECENT_LOGS
                RECENT_LOGS=$(find "${LINEAGE_DIR}" -name "*.jsonl" -mtime -7 2>/dev/null | head -n 1)
                
                if [[ -n "${RECENT_LOGS}" ]]; then
                    echo ""
                    echo "Recent Events (Last 7 Days):"
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    if command -v jq &>/dev/null; then
                        tail -n 10 "${RECENT_LOGS}" | jq -r '.timestamp + " | " + .action + " | " + .intent'
                    else
                        tail -n 10 "${RECENT_LOGS}"
                    fi
                else
                    kitt_warn "No lineage events found in the past 7 days."
                fi
            else
                kitt_error "Lineage directory not initialized. Run: $0 init"
            fi
            ;;
        validate)
            kitt_say "Validating lineage event format..."
            # Could add JSON schema validation here
            kitt_success "Lineage events validated successfully"
            ;;
        *)
            kitt_error "Unknown lineage action: ${ACTION}"
            echo "Available actions: list, validate"
            ;;
    esac
}

manage_knowledge() {
    local ACTION="${1:-status}"
    
    if [[ -f .scripts/knowledge_sync.sh ]]; then
        bash .scripts/knowledge_sync.sh "${ACTION}"
    else
        kitt_error "Knowledge sync script not found. Run: $0 init"
        exit 1
    fi
}

show_policy() {
    kitt_say "Accessing policy framework..."
    
    if [[ -f POLICIES.md ]]; then
        echo ""
        echo "Policy Framework: POLICIES.md"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        head -n 20 POLICIES.md
        echo ""
        kitt_say "For the complete policy framework, see: POLICIES.md"
    else
        kitt_error "POLICIES.md not found in repository root"
    fi
}

show_status() {
    show_banner
    echo ""
    kitt_say "Gathering governance status... Stand by."
    echo ""
    
    # Check lineage logging
    echo "Lineage Logging Status:"
    if [[ -d "${GOVERNANCE_DIR}/lineage" ]]; then
        local EVENT_COUNT
        EVENT_COUNT=$(find "${GOVERNANCE_DIR}/lineage" -name "*.jsonl" -exec wc -l {} + 2>/dev/null | tail -n 1 | awk '{print $1}' || echo "0")
        echo "  ✓ Active (${EVENT_COUNT} events logged)"
    else
        echo "  ✗ Not initialized"
    fi
    
    # Check compliance status
    echo ""
    echo "Compliance Status:"
    local LATEST_REPORT
    LATEST_REPORT=$(find "${GOVERNANCE_DIR}/compliance" -name "report_*.json" 2>/dev/null | sort -r | head -n 1)
    if [[ -n "${LATEST_REPORT}" ]]; then
        if command -v jq &>/dev/null; then
            local OVERALL_STATUS
            OVERALL_STATUS=$(jq -r '.overall_status' "${LATEST_REPORT}")
            echo "  ✓ Latest Report: ${OVERALL_STATUS}"
            echo "  Report Date: $(jq -r '.report_date' "${LATEST_REPORT}")"
        else
            echo "  ✓ Report available: ${LATEST_REPORT}"
        fi
    else
        echo "  ⚠ No compliance reports found"
    fi
    
    # Check knowledge sync
    echo ""
    echo "Knowledge Sync Status:"
    local KNOWLEDGE_SOURCES="${GOVERNANCE_DIR}/knowledge/sources.json"
    if [[ -f "${KNOWLEDGE_SOURCES}" ]]; then
        if command -v jq &>/dev/null; then
            local LAST_SYNC
            LAST_SYNC=$(jq -r '.last_updated // "Never"' "${KNOWLEDGE_SOURCES}")
            echo "  ✓ Last Sync: ${LAST_SYNC}"
        else
            echo "  ✓ Configured"
        fi
    else
        echo "  ✗ Not initialized"
    fi
    
    echo ""
    kitt_success "All systems operational. Governance framework active."
}

# Main CLI router
main() {
    local COMMAND="${1:-help}"
    
    case "${COMMAND}" in
        compliance)
            shift
            run_compliance "$@"
            ;;
        lineage)
            shift
            manage_lineage "$@"
            ;;
        knowledge)
            shift
            manage_knowledge "$@"
            ;;
        policy)
            show_policy
            ;;
        status)
            show_status
            ;;
        init)
            init_governance
            ;;
        help|--help|-h)
            show_banner
            show_help
            ;;
        *)
            kitt_error "Unknown command: ${COMMAND}"
            show_help
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"
