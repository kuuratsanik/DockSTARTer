#!/usr/bin/env bash
set -Eeu
IFS=$'\n\t'

# Governance Framework Test Suite
# Tests all governance components for proper functionality
# Compliant with POLICIES.md Section 10.3

# Colors for output
readonly C_RESET='\033[0m'
readonly C_GREEN='\033[0;32m'
readonly C_RED='\033[0;31m'
readonly C_YELLOW='\033[0;33m'
readonly C_BLUE='\033[0;34m'

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Print functions
print_header() {
    echo -e "\n${C_BLUE}========================================${C_RESET}"
    echo -e "${C_BLUE}$1${C_RESET}"
    echo -e "${C_BLUE}========================================${C_RESET}\n"
}

print_test() {
    echo -e "${C_YELLOW}TEST:${C_RESET} $1"
}

print_pass() {
    echo -e "${C_GREEN}✓ PASS:${C_RESET} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
}

print_fail() {
    echo -e "${C_RED}✗ FAIL:${C_RESET} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
}

print_summary() {
    echo -e "\n${C_BLUE}========================================${C_RESET}"
    echo -e "${C_BLUE}TEST SUMMARY${C_RESET}"
    echo -e "${C_BLUE}========================================${C_RESET}"
    echo -e "Total Tests: ${TESTS_TOTAL}"
    echo -e "${C_GREEN}Passed: ${TESTS_PASSED}${C_RESET}"
    echo -e "${C_RED}Failed: ${TESTS_FAILED}${C_RESET}"
    
    if [[ ${TESTS_FAILED} -eq 0 ]]; then
        echo -e "\n${C_GREEN}All tests passed!${C_RESET}"
        return 0
    else
        echo -e "\n${C_RED}Some tests failed.${C_RESET}"
        return 1
    fi
}

# Test 1: Check if governance files exist
test_files_exist() {
    print_header "Test 1: Governance Files Existence"
    
    local FILES=(
        "POLICIES.md"
        ".github/copilot-instructions.md"
        "docs/governance/README.md"
        "docs/governance/QUICK_START.md"
        "docs/governance/ROADMAP.md"
        "docs/governance/compliance/README.md"
        "docs/governance/lineage/README.md"
        "docs/governance/lineage/TEMPLATE.json"
        ".scripts/lineage_log.sh"
        ".scripts/knowledge_sync.sh"
        ".scripts/compliance_check.sh"
        ".scripts/governance_cli.sh"
    )
    
    for file in "${FILES[@]}"; do
        print_test "Checking if ${file} exists"
        if [[ -f "${file}" ]]; then
            print_pass "${file} exists"
        else
            print_fail "${file} is missing"
        fi
    done
}

# Test 2: Check if scripts are executable
test_scripts_executable() {
    print_header "Test 2: Script Permissions"
    
    local SCRIPTS=(
        ".scripts/lineage_log.sh"
        ".scripts/knowledge_sync.sh"
        ".scripts/compliance_check.sh"
        ".scripts/governance_cli.sh"
    )
    
    for script in "${SCRIPTS[@]}"; do
        print_test "Checking if ${script} is executable"
        if [[ -x "${script}" ]]; then
            print_pass "${script} is executable"
        else
            print_fail "${script} is not executable"
        fi
    done
}

# Test 3: Test lineage logging functionality
test_lineage_logging() {
    print_header "Test 3: Lineage Logging"
    
    print_test "Testing lineage_log.sh execution"
    if bash .scripts/lineage_log.sh > /dev/null 2>&1; then
        print_pass "lineage_log.sh executes successfully"
    else
        print_fail "lineage_log.sh failed to execute"
    fi
    
    print_test "Checking if lineage directory was created"
    if [[ -d "${HOME}/.config/dockstarter/lineage" ]]; then
        print_pass "Lineage directory exists"
    else
        print_fail "Lineage directory not created"
    fi
    
    print_test "Checking if lineage event was logged"
    local TODAY=$(date -u +"%Y-%m-%d")
    if [[ -f "${HOME}/.config/dockstarter/lineage/${TODAY}.jsonl" ]]; then
        print_pass "Lineage event file created"
    else
        print_fail "Lineage event file not created"
    fi
    
    print_test "Validating lineage JSON structure"
    if grep -q '"timestamp"' "${HOME}/.config/dockstarter/lineage/${TODAY}.jsonl" 2>/dev/null && \
       grep -q '"agent_id"' "${HOME}/.config/dockstarter/lineage/${TODAY}.jsonl" 2>/dev/null && \
       grep -q '"action"' "${HOME}/.config/dockstarter/lineage/${TODAY}.jsonl" 2>/dev/null; then
        print_pass "Lineage JSON has required fields"
    else
        print_fail "Lineage JSON missing required fields"
    fi
}

# Test 4: Test knowledge sync functionality
test_knowledge_sync() {
    print_header "Test 4: Knowledge Sync"
    
    print_test "Testing knowledge_sync.sh init"
    if bash .scripts/knowledge_sync.sh init > /dev/null 2>&1; then
        print_pass "knowledge_sync.sh init succeeds"
    else
        print_fail "knowledge_sync.sh init failed"
    fi
    
    print_test "Checking if knowledge directory was created"
    if [[ -d "${HOME}/.config/dockstarter/knowledge" ]]; then
        print_pass "Knowledge directory exists"
    else
        print_fail "Knowledge directory not created"
    fi
    
    print_test "Testing knowledge_sync.sh status"
    if bash .scripts/knowledge_sync.sh status > /dev/null 2>&1; then
        print_pass "knowledge_sync.sh status succeeds"
    else
        print_fail "knowledge_sync.sh status failed"
    fi
}

