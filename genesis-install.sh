#!/data/data/com.termux/files/usr/bin/bash

# ============================================================================
# GENESIS Engine - Self-Healing Installation Script
# Automatically detects and fixes errors during installation
# ============================================================================

set -u  # Exit on undefined variables
IFS=$'\n\t'

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
LOG_FILE="/tmp/genesis-install-$(date +%Y%m%d-%H%M%S).log"
STATE_FILE="$HOME/.genesis-install-state"
MAX_RETRIES=3
RETRY_DELAY=5

# ============================================================================
# Core Functions
# ============================================================================

log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

print_header() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   ██████╗ ███████╗███╗   ██╗███████╗███████╗██╗███████╗     ║
║  ██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔════╝██║██╔════╝     ║
║  ██║  ███╗█████╗  ██╔██╗ ██║█████╗  ███████╗██║███████╗     ║
║  ██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ╚════██║██║╚════██║     ║
║  ╚██████╔╝███████╗██║ ╚████║███████╗███████║██║███████║     ║
║   ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚══════╝╚═╝╚══════╝     ║
║                                                               ║
║     Self-Healing Installation System v2.0 (Termux)          ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    log "INFO" "Starting GENESIS Engine installation"
}

# Retry mechanism with exponential backoff
retry_with_backoff() {
    local max_attempts=$1
    local delay=$2
    local description=$3
    shift 3
    local attempt=1
    local exit_code=0

    while [ $attempt -le $max_attempts ]; do
        log "INFO" "$description (attempt $attempt/$max_attempts)"
        
        if "$@" 2>&1 | tee -a "$LOG_FILE"; then
            log "SUCCESS" "$description completed"
            return 0
        fi
        
        exit_code=$?
        
        if [ $attempt -lt $max_attempts ]; then
            local wait_time=$((delay * attempt))
            log "WARN" "$description failed (exit code: $exit_code), retrying in ${wait_time}s..."
            sleep $wait_time
        fi
        
        attempt=$((attempt + 1))
    done
    
    log "ERROR" "$description failed after $max_attempts attempts"
    return $exit_code
}

# Mark step as completed
mark_complete() {
    echo "$1" >> "$STATE_FILE"
    log "INFO" "Step completed: $1"
}

# Check if step already completed
is_complete() {
    grep -q "^$1$" "$STATE_FILE" 2>/dev/null
}

# Safe package installation with retry
safe_pkg_install() {
    local package=$1
    
    if is_complete "pkg_$package"; then
        log "INFO" "Package $package already installed"
        return 0
    fi
    
    retry_with_backoff 3 5 "Installing package: $package" pkg install -y "$package"
    
    if [ $? -eq 0 ]; then
        mark_complete "pkg_$package"
        return 0
    else
        log "ERROR" "Failed to install $package, trying alternative methods..."
        pkg update -y && pkg install -y "$package" && mark_complete "pkg_$package"
    fi
}

# Safe pip installation with fallbacks
safe_pip_install() {
    local package=$1
    local pip_name=${2:-$package}
    
    if is_complete "pip_$package"; then
        log "INFO" "Python package $package already installed"
        return 0
    fi
    
    # Try regular installation first
    if pip install "$pip_name" 2>&1 | tee -a "$LOG_FILE"; then
        mark_complete "pip_$package"
        return 0
    fi
    
    log "WARN" "Standard pip install failed for $package, trying alternatives..."
    
    # Try with --no-build-isolation for problematic packages
    if pip install --no-build-isolation "$pip_name" 2>&1 | tee -a "$LOG_FILE"; then
        mark_complete "pip_$package"
        return 0
    fi
    
    # Try installing from wheel only
    if pip install --only-binary :all: "$pip_name" 2>&1 | tee -a "$LOG_FILE"; then
        mark_complete "pip_$package"
        return 0
    fi
    
    # Last resort: skip this package
    log "ERROR" "Could not install $package, marking as skipped"
    mark_complete "pip_${package}_skipped"
    return 1
}

# ============================================================================
# Installation Steps
# ============================================================================

