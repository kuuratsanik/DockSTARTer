#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# Compliance Checker
# Validates adherence to POLICIES.md requirements
# Performs automated compliance audits

# Determine home directory safely
HOME_DIR="${DETECTED_HOMEDIR:-${HOME:-$PWD}}"
readonly COMPLIANCE_DIR="${HOME_DIR}/.config/dockstarter/compliance"
readonly COMPLIANCE_REPORT="${COMPLIANCE_DIR}/report_$(date -u +"%Y-%m-%d").json"

compliance_init() {
    mkdir -p "${COMPLIANCE_DIR}"
}

check_docker_security() {
    local STATUS="compliant"
    local ISSUES=()
    
    echo "Checking Docker security configuration..." >&2
    
    # Check if Docker daemon is running
    if ! docker info &>/dev/null; then
        ISSUES+=("Docker daemon not running or not accessible")
        STATUS="non-compliant"
    fi
    
    # Check for running privileged containers (security risk)
    local PRIVILEGED_CONTAINERS
    PRIVILEGED_CONTAINERS=$(docker ps --filter "status=running" --quiet 2>/dev/null | \
        xargs -r docker inspect --format '{{.Name}}:{{.HostConfig.Privileged}}' 2>/dev/null | \
        grep ":true" || true)
    
    if [[ -n "${PRIVILEGED_CONTAINERS}" ]]; then
        ISSUES+=("Privileged containers detected: ${PRIVILEGED_CONTAINERS}")
        STATUS="compliant-with-exceptions"
    fi
    
    # Check for containers with host network mode
    local HOST_NETWORK
    HOST_NETWORK=$(docker ps --filter "status=running" --quiet 2>/dev/null | \
        xargs -r docker inspect --format '{{.Name}}:{{.HostConfig.NetworkMode}}' 2>/dev/null | \
        grep ":host" || true)
    
    if [[ -n "${HOST_NETWORK}" ]]; then
        ISSUES+=("Containers using host network mode: ${HOST_NETWORK}")
        STATUS="compliant-with-exceptions"
    fi
    
    # Return results as JSON
    jq -n \
        --arg status "${STATUS}" \
        --argjson issues "$(if [[ ${#ISSUES[@]} -eq 0 ]]; then echo '[]'; else printf '%s\n' "${ISSUES[@]}" | jq -R . | jq -s .; fi)" \
        '{
            "check": "docker_security",
            "status": $status,
            "issues": $issues,
            "policy_ref": "Section 5.1 - EU AI Act Alignment"
        }'
}

check_data_privacy() {
    local STATUS="compliant"
    local ISSUES=()
    
    echo "Checking data privacy configuration..." >&2
    
    # Check for environment files with sensitive data
    if [[ -d "${HOME_DIR}/.docker/compose" ]]; then
        local ENV_FILES
        ENV_FILES=$(find "${HOME_DIR}/.docker/compose" -name ".env*" 2>/dev/null || true)
        
        if [[ -n "${ENV_FILES}" ]]; then
            # Check if env files contain API keys or passwords in plain text
            local SENSITIVE_PATTERN="(API_KEY|PASSWORD|SECRET|TOKEN)=[^$]"
            if echo "${ENV_FILES}" | xargs grep -E "${SENSITIVE_PATTERN}" 2>/dev/null | grep -v "^#" > /dev/null; then
                ISSUES+=("Potential hardcoded secrets found in .env files")
                STATUS="non-compliant"
            fi
        fi
    fi
    
    jq -n \
        --arg status "${STATUS}" \
        --argjson issues "$(if [[ ${#ISSUES[@]} -eq 0 ]]; then echo '[]'; else printf '%s\n' "${ISSUES[@]}" | jq -R . | jq -s .; fi)" \
        '{
            "check": "data_privacy",
            "status": $status,
            "issues": $issues,
            "policy_ref": "Section 5.2 - Consent & Retention"
        }'
}

check_lineage_logging() {
    local STATUS="compliant"
    local ISSUES=()
    
    echo "Checking lineage logging..." >&2
    
    local LINEAGE_DIR="${HOME_DIR}/.config/dockstarter/lineage"
    
    if [[ ! -d "${LINEAGE_DIR}" ]]; then
        ISSUES+=("Lineage logging directory not found")
        STATUS="non-compliant"
    else
        local RECENT_LOGS
        RECENT_LOGS=$(find "${LINEAGE_DIR}" -name "*.jsonl" -mtime -7 2>/dev/null || true)
        
        if [[ -z "${RECENT_LOGS}" ]]; then
            ISSUES+=("No lineage events logged in the past 7 days")
            STATUS="compliant-with-exceptions"
        fi
    fi
    
    jq -n \
        --arg status "${STATUS}" \
        --argjson issues "$(if [[ ${#ISSUES[@]} -eq 0 ]]; then echo '[]'; else printf '%s\n' "${ISSUES[@]}" | jq -R . | jq -s .; fi)" \
        '{
            "check": "lineage_logging",
            "status": $status,
            "issues": $issues,
            "policy_ref": "Section 7.3 - Auditability"
        }'
}

