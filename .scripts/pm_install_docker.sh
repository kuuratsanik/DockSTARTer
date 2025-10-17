#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

pm_install_docker() {
    # Make sure a compatible package manager is available
    run_script 'pm_check_package_manager'

    run_script "pm_${PM}_install_docker"
}

test_pm_clean() {
    run_script 'pm_install_docker'
}
