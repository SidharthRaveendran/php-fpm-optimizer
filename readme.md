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

Download the file: `curl -O https://raw.githubusercontent.com/SidharthRaveendran/php-fpm-optimizer/refs/heads/master/main.sh`

Normal run: `sudo bash ./main.sh`

Dry run: `sudo bash ./main.sh -n` or `sudo bash ./main.sh --dry-run`

The dry run mode prints proposed changes without modifying the configuration.