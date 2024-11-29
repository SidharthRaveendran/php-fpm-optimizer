#!/bin/bash

# Ensure script is run with root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Configuration paths
PHP_VERSION=$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d".")
POOL_CONFIG="/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"

# System resources
TOTAL_MEMORY=$(free -m | awk '/^Mem:/{print $2}')
CPU_CORES=$(nproc)

# Dry run flag
DRY_RUN=0

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -n|--dry-run) DRY_RUN=1 ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Optimize function
optimize_fpm_pool() {
    # Calculate optimal settings
    MAX_CHILDREN=$((TOTAL_MEMORY / 64))
    START_SERVERS=$((MAX_CHILDREN / 4))
    MIN_SPARE_SERVERS=$((MAX_CHILDREN / 10))
    MAX_SPARE_SERVERS=$((MAX_CHILDREN / 3))

    # Dry run: only print proposed changes
    if [[ $DRY_RUN -eq 1 ]]; then
        echo "PROPOSED PHP-FPM POOL CONFIGURATION:"
        echo "Current PHP Version: ${PHP_VERSION}"
        echo "Total Memory: ${TOTAL_MEMORY}MB"
        echo "CPU Cores: ${CPU_CORES}"
        echo ""
        echo "Proposed Changes:"
        echo "pm = dynamic"
        echo "pm.max_children = ${MAX_CHILDREN}"
        echo "pm.start_servers = ${START_SERVERS}"
        echo "pm.min_spare_servers = ${MIN_SPARE_SERVERS}"
        echo "pm.max_spare_servers = ${MAX_SPARE_SERVERS}"
        echo "pm.process_idle_timeout = 10s"
        echo "pm.max_requests = 500"
        return 0
    fi

    # Backup original configuration
    cp "$POOL_CONFIG" "${POOL_CONFIG}.bak"

    # Update configuration
    sed -i "s/^pm = .*/pm = dynamic/" "$POOL_CONFIG"
    sed -i "s/^pm.max_children = .*/pm.max_children = ${MAX_CHILDREN}/" "$POOL_CONFIG"
    sed -i "s/^pm.start_servers = .*/pm.start_servers = ${START_SERVERS}/" "$POOL_CONFIG"
    sed -i "s/^pm.min_spare_servers = .*/pm.min_spare_servers = ${MIN_SPARE_SERVERS}/" "$POOL_CONFIG"
    sed -i "s/^pm.max_spare_servers = .*/pm.max_spare_servers = ${MAX_SPARE_SERVERS}/" "$POOL_CONFIG"

    # Additional optimizations
    sed -i "s/^;pm.process_idle_timeout = .*/pm.process_idle_timeout = 10s/" "$POOL_CONFIG"
    sed -i "s/^;pm.max_requests = .*/pm.max_requests = 500/" "$POOL_CONFIG"
}

# Validate configuration
validate_config() {
    php-fpm -t
    return $?
}

# Restart service
restart_service() {
    systemctl restart php${PHP_VERSION}-fpm
}

# Main execution
main() {
    optimize_fpm_pool

    # Skip further actions in dry run mode
    [[ $DRY_RUN -eq 1 ]] && exit 0

    if validate_config; then
        echo "Configuration validated successfully"
        restart_service
        echo "PHP-FPM service restarted"
    else
        echo "Configuration validation failed. Reverting to backup"
        mv "${POOL_CONFIG}.bak" "$POOL_CONFIG"
        exit 1
    fi
}

main