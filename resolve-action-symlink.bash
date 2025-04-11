#!/bin/bash
set -e

log_error() { echo "::error file=${BASH_SOURCE[1]},line=${BASH_LINENO[0]}::$1"; exit 1; }

log_debug() { echo "::debug file=${BASH_SOURCE[1]},line=${BASH_LINENO[0]}::$1"; }

validate_env() {
  : "${COMPOSITE_ACTION_PATH:?Missing COMPOSITE_ACTION_PATH}"
  : "${COMPOSITE_ACTION_REPOSITORY:?Missing COMPOSITE_ACTION_REPOSITORY}"
  : "${GITHUB_WORKSPACE:?Missing GITHUB_WORKSPACE}"
  log_debug "All required variables are present."
}

parse_repo() {
  IFS='/' read -r ORG REPO <<< "$COMPOSITE_ACTION_REPOSITORY"
  [[ -z "$ORG" || -z "$REPO" ]] && log_error "Invalid COMPOSITE_ACTION_REPOSITORY format"
  log_debug "Parsed ORG_NAME=$ORG_NAME, REPO_NAME=$REPO_NAME"
}

find_repo_dir() {
  local path="$COMPOSITE_ACTION_PATH"
  while [ "$path" != "/" ]; do
    local parent="$(dirname "$path")"
    if [[ "${path##*/,,}" == "${REPO,,}" && "${parent##*/,,}" == "${ORG,,}" ]]; then
      REPO_DIR="$parent/$REPO"
      log_debug "Found REPO_DIR=$REPO_DIR"
      return
    fi
    path="$parent"
  done
  log_error "Could not find repo dir for $COMPOSITE_ACTION_REPOSITORY"
}

resolve_target_path() {
  mapfile -t SUBDIRS < <(find "$REPO_DIR" -mindepth 1 -maxdepth 1 -type d)
  [[ ${#SUBDIRS[@]} -ne 1 ]] && log_error "Expected exactly one subdir in $REPO_DIR"
  TARGET_PATH="${SUBDIRS[0]}"
  log_debug "Resolved COMPOSITE_ACTION_REPOSITORY_PATH=$TARGET_PATH"
}

create_symlink() {
  local link_root="$(dirname "$GITHUB_WORKSPACE")"
  SYMLINK="$link_root/$COMPOSITE_ACTION_REPOSITORY"
  echo "Creating SYMLINK: $SYMLINK"
  mkdir -p "$(dirname "$SYMLINK")"
  [ -L "$SYMLINK" ] && rm "$SYMLINK"
  ln -s "$TARGET_PATH" "$SYMLINK"
  echo "✅ Symlink created successfully."
  log_debug "  → $TARGET_PATH"
}

main() {
  validate_env
  parse_repo
  find_repo_dir
  resolve_target_path
  create_symlink
}

main
