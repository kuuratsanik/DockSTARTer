#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

pm_upgrade() {
    # Make sure a compatible package manager is available
    run_script 'pm_check_package_manager'

    run_script "pm_${PM}_upgrade"
}

test_pm_clean() {
    run_script 'pm_upgrade'
}