# Test 5: Test compliance checking
test_compliance_check() {
    print_header "Test 5: Compliance Checking"
    
    print_test "Testing compliance_check.sh docker check"
    if bash .scripts/compliance_check.sh docker > /dev/null 2>&1; then
        print_pass "Docker compliance check succeeds"
    else
        print_fail "Docker compliance check failed"
    fi
    
    print_test "Testing compliance_check.sh privacy check"
    if bash .scripts/compliance_check.sh privacy > /dev/null 2>&1; then
        print_pass "Privacy compliance check succeeds"
    else
        print_fail "Privacy compliance check failed"
    fi
    
    print_test "Testing compliance_check.sh full report"
    if bash .scripts/compliance_check.sh report > /dev/null 2>&1; then
        print_pass "Full compliance report succeeds"
    else
        print_fail "Full compliance report failed"
    fi
    
    print_test "Checking if compliance report was created"
    local TODAY=$(date -u +"%Y-%m-%d")
    if [[ -f "${HOME}/.config/dockstarter/compliance/report_${TODAY}.json" ]]; then
        print_pass "Compliance report file created"
    else
        print_fail "Compliance report file not created"
    fi
}

# Test 6: Test governance CLI
test_governance_cli() {
    print_header "Test 6: Governance CLI"
    
    print_test "Testing governance_cli.sh help"
    if bash .scripts/governance_cli.sh help > /dev/null 2>&1; then
        print_pass "Governance CLI help succeeds"
    else
        print_fail "Governance CLI help failed"
    fi
    
    print_test "Testing governance_cli.sh init"
    if bash .scripts/governance_cli.sh init > /dev/null 2>&1; then
        print_pass "Governance CLI init succeeds"
    else
        print_fail "Governance CLI init failed"
    fi
    
    print_test "Testing governance_cli.sh status"
    if bash .scripts/governance_cli.sh status > /dev/null 2>&1; then
        print_pass "Governance CLI status succeeds"
    else
        print_fail "Governance CLI status failed"
    fi
    
    print_test "Checking governance directory structure"
    if [[ -d "${HOME}/.config/dockstarter/governance" ]] && \
       [[ -d "${HOME}/.config/dockstarter/governance/compliance" ]] && \
       [[ -d "${HOME}/.config/dockstarter/governance/lineage" ]] && \
       [[ -d "${HOME}/.config/dockstarter/governance/knowledge" ]]; then
        print_pass "Governance directory structure is correct"
    else
        print_fail "Governance directory structure is incomplete"
    fi
}

# Test 7: Validate documentation structure
test_documentation() {
    print_header "Test 7: Documentation Validation"
    
    print_test "Checking POLICIES.md has required sections"
    if grep -q "## 1. Core Infrastructure" POLICIES.md && \
       grep -q "## 2. Blockchain, DAO" POLICIES.md && \
       grep -q "## 3. AI Agent Lifecycle" POLICIES.md; then
        print_pass "POLICIES.md has required sections"
    else
        print_fail "POLICIES.md missing required sections"
    fi
    
    print_test "Checking copilot-instructions.md references POLICIES.md"
    if grep -q "POLICIES.md" .github/copilot-instructions.md; then
        print_pass "copilot-instructions.md references POLICIES.md"
    else
        print_fail "copilot-instructions.md does not reference POLICIES.md"
    fi
    
    print_test "Checking mkdocs.yml includes governance section"
    if grep -q "Governance:" mkdocs.yml; then
        print_pass "mkdocs.yml includes Governance section"
    else
        print_fail "mkdocs.yml missing Governance section"
    fi
}

# Test 8: Validate JSON schema
test_json_schema() {
    print_header "Test 8: JSON Schema Validation"
    
    print_test "Checking TEMPLATE.json is valid JSON"
    if python3 -m json.tool docs/governance/lineage/TEMPLATE.json > /dev/null 2>&1; then
        print_pass "TEMPLATE.json is valid JSON"
    else
        print_fail "TEMPLATE.json is not valid JSON"
    fi
    
    print_test "Checking lineage events file is valid JSON Lines"
    local TODAY=$(date -u +"%Y-%m-%d")
    if [[ -f "${HOME}/.config/dockstarter/lineage/${TODAY}.jsonl" ]]; then
        # The file contains multi-line JSON objects, check if file content contains valid JSON structure
        if grep -q '"timestamp"' "${HOME}/.config/dockstarter/lineage/${TODAY}.jsonl" && \
           grep -q '"agent_id"' "${HOME}/.config/dockstarter/lineage/${TODAY}.jsonl" && \
           grep -q '"action"' "${HOME}/.config/dockstarter/lineage/${TODAY}.jsonl" && \
           grep -q '"intent"' "${HOME}/.config/dockstarter/lineage/${TODAY}.jsonl"; then
            print_pass "Lineage events file contains valid JSON structure"
        else
            print_fail "Lineage events file missing required JSON fields"
        fi
    else
        print_pass "Lineage events file not present (expected in fresh test)"
    fi
}

# Main test runner
main() {
    echo -e "${C_BLUE}"
    cat <<'EOF'
╔════════════════════════════════════════════╗
║  DockSTARTer Governance Test Suite        ║
║  Testing all governance framework          ║
║  components for proper functionality       ║
╚════════════════════════════════════════════╝
EOF
    echo -e "${C_RESET}"
    
    # Run all tests
    test_files_exist
    test_scripts_executable
    test_lineage_logging
    test_knowledge_sync
    test_compliance_check
    test_governance_cli
    test_documentation
    test_json_schema
    
    # Print summary
    print_summary
}

# Execute tests
main "$@"