step_1_system_check() {
    echo -e "\n${BLUE}[1/10]${NC} System requirements check..."
    
    # Ensure we're in Termux home
    cd "$HOME" || {
        log "ERROR" "Cannot access home directory"
        exit 1
    }
    
    log "INFO" "Working directory: $(pwd)"
    log "INFO" "Termux version: $(termux-info 2>/dev/null | head -1 || echo 'unknown')"
    
    mark_complete "step_1"
}

step_2_update_packages() {
    echo -e "\n${BLUE}[2/10]${NC} Updating package repositories..."
    
    if is_complete "step_2"; then
        log "INFO" "Package repositories already updated"
        return 0
    fi
    
    retry_with_backoff 3 10 "Updating package repositories" pkg update -y
    mark_complete "step_2"
}

step_3_install_system_deps() {
    echo -e "\n${BLUE}[3/10]${NC} Installing system dependencies..."
    
    # Critical packages
    safe_pkg_install "python"
    safe_pkg_install "git"
    safe_pkg_install "rust"
    safe_pkg_install "docker"
    
    # Build tools for Python packages
    safe_pkg_install "libyaml"
    safe_pkg_install "binutils"
    safe_pkg_install "clang"
    
    mark_complete "step_3"
}

step_4_setup_rust() {
    echo -e "\n${BLUE}[4/10]${NC} Configuring Rust toolchain..."
    
    if is_complete "step_4"; then
        log "INFO" "Rust already configured"
        return 0
    fi
    
    # Initialize rustup if needed
    if ! command -v rustup &>/dev/null; then
        log "INFO" "Installing rustup..."
        rustup-init -y 2>&1 | tee -a "$LOG_FILE"
    fi
    
    # Set default toolchain
    source "$HOME/.cargo/env" 2>/dev/null || true
    
    if command -v rustup &>/dev/null; then
        retry_with_backoff 3 5 "Setting Rust default toolchain" rustup default stable
        mark_complete "step_4"
    else
        log "WARN" "Rustup not available, some packages may fail to install"
        mark_complete "step_4_partial"
    fi
}

step_5_start_docker() {
    echo -e "\n${BLUE}[5/10]${NC} Starting Docker daemon..."
    
    # Kill any existing dockerd
    pkill dockerd 2>/dev/null || true
    sleep 2
    
    # Clean up old socket
    rm -f /data/data/com.termux/files/usr/var/run/docker.sock 2>/dev/null
    
    # Start Docker daemon
    log "INFO" "Launching dockerd..."
    dockerd --iptables=false &> /tmp/dockerd.log &
    
    # Wait for Docker to be ready
    local attempts=0
    while [ $attempts -lt 15 ]; do
        if docker ps &>/dev/null; then
            log "SUCCESS" "Docker daemon is ready"
            mark_complete "step_5"
            return 0
        fi
        attempts=$((attempts + 1))
        sleep 2
    done
    
    log "ERROR" "Docker failed to start. Check /tmp/dockerd.log"
    cat /tmp/dockerd.log | tail -20 >> "$LOG_FILE"
    return 1
}

step_6_init_swarm() {
    echo -e "\n${BLUE}[6/10]${NC} Initializing Docker Swarm..."
    
    if is_complete "step_6"; then
        log "INFO" "Swarm already initialized"
        return 0
    fi
    
    if docker info 2>/dev/null | grep -q "Swarm: active"; then
        log "SUCCESS" "Swarm is active"
        mark_complete "step_6"
        return 0
    fi
    
    # Try to initialize swarm
    docker swarm init --advertise-addr 127.0.0.1 2>&1 | tee -a "$LOG_FILE" || \
    docker swarm init 2>&1 | tee -a "$LOG_FILE" || {
        log "WARN" "Swarm initialization failed, but continuing..."
        mark_complete "step_6_skipped"
        return 0
    }
    
    mark_complete "step_6"
}