check_self_healing() {
    local STATUS="compliant"
    local ISSUES=()
    
    echo "Checking self-healing configuration..." >&2
    
    # Check if containers have restart policies
    local NO_RESTART_POLICY
    NO_RESTART_POLICY=$(docker ps --quiet 2>/dev/null | \
        xargs -r docker inspect --format '{{.Name}}:{{.HostConfig.RestartPolicy.Name}}' 2>/dev/null | \
        grep ":no$\|:$" || true)
    
    if [[ -n "${NO_RESTART_POLICY}" ]]; then
        ISSUES+=("Containers without restart policy: ${NO_RESTART_POLICY}")
        STATUS="compliant-with-exceptions"
    fi
    
    # Check for health checks
    local NO_HEALTHCHECK
    NO_HEALTHCHECK=$(docker ps --quiet 2>/dev/null | \
        xargs -r docker inspect --format '{{.Name}}:{{.Config.Healthcheck}}' 2>/dev/null | \
        grep ":<nil>$" || true)
    
    if [[ -n "${NO_HEALTHCHECK}" ]]; then
        ISSUES+=("Containers without health checks: ${NO_HEALTHCHECK}")
        STATUS="compliant-with-exceptions"
    fi
    
    jq -n \
        --arg status "${STATUS}" \
        --argjson issues "$(if [[ ${#ISSUES[@]} -eq 0 ]]; then echo '[]'; else printf '%s\n' "${ISSUES[@]}" | jq -R . | jq -s .; fi)" \
        '{
            "check": "self_healing",
            "status": $status,
            "issues": $issues,
            "policy_ref": "Section 4.1 - Automatic Operations"
        }'
}

generate_compliance_report() {
    compliance_init
    
    local TIMESTAMP
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    echo "Generating compliance report..." >&2
    
    # Run all checks and combine results
    local DOCKER_SEC DATA_PRIV LINEAGE SELF_HEAL
    
    if command -v jq &> /dev/null; then
        DOCKER_SEC=$(check_docker_security)
        DATA_PRIV=$(check_data_privacy)
        LINEAGE=$(check_lineage_logging)
        SELF_HEAL=$(check_self_healing)
        
        # Combine into full report
        jq -n \
            --arg timestamp "${TIMESTAMP}" \
            --argjson docker_sec "${DOCKER_SEC}" \
            --argjson data_priv "${DATA_PRIV}" \
            --argjson lineage "${LINEAGE}" \
            --argjson self_heal "${SELF_HEAL}" \
            '{
                "report_date": $timestamp,
                "checks": [
                    $docker_sec,
                    $data_priv,
                    $lineage,
                    $self_heal
                ]
            } | . + {
                "overall_status": (
                    [.checks[].status] as $statuses |
                    if ($statuses | any(. == "non-compliant")) then "non-compliant"
                    elif ($statuses | any(. == "compliant-with-exceptions")) then "compliant-with-exceptions"
                    else "compliant"
                    end
                )
            }' > "${COMPLIANCE_REPORT}"
        
        echo "Compliance report generated: ${COMPLIANCE_REPORT}"
        
        # Display summary
        jq -r '"
Overall Status: " + .overall_status + "

Checks Performed:
" + (.checks | map("  - " + .check + ": " + .status) | join("\n"))
' "${COMPLIANCE_REPORT}"
        
        # Log lineage event
        if declare -F lineage_log &> /dev/null; then
            lineage_log "compliance_audit" "Monthly compliance check completed" "[\"${COMPLIANCE_REPORT}\"]" "5.1 EU AI Act Alignment" "compliant" "scheduled-audit"
        fi
    else
        echo "Error: jq is required for compliance reporting" >&2
        echo "Install with: sudo apt install jq" >&2
        exit 1
    fi
}

# Main execution (only if not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-report}" in
        report)
            generate_compliance_report
            ;;
        docker)
            check_docker_security | jq '.'
            ;;
        privacy)
            check_data_privacy | jq '.'
            ;;
        lineage)
            check_lineage_logging | jq '.'
            ;;
        healing)
            check_self_healing | jq '.'
            ;;
        *)
            echo "Usage: $0 {report|docker|privacy|lineage|healing}"
            exit 1
            ;;
    esac
fi
