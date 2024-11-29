# PHP FPM Pool Optimizer

A simple script to increase the fpm to the optimal number of child processes based on server configuration.

# Key features:

* Dynamically detects PHP version
* Calculates optimal settings based on system memory
* Creates backup before modifications
* Validates configuration before applying
* Restarts PHP-FPM service
* Dry run mode to preview changes

# Usage:

Normal run: `sudo ./fpm_pool_optimizer.sh`

Dry run: `sudo ./fpm_pool_optimizer.sh -n` or `sudo ./fpm_pool_optimizer.sh --dry-run`

The dry run mode prints proposed changes without modifying the configuration.