step_7_create_project_structure() {
    echo -e "\n${BLUE}[7/10]${NC} Creating project structure..."
    
    if is_complete "step_7"; then
        log "INFO" "Project structure already exists"
        return 0
    fi
    
    cd "$HOME"
    
    # Create or enter genesis_engine directory
    if [ -d "genesis_engine" ]; then
        log "INFO" "Using existing genesis_engine directory"
        cd genesis_engine
    else
        mkdir -p genesis_engine
        cd genesis_engine
    fi
    
    # Create subdirectories
    mkdir -p agents orchestrator memory tests/{unit,integration,e2e}
    mkdir -p scripts genesis_builds docs .devcontainer
    
    log "INFO" "Project structure created in: $(pwd)"
    mark_complete "step_7"
}

step_8_install_python_deps() {
    echo -e "\n${BLUE}[8/10]${NC} Installing Python dependencies..."
    
    # Core dependencies (order matters!)
    safe_pip_install "openai"
    safe_pip_install "docker"
    safe_pip_install "pydantic"
    safe_pip_install "redis"
    safe_pip_install "psutil"
    
    # Development tools (can fail without breaking system)
    safe_pip_install "pytest"
    
    # Ruff needs Rust - try but don't fail if it doesn't work
    if command -v rustup &>/dev/null; then
        safe_pip_install "ruff" || log "WARN" "Ruff installation failed, continuing without it"
    else
        log "INFO" "Skipping ruff (requires Rust)"
    fi
    
    mark_complete "step_8"
}

step_9_create_config_files() {
    echo -e "\n${BLUE}[9/10]${NC} Creating configuration files..."
    
    if is_complete "step_9"; then
        log "INFO" "Configuration files already exist"
        return 0
    fi
    
    # .env file
    if [ ! -f .env ]; then
        cat > .env << 'ENV'
OPENAI_API_KEY=sk-your-key-here
VAULT_ADDR=http://localhost:8200
VAULT_TOKEN=your-vault-token
ENV
        log "INFO" "Created .env file"
    fi
    
    # pyproject.toml
    cat > pyproject.toml << 'PYPROJECT'
[project]
name = "genesis-engine"
version = "1.0.0"
description = "Autonomous AI development engine"
requires-python = ">=3.11"

[tool.ruff]
line-length = 100

[tool.pytest.ini_options]
testpaths = ["tests"]
PYPROJECT
    
    # .gitignore
    cat > .gitignore << 'GITIGNORE'
__pycache__/
*.py[cod]
.venv/
*.egg-info/
genesis_builds/
*.log
.env
.coverage
GITIGNORE
    
    # Base agent template
    mkdir -p agents
    cat > agents/base_agent.py << 'AGENT'
"""Base agent for GENESIS Engine"""

class BaseAgent:
    def __init__(self, api_key: str):
        self.api_key = api_key
    
    def execute_task(self, task, architecture, memory):
        raise NotImplementedError("Subclasses must implement execute_task")
AGENT
    
    cat > agents/__init__.py << 'INIT'
"""GENESIS Engine Agent System"""
INIT
    
    mark_complete "step_9"
}

