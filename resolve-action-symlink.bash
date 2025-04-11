#!/bin/bash
set -e

# 確保三個變數存在
echo "::group::🔍 Step 0 - Validate required variables"
if [[ -z "$COMPOSITE_ACTION_PATH" || -z "$COMPOSITE_ACTION_REPOSITORY" || -z "$GITHUB_WORKSPACE" ]]; then
  echo "::error file=${BASH_SOURCE[0]},line=${LINENO}::One or more required environment variables are missing."
  exit 1
fi
echo "::debug file=${BASH_SOURCE[0]},line=${LINENO}::All required variables are present."
echo "::endgroup::"

# 拆 org/repo
echo "::group::🔍 Step 1 - Parse COMPOSITE_ACTION_REPOSITORY"
IFS='/' read -r ORG_NAME REPO_NAME <<< "$COMPOSITE_ACTION_REPOSITORY"

if [[ -z "$ORG_NAME" || -z "$REPO_NAME" ]]; then
  echo "::error file=${BASH_SOURCE[0]},line=${LINENO}::Invalid COMPOSITE_ACTION_REPOSITORY format. Expected 'org/repo', got '$COMPOSITE_ACTION_REPOSITORY'"
  exit 1
fi
echo "::debug file=${BASH_SOURCE[0]},line=${LINENO}::Parsed ORG_NAME=$ORG_NAME, REPO_NAME=$REPO_NAME"
echo "::endgroup::"

# 往上找 org/repo 結構
echo "::group::🔍 Step 2 - Search for repository directory path"
current="$COMPOSITE_ACTION_PATH"
REPO_DIR=""

while [ "$current" != "/" ]; do
  parent_dir="$(dirname "$current")"
  if [[ "$(basename "$current" | tr '[:upper:]' '[:lower:]')" == "$(echo "$REPO_NAME" | tr '[:upper:]' '[:lower:]')" ]] &&
     [[ "$(basename "$parent_dir" | tr '[:upper:]' '[:lower:]')" == "$(echo "$ORG_NAME" | tr '[:upper:]' '[:lower:]')" ]]; then
    REPO_DIR="$parent_dir/$REPO_NAME"
    break
  fi
  current="$parent_dir"
done

if [ -z "$REPO_DIR" ]; then
  echo "::error file=${BASH_SOURCE[0]},line=${LINENO}::Could not find '$COMPOSITE_ACTION_REPOSITORY' (org/repo) in any parent directory of: $COMPOSITE_ACTION_PATH"
  exit 1
fi

echo "::debug file=${BASH_SOURCE[0]},line=${LINENO}::Found repository folder: $REPO_DIR"
echo "::endgroup::"

# 找唯一的子資料夾
echo "::group::📁 Step 3 - Locate subdirectory inside repo"
mapfile -t SUBDIRS < <(find "$REPO_DIR" -mindepth 1 -maxdepth 1 -type d)

if [ "${#SUBDIRS[@]}" -ne 1 ]; then
  echo "::debug file=${BASH_SOURCE[0]},line=${LINENO}::Contents of $REPO_DIR:"
  ls -la "$REPO_DIR"
  echo "::error file=${BASH_SOURCE[0]},line=${LINENO}::Expected exactly one subdirectory inside: $REPO_DIR"
  exit 1
fi

COMPOSITE_ACTION_REPOSITORY_PATH="${SUBDIRS[0]}"
echo "Resolved COMPOSITE_ACTION_REPOSITORY_PATH: $COMPOSITE_ACTION_REPOSITORY_PATH"
echo "::endgroup::"

# 建立 symlink
echo "::group::🔗 Step 4 - Create symlink"
LINK_PARENT_DIR="$(dirname "$GITHUB_WORKSPACE")"
SYMLINK_PATH="$LINK_PARENT_DIR/$COMPOSITE_ACTION_REPOSITORY"

echo "::debug file=${BASH_SOURCE[0]},line=${LINENO}::Creating symlink: $SYMLINK_PATH → $COMPOSITE_ACTION_REPOSITORY_PATH"
echo "Creating symlink: SYMLINK_PATH: $SYMLINK_PATH"

# 確保父目錄存在
mkdir -p "$(dirname "$SYMLINK_PATH")"

# 如果已有，先刪掉
[ -L "$SYMLINK_PATH" ] && rm "$SYMLINK_PATH"

# 建立 symlink
ln -s "$COMPOSITE_ACTION_REPOSITORY_PATH" "$SYMLINK_PATH"

echo "✅ Symlink created successfully."
echo "::endgroup::"
