#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"
BOOTSTRAP_TERRAFORM_DIR="$SCRIPT_DIR/bootstrap/terraform"
GITOPS_DIR="$SCRIPT_DIR/../w10-gitops"
ARGOCD_NAMESPACE="argocd"
ROOT_APP_MANIFEST="$GITOPS_DIR/apps/root.yaml"

print_header() {
  printf '\n=== %s ===\n' "$1"
}

print_done() {
  printf '\nDone: %s\n' "$1"
}

run_step() {
  local title="$1"
  shift

  print_header "$title"
  "$@"
  print_done "$title"
}

run_terraform_app() {
  terraform "-chdir=$TERRAFORM_DIR" "$@"
}

run_terraform_bootstrap() {
  terraform "-chdir=$BOOTSTRAP_TERRAFORM_DIR" "$@"
}

get_terraform_output_raw() {
  run_terraform_app output -raw "$1"
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

ensure_dir() {
  if [ ! -d "$1" ]; then
    printf 'Required directory not found: %s\n' "$1" >&2
    exit 1
  fi
}

run_bootstrap_validate() {
  run_terraform_bootstrap init -backend=false
  run_terraform_bootstrap validate
}

run_bootstrap_apply() {
  run_terraform_bootstrap init
  run_terraform_bootstrap apply -auto-approve
  run_terraform_bootstrap output
}

run_infra_apply() {
  run_terraform_app init
  run_terraform_app apply -auto-approve
  run_terraform_app output app_url
}

run_infra_destroy() {
  run_terraform_app destroy -auto-approve
}

run_infra_fmt() {
  run_terraform_app fmt -recursive
  run_terraform_bootstrap fmt -recursive
}

run_infra_validate() {
  run_terraform_app init -backend=false
  run_terraform_app validate
}

run_output() {
  run_terraform_app output
}

run_ssh() {
  printf 'Warning: Repo nay uu tien SSM. EC2 khong mo SSH inbound mac dinh.\n' >&2
  require_command ssh

  local private_key_path
  local alb_dns_name

  private_key_path="$(get_terraform_output_raw private_key_path)"
  alb_dns_name="$(get_terraform_output_raw alb_dns_name)"

  ssh -i "$private_key_path" "ubuntu@$alb_dns_name"
}

run_ssm() {
  require_command aws

  local command
  command="$(get_terraform_output_raw ssm_connect_command)"
  bash -lc "$command"
}

run_gitops_bootstrap() {
  require_command kubectl
  kubectl apply -f "$ROOT_APP_MANIFEST"
}

run_gitops_status() {
  require_command kubectl
  kubectl get applications -n "$ARGOCD_NAMESPACE"
  kubectl get all -n demo
}

run_gitops_sync() {
  require_command argocd
  argocd app sync w10-lab-root --grpc-web
  argocd app sync web --grpc-web
}

run_argocd_port_forward() {
  require_command kubectl
  kubectl -n "$ARGOCD_NAMESPACE" port-forward svc/argocd-server 8080:443
}

show_menu() {
  printf '\n===== W10 Lab Task Menu =====\n'
  printf '1. bootstrap:validate\n'
  printf '2. bootstrap:apply\n'
  printf '3. infra:apply\n'
  printf '4. infra:destroy\n'
  printf '5. infra:fmt\n'
  printf '6. infra:validate\n'
  printf '7. output\n'
  printf '8. ssh\n'
  printf '9. ssm\n'
  printf '10. gitops:bootstrap\n'
  printf '11. gitops:status\n'
  printf '12. gitops:sync\n'
  printf '13. argocd:port-forward\n'
  printf '14. exit\n'
}

usage() {
  cat <<'EOF'
Usage:
  ./task.sh <command>
  ./task.sh

Commands:
  bootstrap:validate
  bootstrap:apply
  infra:apply
  infra:destroy
  infra:fmt
  infra:validate
  output
  ssh
  ssm
  gitops:bootstrap
  gitops:status
  gitops:sync
  argocd:port-forward
  help
EOF
}

dispatch_command() {
  case "$1" in
    bootstrap:validate)
      run_step bootstrap:validate run_bootstrap_validate
      ;;
    bootstrap:apply)
      run_step bootstrap:apply run_bootstrap_apply
      ;;
    infra:apply)
      run_step infra:apply run_infra_apply
      ;;
    infra:destroy)
      run_step infra:destroy run_infra_destroy
      ;;
    infra:fmt)
      run_step infra:fmt run_infra_fmt
      ;;
    infra:validate)
      run_step infra:validate run_infra_validate
      ;;
    output)
      run_step output run_output
      ;;
    ssh)
      run_step ssh run_ssh
      ;;
    ssm)
      run_step ssm run_ssm
      ;;
    gitops:bootstrap)
      run_step gitops:bootstrap run_gitops_bootstrap
      ;;
    gitops:status)
      run_step gitops:status run_gitops_status
      ;;
    gitops:sync)
      run_step gitops:sync run_gitops_sync
      ;;
    argocd:port-forward)
      run_step argocd:port-forward run_argocd_port_forward
      ;;
    help|-h|--help)
      usage
      ;;
    *)
      printf 'Unknown command: %s\n\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
}

interactive_menu() {
  local choice

  while true; do
    show_menu
    printf 'Chon so de chay: '
    IFS= read -r choice || exit 0

    case "$choice" in
      1) dispatch_command bootstrap:validate ;;
      2) dispatch_command bootstrap:apply ;;
      3) dispatch_command infra:apply ;;
      4) dispatch_command infra:destroy ;;
      5) dispatch_command infra:fmt ;;
      6) dispatch_command infra:validate ;;
      7) dispatch_command output ;;
      8) dispatch_command ssh ;;
      9) dispatch_command ssm ;;
      10) dispatch_command gitops:bootstrap ;;
      11) dispatch_command gitops:status ;;
      12) dispatch_command gitops:sync ;;
      13) dispatch_command argocd:port-forward ;;
      14)
        printf 'Exit.\n'
        break
        ;;
      *)
        printf 'Lua chon khong hop le. Hay nhap so tu 1 den 14.\n' >&2
        ;;
    esac
  done
}

main() {
  ensure_dir "$TERRAFORM_DIR"
  ensure_dir "$BOOTSTRAP_TERRAFORM_DIR"
  ensure_dir "$GITOPS_DIR"
  require_command terraform

  if [ "$#" -gt 0 ]; then
    dispatch_command "$1"
    return
  fi

  interactive_menu
}

main "$@"