step_10_create_scripts() {
    echo -e "\n${BLUE}[10/10]${NC} Creating helper scripts..."
    
    # Docker management script
    cat > start-docker.sh << 'DOCKER'
#!/data/data/com.termux/files/usr/bin/bash
# Auto-start Docker daemon

if pgrep dockerd > /dev/null; then
    echo "✅ Docker already running"
    docker ps
else
    echo "🚀 Starting Docker daemon..."
    pkill dockerd 2>/dev/null || true
    sleep 1
    dockerd --iptables=false &> /tmp/dockerd.log &
    
    # Wait for Docker to be ready
    for i in {1..10}; do
        if docker ps &>/dev/null; then
            echo "✅ Docker started successfully"
            break
        fi
        sleep 2
    done
    
    if ! docker ps &>/dev/null; then
        echo "❌ Docker failed to start"
        tail -20 /tmp/dockerd.log
        exit 1
    fi
fi

# Initialize swarm if needed
if ! docker info 2>/dev/null | grep -q "Swarm: active"; then
    echo "🔧 Initializing Docker Swarm..."
    docker swarm init --advertise-addr 127.0.0.1 2>/dev/null || true
fi

echo "✅ Docker ready!"
DOCKER
    
    # Main run script
    cat > run.sh << 'RUN'
#!/data/data/com.termux/files/usr/bin/bash
set -e

# Ensure Docker is running
./start-docker.sh

# Load environment
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Check API key
if [ -z "$OPENAI_API_KEY" ] || [[ "$OPENAI_API_KEY" == "sk-your-key-here" ]]; then
    echo "❌ OPENAI_API_KEY not set in .env file"
    exit 1
fi

# Run orchestrator
python3 -m orchestrator.main "$@"
RUN
    
    # Deployment helper
    mkdir -p scripts
    cat > scripts/deploy.py << 'DEPLOY'
#!/usr/bin/env python3
"""Deployment script using Docker SDK"""
import sys
import docker
from pathlib import Path

if len(sys.argv) < 2:
    print("Usage: python3 scripts/deploy.py <project_id>")
    sys.exit(1)

project_id = sys.argv[1]
project_dir = Path("genesis_builds") / project_id

if not project_dir.exists():
    print(f"❌ Project not found: {project_dir}")
    sys.exit(1)

client = docker.from_env()

print(f"🚀 Deploying: {project_id}")
print("Building image...")

image, logs = client.images.build(
    path=str(project_dir),
    tag=f"genesis_{project_id}:latest",
    rm=True
)

print("Starting container...")
container = client.containers.run(
    image.tags[0],
    name=f"genesis_{project_id}",
    detach=True,
    ports={'8000/tcp': 8000},
    remove=True
)

print(f"✅ Deployed: {container.name}")
print(f"   Access: http://localhost:8000")
DEPLOY
    
    chmod +x start-docker.sh run.sh 2>/dev/null || true
    chmod +x scripts/deploy.py 2>/dev/null || true
    
    mark_complete "step_10"
}

# ============================================================================
# Main Installation Flow
# ============================================================================

main() {
    print_header
    
    log "INFO" "Installation log: $LOG_FILE"
    log "INFO" "State file: $STATE_FILE"
    
    # Run all steps with error recovery
    step_1_system_check || { log "FATAL" "System check failed"; exit 1; }
    step_2_update_packages || log "WARN" "Package update had issues"
    step_3_install_system_deps || log "WARN" "Some system dependencies missing"
    step_4_setup_rust || log "WARN" "Rust setup incomplete"
    step_5_start_docker || { log "ERROR" "Docker failed to start"; }
    step_6_init_swarm || log "WARN" "Swarm initialization incomplete"
    step_7_create_project_structure || { log "FATAL" "Cannot create project"; exit 1; }
    step_8_install_python_deps || log "WARN" "Some Python packages missing"
    step_9_create_config_files || log "WARN" "Config file creation had issues"
    step_10_create_scripts || log "WARN" "Script creation incomplete"
    
    # Final report
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                  Installation Complete!                      ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next Steps:${NC}"
    echo "1. Edit API key: ${BLUE}nano .env${NC}"
    echo "2. Keep Termux awake: ${BLUE}termux-wake-lock${NC}"
    echo "3. Start Docker: ${BLUE}./start-docker.sh${NC}"
    echo "4. Run GENESIS: ${BLUE}./run.sh --idea 'Your project'${NC}"
    echo ""
    echo -e "${YELLOW}📱 Termux Tips:${NC}"
    echo "• Persistent session: ${BLUE}pkg install tmux && tmux${NC}"
    echo "• View install log: ${BLUE}less $LOG_FILE${NC}"
    echo "• Resume failed install: ${BLUE}bash $(basename $0)${NC} (skips completed steps)"
    echo ""
    
    log "INFO" "Installation completed successfully"
    log "INFO" "Project location: $(pwd)"
}

# Run with error handling
trap 'log "ERROR" "Installation interrupted"; exit 1' INT TERM
main

exit 0