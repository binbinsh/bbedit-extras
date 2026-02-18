#!/bin/sh

# Install the Monokai Light color scheme and Dart language module for BBEdit.

set -eu

SCHEME_NAME="Monokai Light.bbColorScheme"
SCHEME_SOURCE="color-schemes/${SCHEME_NAME}"
MODULE_NAME="Dart.plist"
MODULE_SOURCE="language-modules/${MODULE_NAME}"
REPO_URL="https://github.com/binbinsh/bbedit-extras.git"

if ! command -v git >/dev/null 2>&1; then
  printf '%s\n' "git is required to download ${SCHEME_NAME} and ${MODULE_NAME}." >&2
  exit 1
fi

color_schemes_dir="${HOME}/Library/Application Support/BBEdit/Color Schemes"
language_modules_dir="${HOME}/Library/Application Support/BBEdit/Language Modules"
mkdir -p "${color_schemes_dir}"
mkdir -p "${language_modules_dir}"

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
local_scheme_path="${script_dir}/${SCHEME_SOURCE}"
local_module_path="${script_dir}/${MODULE_SOURCE}"

tmp_dir=""
cleanup() {
  if [ -n "${tmp_dir}" ] && [ -d "${tmp_dir}" ]; then
    rm -rf "${tmp_dir}"
  fi
}
trap cleanup EXIT INT HUP TERM

if [ -f "${local_scheme_path}" ] && [ -f "${local_module_path}" ]; then
  source_root="${script_dir}"
else
  tmp_dir=$(mktemp -d)
  git clone --depth 1 "${REPO_URL}" "${tmp_dir}/repo" >/dev/null 2>&1
  source_root="${tmp_dir}/repo"
fi

scheme_path="${source_root}/${SCHEME_SOURCE}"
if [ ! -f "${scheme_path}" ]; then
  printf '%s\n' "Failed to locate ${SCHEME_SOURCE}." >&2
  exit 1
fi

target_path="${color_schemes_dir}/${SCHEME_NAME}"
cp "${scheme_path}" "${target_path}"
printf '%s\n' "Installed ${SCHEME_NAME} into ${color_schemes_dir}."

module_path="${source_root}/${MODULE_SOURCE}"
if [ ! -f "${module_path}" ]; then
  printf '%s\n' "Failed to locate ${MODULE_SOURCE}." >&2
  exit 1
fi

module_target_path="${language_modules_dir}/${MODULE_NAME}"
cp "${module_path}" "${module_target_path}"
printf '%s\n' "Installed ${MODULE_NAME} into ${language_modules_dir}."
