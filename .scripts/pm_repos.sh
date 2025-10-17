#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

pm_repos() {
    # Make sure a compatible package manager is available
    run_script 'pm_check_package_manager'

    run_script "pm_${PM}_repos"
}

test_pm_repos() {
    run_script 'pm_repos'
}
