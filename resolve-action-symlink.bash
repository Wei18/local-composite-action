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
  log_debug "Parsed ORG=$ORG, REPO_NAME=$REPO"
}

find_repo_dir() {
  local current="$COMPOSITE_ACTION_PATH"
  local repo_lc="$(echo "$REPO" | tr '[:upper:]' '[:lower:]')"
  local org_lc="$(echo "$ORG" | tr '[:upper:]' '[:lower:]')"
  while [ "$current" != "/" ]; do
    local parent_dir="$(dirname "$current")"
    if [[ "$(basename "$current" | tr '[:upper:]' '[:lower:]')" == "$repo_lc" ]] &&
       [[ "$(basename "$parent_dir" | tr '[:upper:]' '[:lower:]')" == "$org_lc" ]]; then
      REPO_DIR="$parent_dir/$REPO"
      log_debug "Found REPO_DIR=$REPO_DIR"
      return
    fi
    current="$parent_dir"
  done
  log_error "Could not find repo dir for $COMPOSITE_ACTION_REPOSITORY"
}

resolve_target_path() {
  SUBDIRS=()
  while IFS= read -r -d '' dir; do
    SUBDIRS+=("$dir")
  done < <(find "$REPO_DIR" -mindepth 1 -maxdepth 1 -type d -print0)

  if [[ ${#SUBDIRS[@]} -ne 1 ]]; then
    log_error "Expected exactly one subdir in $REPO_DIR"
  else
    TARGET_PATH="${SUBDIRS[0]}"
    log_debug "Resolved TARGET_PATH=$TARGET_PATH"
  fi
}

create_symlink() {
  local link_root="$(dirname "$GITHUB_WORKSPACE")"
  SYMLINK="$link_root/$COMPOSITE_ACTION_REPOSITORY"
  echo "Creating SYMLINK: $SYMLINK"
  mkdir -p "$(dirname "$SYMLINK")"
  [ -L "$SYMLINK" ] && rm "$SYMLINK"
  ln -s "$TARGET_PATH" "$SYMLINK"
  echo "✅ Symlink created successfully."
}

main() {
  validate_env
  parse_repo
  find_repo_dir
  resolve_target_path
  create_symlink
}

test_main() {
  COMPOSITE_ACTION_PATH="./test/_action/wei18/helper-action/main/composite-actions/action1"
  COMPOSITE_ACTION_REPOSITORY="wei18/helper-action"
  GITHUB_WORKSPACE="./test/work/awesome-repo/awesome-repo"
  mkdir -p $COMPOSITE_ACTION_PATH
  mkdir -p $GITHUB_WORKSPACE
  main
  rm -rf ./test
}

if true; then
  main
else
  test_main
fi
