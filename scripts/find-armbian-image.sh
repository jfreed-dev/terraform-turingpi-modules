#!/bin/bash
#
# Find Armbian Image for Turing RK1
# Queries GitHub releases for the latest Armbian community image
#
# Usage: ./find-armbian-image.sh [OPTIONS]
#
# Options:
#   -v, --variant VARIANT   Image variant: minimal, cli, desktop (default: minimal)
#   -r, --release RELEASE   Debian release: trixie, bookworm (default: trixie)
#   -l, --list              List all available images
#   -d, --download          Download the image
#   -o, --output DIR        Download directory (default: current dir)
#   --autoconfig FILE       Generate autoconfig file for first boot setup
#   --root-password PASS    Root password for autoconfig (default: 1234)
#   --hostname NAME         Hostname for autoconfig
#   --timezone TZ           Timezone for autoconfig (default: UTC)
#   -h, --help              Show this help message

set -euo pipefail

# Default values
VARIANT="minimal"
RELEASE="trixie"
LIST_MODE=false
DOWNLOAD=false
OUTPUT_DIR="."
AUTOCONFIG_FILE=""
ROOT_PASSWORD="1234"
HOSTNAME=""
TIMEZONE="UTC"

# GitHub API
REPO="armbian/community"
API_URL="https://api.github.com/repos/${REPO}/releases"

show_help() {
    head -21 "$0" | tail -18
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--variant) VARIANT="$2"; shift 2 ;;
        -r|--release) RELEASE="$2"; shift 2 ;;
        -l|--list) LIST_MODE=true; shift ;;
        -d|--download) DOWNLOAD=true; shift ;;
        -o|--output) OUTPUT_DIR="$2"; shift 2 ;;
        --autoconfig) AUTOCONFIG_FILE="$2"; shift 2 ;;
        --root-password) ROOT_PASSWORD="$2"; shift 2 ;;
        --hostname) HOSTNAME="$2"; shift 2 ;;
        --timezone) TIMEZONE="$2"; shift 2 ;;
        -h|--help) show_help ;;
        *) echo "Unknown option: $1"; show_help ;;
    esac
done

# Generate autoconfig if requested
if [[ -n "$AUTOCONFIG_FILE" ]]; then
    echo "Generating Armbian autoconfig: $AUTOCONFIG_FILE"
    cat > "$AUTOCONFIG_FILE" << EOF
# Armbian first run configuration
# Place this file at /boot/armbian_first_run.txt on the SD card/eMMC
# See: https://docs.armbian.com/User-Guide_Autoconfig/

# Root password (required for unattended setup)
FR_net_change_defaults=1
FR_general_delete_firstrun_file_after_completion=1

# User credentials
PRESET_ROOT_PASSWORD="${ROOT_PASSWORD}"

# Skip user creation prompt
PRESET_USER_NAME=""

# Locale and timezone
PRESET_LOCALE="en_US.UTF-8"
PRESET_TIMEZONE="${TIMEZONE}"
EOF

    if [[ -n "$HOSTNAME" ]]; then
        echo "" >> "$AUTOCONFIG_FILE"
        echo "# Hostname (set after first boot via hostnamectl)" >> "$AUTOCONFIG_FILE"
        echo "# PRESET_HOSTNAME=\"${HOSTNAME}\"" >> "$AUTOCONFIG_FILE"
        echo "" >> "$AUTOCONFIG_FILE"
        echo "# Note: Hostname is best set via SSH after boot:" >> "$AUTOCONFIG_FILE"
        echo "#   hostnamectl set-hostname ${HOSTNAME}" >> "$AUTOCONFIG_FILE"
    fi

    echo ""
    echo "Autoconfig file created: $AUTOCONFIG_FILE"
    echo ""
    echo "To use with existing installation:"
    echo "  1. Mount the eMMC/SD card on your workstation"
    echo "  2. Copy to /boot/armbian_first_run.txt"
    echo "  3. Boot the node - autoconfig runs on first boot"
    echo ""
    echo "For BMC flash with autoconfig:"
    echo "  1. Flash the image to the node"
    echo "  2. SSH to the node (root:1234 initially)"
    echo "  3. Copy autoconfig: scp $AUTOCONFIG_FILE root@NODE:/boot/armbian_first_run.txt"
    echo "  4. Reboot: ssh root@NODE reboot"
    echo ""

    # Exit if only autoconfig was requested (no image search)
    if [[ "$LIST_MODE" == "false" && "$DOWNLOAD" == "false" ]]; then
        exit 0
    fi
fi

# Check dependencies
if ! command -v jq &>/dev/null; then
    echo "Error: jq is required but not installed"
    exit 1
fi

if ! command -v curl &>/dev/null; then
    echo "Error: curl is required but not installed"
    exit 1
fi

echo "Searching for Armbian Turing RK1 images..."
echo ""

# Fetch releases
RELEASES=$(curl -sL "${API_URL}?per_page=10" 2>/dev/null)

if [[ -z "$RELEASES" || "$RELEASES" == "null" ]]; then
    echo "Error: Failed to fetch releases from GitHub"
    exit 1
fi

# Find Turing RK1 images
if [[ "$LIST_MODE" == "true" ]]; then
    echo "Available Turing RK1 images:"
    echo "----------------------------"

    echo "$RELEASES" | jq -r '
        .[].assets[]
        | select(.name | test("Turing-rk1.*\\.img\\.xz$"))
        | "\(.name)\n  URL: \(.browser_download_url)\n  Size: \(.size / 1048576 | floor)MB\n"
    ' 2>/dev/null || echo "No Turing RK1 images found in recent releases"

    exit 0
fi

# Find matching image
PATTERN="Turing-rk1_${RELEASE}.*${VARIANT}\\.img\\.xz$"
IMAGE_INFO=$(echo "$RELEASES" | jq -r "
    [.[].assets[]
    | select(.name | test(\"${PATTERN}\"; \"i\"))]
    | sort_by(.created_at) | reverse | .[0]
    | {name: .name, url: .browser_download_url, size: .size}
" 2>/dev/null)

if [[ -z "$IMAGE_INFO" || "$IMAGE_INFO" == "null" ]]; then
    echo "No matching image found for:"
    echo "  Variant: $VARIANT"
    echo "  Release: $RELEASE"
    echo ""
    echo "Try: $0 --list"
    exit 1
fi

IMAGE_NAME=$(echo "$IMAGE_INFO" | jq -r '.name')
IMAGE_URL=$(echo "$IMAGE_INFO" | jq -r '.url')
IMAGE_SIZE=$(echo "$IMAGE_INFO" | jq -r '.size / 1048576 | floor')

echo "Found: $IMAGE_NAME"
echo "Size:  ${IMAGE_SIZE}MB"
echo "URL:   $IMAGE_URL"
echo ""

if [[ "$DOWNLOAD" == "true" ]]; then
    echo "Downloading to ${OUTPUT_DIR}/${IMAGE_NAME}..."
    mkdir -p "$OUTPUT_DIR"
    curl -L -o "${OUTPUT_DIR}/${IMAGE_NAME}" "$IMAGE_URL"
    echo ""
    echo "Download complete: ${OUTPUT_DIR}/${IMAGE_NAME}"
else
    echo "To download: $0 -v $VARIANT -r $RELEASE --download"
    echo ""
    echo "Or use directly with BMC flash API:"
    echo "  curl -sk -u USER:PASS \"https://BMC_IP/api/bmc?opt=set&type=flash&node=N&file=${IMAGE_URL}\""
fi
