# Compliance Documentation

This directory contains compliance reports, certifications, and audit documentation for the DockSTARTer project.

---

## Current Compliance Status

| Framework | Status | Last Audit | Next Review |
|-----------|--------|------------|-------------|
| **GDPR** | ✅ Compliant | 2025-10-18 | 2026-01-18 |
| **EU AI Act** | ✅ Compliant | 2025-10-18 | 2026-01-18 |
| **Estonia e-Gov** | 🟡 In Progress | N/A | 2026-04-18 |
| **ISO 27001** | 🔜 Planned | N/A | TBD |
| **SOC 2 Type II** | 🔜 Planned | N/A | TBD |

**Legend:**
- ✅ Compliant: Fully implemented and audited
- 🟡 In Progress: Partial implementation
- 🔜 Planned: On roadmap
- ❌ Non-Compliant: Identified gaps

---

## GDPR Compliance

### Data Processing Inventory
- **Personal Data Collected**: User emails (optional, for newsletter), IP addresses (anonymized logs)
- **Purpose**: Service operation, security monitoring
- **Lawful Basis**: Legitimate interest (GDPR Art. 6(1)(f))
- **Retention**: 90 days for logs, indefinite for user-provided config (user-controlled)
- **Third Parties**: None (self-hosted only)

### User Rights Implementation
- ✅ **Right to Access** (Art. 15): Users control all config files
- ✅ **Right to Erasure** (Art. 17): Delete config files = data deletion
- ✅ **Right to Portability** (Art. 20): Standard Docker Compose format
- ✅ **Right to Object** (Art. 21): Opt-out of telemetry (default: no telemetry)

### Technical Measures
- ✅ **Encryption at Rest**: Optional via LUKS/ZFS encryption
- ✅ **Encryption in Transit**: TLS 1.3 for all external connections
- ✅ **Access Controls**: File-based permissions, container isolation
- ✅ **Audit Logging**: All operations logged (see `lineage/`)

---

## EU AI Act Compliance

### AI System Classification
| Component | Classification | Risk Level | Conformity Requirement |
|-----------|----------------|------------|------------------------|
| **GitHub Copilot** | GPAI (General Purpose AI) | Limited | Transparency notice |
| **Master Management AI** | High-Risk (infrastructure automation) | High | Third-party assessment |
| **CEO/Super-CEO AI** | High-Risk (governance automation) | High | Third-party assessment |
| **Specialized Teams** | Limited Risk (task automation) | Limited | Self-assessment |

### Conformity Assessment
- **High-Risk Systems**: Scheduled for Q1 2026 third-party audit
- **Documentation**: Technical documentation in `POLICIES.md`
- **Risk Assessment**: See [risk-assessment-2025.md](./risk-assessment-2025.md) (TODO)

### Transparency Requirements
- ✅ **User Notification**: Users informed of AI agent involvement
- ✅ **Human Oversight**: Human stewards have override authority
- ✅ **Auditability**: Full lineage logging implemented

---

## Estonia e-Residency Optimization

### Current Integration
- 🟡 **Digital Signatures**: Blockchain-anchored (not yet X-Road compatible)
- 🟡 **e-ID Support**: Planned for Q2 2026
- 🟡 **X-Road Integration**: Planned for Q3 2026

### Roadmap
1. **Q1 2026**: Implement X-Road adapter for secure data exchange
2. **Q2 2026**: Add e-ID authentication for governance actions
3. **Q3 2026**: Full X-Road compliance for cross-border data sharing
4. **Q4 2026**: Estonia e-Residency API integration

---

## Security Certifications

### Planned Certifications
1. **ISO 27001** (Information Security Management)
   - Target: Q2 2026
   - Scope: Infrastructure, data processing, incident response
   
2. **SOC 2 Type II** (Service Organization Controls)
   - Target: Q4 2026
   - Scope: Security, availability, confidentiality

3. **CIS Benchmarks** (Center for Internet Security)
   - Target: Q1 2026
   - Scope: Docker, Kubernetes, Linux hardening

---

## Audit Reports

### Internal Audits
- **Frequency**: Quarterly
- **Next Audit**: January 18, 2026
- **Responsible**: Compliance Team (AI) + Human Stewards

### External Audits
- **Frequency**: Annual
- **Next Audit**: October 18, 2026 (EU AI Act conformity)
- **Auditor**: TBD

### Audit Artifacts
- [Quarterly Compliance Report Template](./templates/quarterly-report.md) (TODO)
- [Incident Response Playbook](./incident-response-playbook.md) (TODO)
- [Data Breach Notification Procedure](./data-breach-procedure.md) (TODO)

---

## Compliance Contacts

### Data Protection Officer (DPO)
- **Role**: Oversee GDPR compliance
- **Contact**: TBD (human steward)
- **Backup**: Compliance Team (AI)

### AI Ethics Officer
- **Role**: Oversee EU AI Act compliance
- **Contact**: Super-CEO AI Agent
- **Backup**: Human Stewards

### Security Officer
- **Role**: Oversee security certifications
- **Contact**: Security Team (AI)
- **Escalation**: Master Management Super-AI Team

---

## Compliance Automation

### Automated Checks
- ✅ **Daily**: Vulnerability scanning (Trivy, Grype)
- ✅ **Weekly**: Dependency updates (Dependabot)
- ✅ **Monthly**: Policy compliance audit
- ✅ **Quarterly**: Comprehensive compliance review

### Tools & Services
- **Vulnerability Scanning**: Trivy, Snyk
- **SBOM Generation**: Syft
- **License Compliance**: FOSSA (future)
- **GDPR Compliance**: Custom scripts + manual review

---

## Non-Compliance Handling

### Escalation Path
1. **Detection**: Automated monitoring or manual report
2. **Assessment**: Compliance Team evaluates severity
3. **Remediation**: Issue fix within SLA (critical: 24h, high: 7d, medium: 30d)
4. **Verification**: Post-fix audit
5. **Documentation**: Update lineage log and compliance report

### Severity Levels
- **Critical**: Data breach, high-risk AI system failure → 24h SLA
- **High**: GDPR violation, security vulnerability → 7d SLA
- **Medium**: Documentation gap, minor policy deviation → 30d SLA
- **Low**: Cosmetic issue, optimization opportunity → 90d SLA

---

## Resources

### External Standards
- [GDPR Official Text](https://gdpr.eu/)
- [EU AI Act (Regulation 2024/1689)](https://eur-lex.europa.eu/eli/reg/2024/1689/oj)
- [Estonia e-Gov Academy](https://ega.ee/e-governance/)
- [ISO 27001 Standards](https://www.iso.org/isoiec-27001-information-security.html)
- [SOC 2 Framework](https://www.aicpa.org/interestareas/frc/assuranceadvisoryservices/aicpasoc2report.html)

### Internal Documentation
- [Project Governance Charter](../../POLICIES.md)
- [Lineage Event Logs](../lineage/)
- [Governance Overview](../README.md)

---

**For compliance questions, file a GitHub issue with the `compliance` label.**

**Data subject requests**: Contact DPO (TBD) or file via GitHub (for self-hosted config deletion).

---

*Last Updated: October 18, 2025*  
*Next Review: January 18, 2026*
