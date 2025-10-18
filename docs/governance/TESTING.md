# Governance Framework Testing Guide

**Version**: 1.0.0  
**Last Updated**: October 18, 2025  
**Status**: ✅ All Tests Passing

---

## Overview

This document describes the testing strategy and procedures for validating the DockSTARTer governance framework. All governance components have been tested and are functioning correctly.

---

## Test Suite

The comprehensive test suite is located at `.scripts/test_governance.sh` and validates all governance framework components.

### Running Tests

```bash
# Run full test suite
bash .scripts/test_governance.sh

# Expected output: All tests passed!
```

---

## Test Coverage

### Test 1: Governance Files Existence (12 tests)
Validates that all required governance files exist:
- ✅ POLICIES.md
- ✅ .github/copilot-instructions.md
- ✅ docs/governance/README.md
- ✅ docs/governance/QUICK_START.md
- ✅ docs/governance/ROADMAP.md
- ✅ docs/governance/compliance/README.md
- ✅ docs/governance/lineage/README.md
- ✅ docs/governance/lineage/TEMPLATE.json
- ✅ .scripts/lineage_log.sh
- ✅ .scripts/knowledge_sync.sh
- ✅ .scripts/compliance_check.sh
- ✅ .scripts/governance_cli.sh

### Test 2: Script Permissions (4 tests)
Verifies all governance scripts are executable:
- ✅ lineage_log.sh is executable
- ✅ knowledge_sync.sh is executable
- ✅ compliance_check.sh is executable
- ✅ governance_cli.sh is executable

### Test 3: Lineage Logging (4 tests)
Tests lineage event logging functionality:
- ✅ Script executes successfully
- ✅ Lineage directory created at `~/.config/dockstarter/lineage/`
- ✅ Event file created with current date
- ✅ JSON structure contains required fields (timestamp, agent_id, action, etc.)

### Test 4: Knowledge Sync (3 tests)
Tests knowledge synchronization system:
- ✅ Initialization succeeds
- ✅ Knowledge directory created at `~/.config/dockstarter/knowledge/`
- ✅ Status command works

### Test 5: Compliance Checking (4 tests)
Tests compliance audit functionality:
- ✅ Docker security check succeeds
- ✅ Privacy compliance check succeeds
- ✅ Full compliance report generation succeeds
- ✅ Report file created at `~/.config/dockstarter/compliance/report_YYYY-MM-DD.json`

### Test 6: Governance CLI (4 tests)
Tests the unified CLI interface:
- ✅ Help command works
- ✅ Initialization command works
- ✅ Status command works
- ✅ Directory structure created correctly

### Test 7: Documentation Validation (3 tests)
Validates documentation structure:
- ✅ POLICIES.md contains required sections (Infrastructure, Blockchain/DAO, AI Lifecycle)
- ✅ copilot-instructions.md references POLICIES.md
- ✅ mkdocs.yml includes Governance section

### Test 8: JSON Schema Validation (2 tests)
Validates JSON schema compliance:
- ✅ TEMPLATE.json is valid JSON
- ✅ Lineage event files contain valid JSON structure

---

## Test Results Summary

**Total Tests**: 36  
**Passed**: 36  
**Failed**: 0  
**Success Rate**: 100%

---

## Manual Testing Procedures

### Testing Lineage Logging

```bash
# Source the lineage_log function
source .scripts/lineage_log.sh

# Log a test event
lineage_log \
  "code_modification" \
  "Testing lineage logging functionality" \
  '["test.sh"]' \
  "7.3 Auditability" \
  "compliant" \
  "manual-test"

# Verify event was logged
cat ~/.config/dockstarter/lineage/$(date -u +%Y-%m-%d).jsonl
```

### Testing Compliance Checks

```bash
# Run individual compliance checks
bash .scripts/compliance_check.sh docker
bash .scripts/compliance_check.sh privacy
bash .scripts/compliance_check.sh lineage
bash .scripts/compliance_check.sh healing

# Run full compliance report
bash .scripts/compliance_check.sh report

# View report
cat ~/.config/dockstarter/compliance/report_$(date -u +%Y-%m-%d).json
```

### Testing Knowledge Sync

```bash
# Initialize knowledge sync
bash .scripts/knowledge_sync.sh init

# Check status
bash .scripts/knowledge_sync.sh status

# Note: Full sync requires internet access to CVE feeds
# This is skipped in automated tests
```

### Testing Governance CLI

```bash
# Initialize governance infrastructure
bash .scripts/governance_cli.sh init

# View status dashboard
bash .scripts/governance_cli.sh status

# Run compliance audit
bash .scripts/governance_cli.sh compliance

# View policy information
bash .scripts/governance_cli.sh policy
```

---

## Integration Testing

### With Docker Compose

