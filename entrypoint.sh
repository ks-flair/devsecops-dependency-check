#!/bin/bash
set -euo pipefail

log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1"
}

log_warn() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $1" >&2
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" >&2
}

# Function to setup environment
setup_environment() {
    log_info "Setting up container environment..."
    
    # Set working directory
    cd /workspace
    
    # Check if we're running as non-root and switch if needed
    if [ "$(id -u)" = "0" ] && [ -n "${RUN_AS_USER:-}" ]; then
        log_info "Switching to user: $RUN_AS_USER"
        exec gosu "$RUN_AS_USER" "$@"
    fi
    
    log_info "Environment setup complete"
}

# Main entrypoint logic
main() {
    
    # Setup environment
    setup_environment
    
    # If arguments are provided, execute them
    if [ $# -gt 0 ]; then
        log_info "Executing command: $*"
        exec "$@"
    else
        # Default behavior: start interactive shell
        log_info "No command provided, starting interactive shell"
        exec /bin/bash
    fi
}

# Execute main function with all arguments
main "$@" 
