#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

declare Title="Install Dependencies"

pm_nala_install() {
    if use_dialog_box; then
        coproc {
            dialog_pipe "${DC["TitleSuccess"]-}${Title}" "Please be patient, this can take a while.\n${DC["CommandLine"]-} ${APPLICATION_COMMAND} --install" ""
        }
        local -i DialogBox_PID=${COPROC_PID}
        local -i DialogBox_FD="${COPROC[1]}"
        pm_nala_install_commands >&${DialogBox_FD} 2>&1
        exec {DialogBox_FD}<&-
        wait ${DialogBox_PID}
    else
        pm_nala_install_commands
    fi
}

pm_nala_install_commands() {
    local Command=""

    local REDIRECT='> /dev/null 2>&1 '
    if [[ -n ${VERBOSE-} ]]; then
        REDIRECT='2>&1 '
    fi

    local -a Dependencies=("${PM_COMMAND_DEPS[@]}")
    if [[ ${FORCE-} != true ]]; then
        for index in "${!Dependencies[@]}"; do
            if pm_check_dependency "${Dependencies[index]}"; then
                unset 'Dependencies[index]'
            fi
        done
        Dependencies=("${Dependencies[@]}")
    fi
    if [[ ${#Dependencies[@]} -eq 0 ]]; then
        notice "All dependencies have already been installed."
    else
        #shellcheck disable=SC2124 #Assigning an array to a string! Assign as array, or use * instead of @ to concatenate.
        local deplist="${Dependencies[@]}"
        deplist="${deplist// /${NC}\', \'${C["Program"]}}"
        deplist="${NC}'${C["Program"]}${deplist}${NC}'"
        notice "Installing dependencies: ${deplist}"

        if [[ -z "$(command -v apt-file)" ]]; then
            info "Installing '${C["Program"]}apt-file${NC}'."
            Command="sudo nala install --no-update -y apt-file"
            notice "Running: ${C["RunningCommand"]}${Command}${NC}"
            eval "${REDIRECT}${Command}" ||
                fatal "Failed to install '${C["Program"]}apt-file${NC}' from apt.\nFailing command: ${C["FailingCommand"]}${Command}"
        fi
        notice "Updating package information."
        Command='sudo apt-file update'
        notice "Running: ${C["RunningCommand"]}${Command}${NC}"
        eval "${REDIRECT}${Command}" ||
            fatal "Failed to get updates from apt.\nFailing command: ${C["FailingCommand"]}${Command}"

        notice "Determining packages to install."
        local -a Packages
        readarray -t Packages < <(detect_packages "${Dependencies[@]}")

        if [[ ${#Packages[@]} -eq 0 ]]; then
            notice "No packages found to install."
        else
            #shellcheck disable=SC2124 #Assigning an array to a string! Assign as array, or use * instead of @ to concatenate.
            local PackagesString="${Packages[@]}"
            local pkglist="${PackagesString// /${NC}\', \'${C["Program"]}}"
            pkglist="${NC}'${C["Program"]}${pkglist}${NC}'"
            notice "Installing packages: ${pkglist}"
            Command="sudo nala install --no-update -y ${PackagesString}"
            notice "Running: ${C["RunningCommand"]}${Command}${NC}"
            eval "${REDIRECT}${Command}" ||
                fatal "Failed to install dependencies from nala.\nFailing command: ${C["FailingCommand"]}${Command}"
        fi
    fi
}

detect_packages() {
    local -a Dependencies=("$@")

    Old_IFS="${IFS}"
    IFS='|'
    RegEx_Dependencies="(${Dependencies[*]})"
    RegEx_Package_Blacklist="(${PM_PACKAGE_BLACKLIST[*]-})"
    IFS="${Old_IFS}"

    local RegEx_AptFile="^(.*):.*/s?bin/${RegEx_Dependencies}$"

    for Dep in "${Dependencies[@]}"; do
        if [[ -v PM_DEP_PACKAGE["${Dep}"] ]]; then
            echo "${PM_DEP_PACKAGE["${Dep}"]}"
        else
            local Command="apt-file search bin/${Dep}"
            notice "Running: ${C["RunningCommand"]}${Command}${NC}"
            eval "${Command}" 2> /dev/null
        fi
    done | while IFS= read -r line; do
        if [[ ${line} =~ ${RegEx_AptFile} ]]; then
            local Package="${BASH_REMATCH[1]}"
            if [[ ! ${Package} =~ ^${RegEx_Package_Blacklist}$ ]]; then
                echo "${Package}"
            fi
        fi
    done | sort -u
}

test_pm_nala_install() {
    #run_script 'pm_nala_repos'
    #run_script 'pm_nala_install'
    warn "CI does not test pm_nala_install."
}