The governance framework integrates with DockSTARTer's Docker Compose workflow:

```bash
# Before deploying containers, run compliance check
bash .scripts/governance_cli.sh compliance

# Log deployment as lineage event
source .scripts/lineage_log.sh
lineage_log "deployment" "Deployed Plex container" '["compose/plex.yml"]' "4.1 Auto-Healing" "compliant" "docker-compose-up"
```

### With CI/CD

Future integration with GitHub Actions:
- Pre-commit hooks for lineage logging
- Automated compliance checks on PR
- Security scanning integration
- Policy validation

---

## Troubleshooting

### Permission Errors

If tests fail due to permissions:

```bash
# Fix script permissions
chmod +x .scripts/*.sh

# Fix config directory permissions
chmod -R 755 ~/.config/dockstarter/
```

### Missing Dependencies

The test suite requires:
- `bash` (v4.0+)
- `python3` (for JSON validation)
- Standard Unix tools: `grep`, `date`, `mkdir`, `cat`

### Test Failures

If a specific test fails:

1. Run the test script with debug output:
   ```bash
   bash -x .scripts/test_governance.sh 2>&1 | less
   ```

2. Check specific component:
   ```bash
   # Test individual script
   bash .scripts/lineage_log.sh
   bash .scripts/knowledge_sync.sh init
   bash .scripts/compliance_check.sh docker
   ```

3. Verify file structure:
   ```bash
   ls -la docs/governance/
   ls -la .scripts/
   ls -la ~/.config/dockstarter/
   ```

---

## Continuous Testing

### Scheduled Testing

Recommended cron schedule for ongoing validation:

```bash
# Daily compliance checks (6 AM UTC)
0 6 * * * cd /path/to/DockSTARTer && bash .scripts/governance_cli.sh compliance

# Weekly full test suite (Sunday 2 AM UTC)
0 2 * * 0 cd /path/to/DockSTARTer && bash .scripts/test_governance.sh
```

### Pre-commit Testing

Recommended Git hook:

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Run governance tests before commit
if ! bash .scripts/test_governance.sh; then
    echo "Governance tests failed. Commit aborted."
    exit 1
fi
```

---

## Test Maintenance

### Adding New Tests

When adding new governance features:

1. Add test to `.scripts/test_governance.sh`
2. Follow existing test pattern:
   ```bash
   test_new_feature() {
       print_header "Test N: Feature Name"
       
       print_test "Testing feature"
       if feature_works; then
           print_pass "Feature works"
       else
           print_fail "Feature failed"
       fi
   }
   ```
3. Add to main test runner
4. Update this documentation

### Updating Tests

When governance framework changes:

1. Review affected tests
2. Update test expectations
3. Run full test suite
4. Update documentation
5. Commit changes with lineage event

---

## Compliance Validation

The test suite validates compliance with:

- **POLICIES.md Section 7.3**: Auditability (lineage logging)
- **POLICIES.md Section 5.1**: EU AI Act alignment (compliance checks)
- **POLICIES.md Section 6.1**: Knowledge management (sync functionality)
- **POLICIES.md Section 10**: Implementation & enforcement

---

## Security Testing

### Static Analysis

```bash
# Check scripts with ShellCheck
shellcheck .scripts/*.sh

# Validate JSON schemas
python3 -m json.tool docs/governance/lineage/TEMPLATE.json
```

### Dynamic Analysis

The test suite performs runtime validation:
- Creates actual lineage events
- Generates real compliance reports
- Tests directory creation
- Validates file permissions

---

## Performance Benchmarks

Test suite execution time:
- **Full suite**: ~2-3 seconds
- **Individual tests**: <0.5 seconds each
- **Lineage logging**: <0.1 seconds per event
- **Compliance check**: ~1 second

---

## Known Limitations

1. **Internet Access**: Full knowledge sync requires internet (skipped in automated tests)
2. **Docker Dependency**: Some compliance checks require Docker to be running
3. **Python Dependency**: JSON validation requires Python 3.6+

---

## Next Steps

Future testing enhancements:

1. **Integration Tests**: Test with actual Docker containers
2. **Load Tests**: Validate performance under high event volume
3. **Security Tests**: Penetration testing, vulnerability scanning
4. **End-to-End Tests**: Full workflow from deployment to audit
5. **Regression Tests**: Prevent policy violations from recurring

---

## Support

For testing issues:
- **GitHub Issues**: Use `testing` label
- **Documentation**: See `docs/governance/README.md`
- **Test Failures**: Create issue with full test output

---

**Remember**: Testing is not just validation—it's documentation of expected behavior and a safety net for future changes.

---

*Last Tested*: October 18, 2025  
*Test Suite Version*: 1.0.0  
*All Tests Passing*: ✅
