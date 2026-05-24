#!/usr/bin/env bash
# =============================================================================
# 00-1-export-kubeconfig.sh
# Setup and export KUBECONFIG from k3s
# Usage: source scripts/bash/00-1-export-kubeconfig.sh
# =============================================================================

# -----------------------------------------------------------------------------
# Must be sourced, not executed
# -----------------------------------------------------------------------------
(return 0 2>/dev/null) || {
  echo "❌  Please source this script instead of running it directly."
  echo "    Usage: source scripts/bash/00-1-export-kubeconfig.sh"
  exit 1
}

source "$(dirname "${BASH_SOURCE[0]}")/../libs/pretty-log.bash"

KUBECONFIG_PATH="$HOME/.kube/config"
K3S_CONFIG="/etc/rancher/k3s/k3s.yaml"

step "Setup kubeconfig"

# -----------------------------------------------------------------------------
# Check 1: KUBECONFIG already exported and working
# -----------------------------------------------------------------------------
if [[ -n "${KUBECONFIG:-}" ]] && kubectl cluster-info &>/dev/null 2>&1; then
  log "KUBECONFIG already set and cluster is reachable — skipping setup."
  kv "KUBECONFIG:" "$KUBECONFIG"
else

  # -----------------------------------------------------------------------------
  # Check 2: ~/.kube/config exists and works
  # -----------------------------------------------------------------------------
  if [[ -f "$KUBECONFIG_PATH" ]] && KUBECONFIG="$KUBECONFIG_PATH" kubectl cluster-info &>/dev/null 2>&1; then
    log "Found existing kubeconfig at ${_C_CYAN}${KUBECONFIG_PATH}${_RESET} — skipping copy."
    export KUBECONFIG="$KUBECONFIG_PATH"
    kv "KUBECONFIG:" "$KUBECONFIG"

  else
    # -----------------------------------------------------------------------------
    # Check 3: k3s config exists — copy it
    # -----------------------------------------------------------------------------
    if [[ ! -f "$K3S_CONFIG" ]]; then
      err "k3s config not found at ${K3S_CONFIG}. Is k3s installed and running?"
    fi

    log "Copying k3s config to ${_C_CYAN}${KUBECONFIG_PATH}${_RESET}..."

    mkdir -p "$HOME/.kube"
    sudo cp "$K3S_CONFIG" "$KUBECONFIG_PATH"
    sudo chown "$USER:$USER" "$KUBECONFIG_PATH"
    chmod 600 "$KUBECONFIG_PATH"

    export KUBECONFIG="$KUBECONFIG_PATH"

    if kubectl cluster-info &>/dev/null 2>&1; then
      success "KUBECONFIG is set and cluster is reachable."
      kv "KUBECONFIG:" "$KUBECONFIG"
    else
      warn "KUBECONFIG exported but cluster is not reachable yet."
      warn "k3s may still be starting — try again in a few seconds."
      kv "KUBECONFIG:" "$KUBECONFIG"
    fi
  fi

fi

# -----------------------------------------------------------------------------
# Setup git config
# -----------------------------------------------------------------------------
step "Setup git config"

_GIT_USER="${USER}"
_GIT_HOST=$(hostname -s 2>/dev/null || hostname)
_GIT_EMAIL="${_GIT_USER}@${_GIT_HOST}"

git config --global user.name  "$_GIT_USER"
git config --global user.email "$_GIT_EMAIL"

log "git user.name:  ${_C_CYAN}${_GIT_USER}${_RESET}"
log "git user.email: ${_C_CYAN}${_GIT_EMAIL}${_RESET}"