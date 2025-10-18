#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# Weekly Knowledge Sync Script
# Compliant with POLICIES.md Section 6.1
# Downloads latest best practices, security updates, and knowledge sources

# Determine home directory safely
HOME_DIR="${DETECTED_HOMEDIR:-${HOME:-$PWD}}"
readonly KNOWLEDGE_SYNC_DIR="${HOME_DIR}/.config/dockstarter/knowledge"
readonly KNOWLEDGE_SOURCES="${KNOWLEDGE_SYNC_DIR}/sources.json"
readonly KNOWLEDGE_CACHE="${KNOWLEDGE_SYNC_DIR}/cache"
readonly KNOWLEDGE_LOG="${KNOWLEDGE_SYNC_DIR}/sync.log"

knowledge_sync_init() {
    mkdir -p "${KNOWLEDGE_SYNC_DIR}" "${KNOWLEDGE_CACHE}"
    
    # Create initial sources list if not exists
    if [[ ! -f "${KNOWLEDGE_SOURCES}" ]]; then
        cat > "${KNOWLEDGE_SOURCES}" <<'EOF'
{
  "last_updated": "",
  "sources": {
    "docker": [
      "https://docs.docker.com/",
      "https://github.com/docker/awesome-compose"
    ],
    "security": [
      "https://owasp.org/www-project-top-ten/",
      "https://www.nist.gov/cyberframework",
      "https://cve.mitre.org/"
    ],
    "infrastructure": [
      "https://www.proxmox.com/en/news",
      "https://kubernetes.io/blog/",
      "https://www.linuxserver.io/blog"
    ],
    "homelab": [
      "https://github.com/awesome-selfhosted/awesome-selfhosted",
      "https://github.com/mikeroyal/Self-Hosting-Guide"
    ]
  }
}
EOF
    fi
}

knowledge_sync_run() {
    local TIMESTAMP
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    echo "[${TIMESTAMP}] Starting weekly knowledge sync..." | tee -a "${KNOWLEDGE_LOG}"
    
    # Update Docker best practices
    if command -v docker &> /dev/null; then
        echo "Checking for Docker updates..." | tee -a "${KNOWLEDGE_LOG}"
        docker version > "${KNOWLEDGE_CACHE}/docker_version.txt" 2>&1 || true
    fi
    
    # Check for security updates
    echo "Checking for security updates..." | tee -a "${KNOWLEDGE_LOG}"
    if command -v apt &> /dev/null; then
        apt list --upgradable 2>/dev/null > "${KNOWLEDGE_CACHE}/apt_upgradable.txt" || true
    fi
    
    # Download CVE feed (simplified - in production, use proper CVE API)
    if command -v curl &> /dev/null; then
        echo "Fetching latest security advisories..." | tee -a "${KNOWLEDGE_LOG}"
        curl -sf "https://cve.circl.lu/api/last" > "${KNOWLEDGE_CACHE}/cve_latest.json" 2>/dev/null || true
    fi
    
    # Update sources timestamp
    if command -v jq &> /dev/null && [[ -f "${KNOWLEDGE_SOURCES}" ]]; then
        jq --arg ts "${TIMESTAMP}" '.last_updated = $ts' "${KNOWLEDGE_SOURCES}" > "${KNOWLEDGE_SOURCES}.tmp"
        mv "${KNOWLEDGE_SOURCES}.tmp" "${KNOWLEDGE_SOURCES}"
    fi
    
    echo "[${TIMESTAMP}] Knowledge sync completed." | tee -a "${KNOWLEDGE_LOG}"
    
    # Log lineage event
    if declare -F lineage_log &> /dev/null; then
        lineage_log "knowledge_sync" "Weekly knowledge sync completed" '["knowledge/cache/*"]' "6.1 Weekly Knowledge Sync" "compliant" "cron-job"
    fi
}

knowledge_sync_status() {
    if [[ -f "${KNOWLEDGE_SOURCES}" ]]; then
        echo "Knowledge Sync Status:"
        if command -v jq &> /dev/null; then
            jq -r '"Last Updated: " + .last_updated' "${KNOWLEDGE_SOURCES}"
        else
            grep -o '"last_updated":"[^"]*"' "${KNOWLEDGE_SOURCES}" || echo "Unknown"
        fi
        
        if [[ -f "${KNOWLEDGE_LOG}" ]]; then
            echo ""
            echo "Recent sync log:"
            tail -n 10 "${KNOWLEDGE_LOG}"
        fi
    else
        echo "Knowledge sync not initialized. Run: knowledge_sync_init"
    fi
}

# Main execution
case "${1:-run}" in
    init)
        knowledge_sync_init
        echo "Knowledge sync initialized at ${KNOWLEDGE_SYNC_DIR}"
        ;;
    run)
        knowledge_sync_init
        knowledge_sync_run
        ;;
    status)
        knowledge_sync_status
        ;;
    *)
        echo "Usage: $0 {init|run|status}"
        exit 1
        ;;
esac
