#!/bin/sh

# Install color schemes and the Dart language module for BBEdit.

set -eu

SCHEME_DIR="color-schemes"
MODULE_NAME="Dart.plist"
MODULE_SOURCE="language-modules/${MODULE_NAME}"
REPO_URL="https://github.com/binbinsh/bbedit-extras.git"

if ! command -v git >/dev/null 2>&1; then
  printf '%s\n' "git is required to download color schemes and ${MODULE_NAME}." >&2
  exit 1
fi

color_schemes_dir="${HOME}/Library/Application Support/BBEdit/Color Schemes"
language_modules_dir="${HOME}/Library/Application Support/BBEdit/Language Modules"
mkdir -p "${color_schemes_dir}"
mkdir -p "${language_modules_dir}"

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
local_scheme_dir="${script_dir}/${SCHEME_DIR}"
local_module_path="${script_dir}/${MODULE_SOURCE}"

tmp_dir=""
cleanup() {
  if [ -n "${tmp_dir}" ] && [ -d "${tmp_dir}" ]; then
    rm -rf "${tmp_dir}"
  fi
}
trap cleanup EXIT INT HUP TERM

if [ -d "${local_scheme_dir}" ] && [ -f "${local_module_path}" ]; then
  source_root="${script_dir}"
else
  tmp_dir=$(mktemp -d)
  git clone --depth 1 "${REPO_URL}" "${tmp_dir}/repo" >/dev/null 2>&1
  source_root="${tmp_dir}/repo"
fi

scheme_source_dir="${source_root}/${SCHEME_DIR}"
if [ ! -d "${scheme_source_dir}" ]; then
  printf '%s\n' "Failed to locate ${SCHEME_DIR}." >&2
  exit 1
fi

scheme_count=0
for scheme_path in "${scheme_source_dir}"/*.bbColorScheme; do
  [ -e "${scheme_path}" ] || continue
  scheme_name=$(basename "${scheme_path}")
  cp "${scheme_path}" "${color_schemes_dir}/${scheme_name}"
  printf '%s\n' "Installed ${scheme_name} into ${color_schemes_dir}."
  scheme_count=$((scheme_count + 1))
done

if [ "${scheme_count}" -eq 0 ]; then
  printf '%s\n' "No color schemes found in ${SCHEME_DIR}." >&2
  exit 1
fi

module_path="${source_root}/${MODULE_SOURCE}"
if [ ! -f "${module_path}" ]; then
  printf '%s\n' "Failed to locate ${MODULE_SOURCE}." >&2
  exit 1
fi

module_target_path="${language_modules_dir}/${MODULE_NAME}"
cp "${module_path}" "${module_target_path}"
printf '%s\n' "Installed ${MODULE_NAME} into ${language_modules_dir}."
