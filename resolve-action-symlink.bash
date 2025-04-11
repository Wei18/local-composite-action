#!/bin/bash
set -e

log_error()   { echo "::error file=${BASH_SOURCE[1]},line=${BASH_LINENO[0]}::$1"; exit 1; }
log_debug()   { echo "::debug::$1"; }

validate_env() {
  : "${COMPOSITE_ACTION_PATH:?Missing COMPOSITE_ACTION_PATH}"
  : "${COMPOSITE_ACTION_REPOSITORY:?Missing COMPOSITE_ACTION_REPOSITORY}"
  : "${GITHUB_WORKSPACE:?Missing GITHUB_WORKSPACE}"
}

parse_repo() {
  IFS='/' read -r ORG REPO <<< "$COMPOSITE_ACTION_REPOSITORY"
  [[ -z "$ORG" || -z "$REPO" ]] && log_error "Invalid COMPOSITE_ACTION_REPOSITORY format"
}

find_repo_dir() {
  local path="$COMPOSITE_ACTION_PATH"
  while [ "$path" != "/" ]; do
    local parent="$(dirname "$path")"
    if [[ "${path##*/,,}" == "${REPO,,}" && "${parent##*/,,}" == "${ORG,,}" ]]; then
      REPO_DIR="$parent/$REPO"
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
  echo "Resolved COMPOSITE_ACTION_REPOSITORY_PATH: $TARGET_PATH"
}

create_symlink() {
  local link_root="$(dirname "$GITHUB_WORKSPACE")"
  SYMLINK="$link_root/$COMPOSITE_ACTION_REPOSITORY"
  echo "Creating SYMLINK: $SYMLINK"
  mkdir -p "$(dirname "$SYMLINK")"
  [ -L "$SYMLINK" ] && rm "$SYMLINK"
  ln -s "$TARGET_PATH" "$SYMLINK"
  echo "✅ Symlink created successfully."
  log_debug " → $TARGET_PATH"
}

main() {
  echo "::group::🔗 Starting resolve-action-symlink"
  validate_env
  parse_repo
  find_repo_dir
  resolve_target_path
  create_symlink
  echo "::endgroup::"
}

main
