#!/usr/bin/env bash
set -euo pipefail

check_command() {
    local command_name="$1"
    if command -v "$command_name" >/dev/null 2>&1; then
        printf 'FOUND  %-10s %s\n' "$command_name" "$(command -v "$command_name")"
    else
        printf 'MISSING %-10s\n' "$command_name"
        return 1
    fi
}

printf '\nminhttpd development environment check\n'
printf '%s\n' '-------------------------------------'

failures=0
for command_name in clang++ cmake ninja git; do
    check_command "$command_name" || failures=$((failures + 1))
done

if command -v clang++ >/dev/null 2>&1; then
    printf '\nCompiler:\n'
    clang++ --version | head -n 1
fi

if command -v cmake >/dev/null 2>&1; then
    printf '\nCMake:\n'
    cmake --version | head -n 1
fi

if command -v ninja >/dev/null 2>&1; then
    printf '\nNinja:\n'
    ninja --version
fi

if command -v xcode-select >/dev/null 2>&1; then
    printf '\nApple developer directory:\n'
    xcode-select -p 2>/dev/null || printf '%s\n' 'Not selected; install/select Xcode Command Line Tools.'
fi

printf '\n'
if (( failures > 0 )); then
    printf 'Environment check found %d missing required tool(s).\n' "$failures"
    exit 1
fi

printf '%s\n' 'All required commands are available.'
