#!/bin/bash

thisdir=$(dirname "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(cd -P -- "$thisdir" && pwd -P)
BUILDPACK_DIR=$(cd -P -- "$thisdir/../.." && pwd -P)

#  Source variables and override with platform specifics.
source "$BUILDPACK_DIR/lib/vars.sh"
source "$SCRIPT_DIR/vars.sh"


#
#  Get StrongLoop Node debian package name.
#
function _get_debian_package_name() {
  local version=${1:-"$STRONGLOOP_DEFAULT_NODE_VERSION"}
  echo "${STRONGLOOP_NODE_PACKAGE_NAME}_${version}_$DEB_PACKAGE_EXTENSION"

}  #  End of function  _get_debian_package_name.


#
#  Prints the specified message - formatted.
#
#  Examples:
#    print_message "Initializing ..."
#
function print_message() {
  echo "$@" | sed "s/^/\t/"

}  #  End of function  print_message.


#
#  Print installed StrongLoop Node version.
#
function _print_installed_version() {
  local install_dir=$1

  local slnodebin=$install_dir/$STRONGLOOP_INSTALL_BIN_DIR/node
  if [ ! -f "$slnodebin" ]; then
    print_message "  - ERROR: No StrongLoop Node binary '$slnodebin' found."
    return 1
  fi

  local zver=$("$slnodebin" --version)
  print_message "  - Installed StrongLoop Node version '$zver'"
  return 0

}  #  End of function  _print_installed_version.


#
#  Download StrongLoop Node Debian Package from the CDN.
#  Example:
#    download_strongloop_debian_package "1.0.0-0.1_beta" ~/myapp ./cache
#
function download_strongloop_debian_package() {
  local version=${1:-"$STRONGLOOP_DEFAULT_NODE_VERSION"}
  local dldir=${2:-"/tmp/strongloop"}
  local pkgfile=$(_get_debian_package_name "$version")

  mkdir -p "$dldir"

  local dluri=$STRONGLOOP_CDN/$pkgfile
  local curlopts="-L -s -S --retry 3"
  curlopts="-L --retry 3"  #  For testing - verbose download

  print_message "  - Downloading StrongLoop package $pkgfile ..."
  print_message "      download uri = $dluri"
  print_message "  - Download started @ $(date)"

  if ! curl $curlopts -o "$dldir/$pkgfile" "$dluri"; then
    print_message "  - Download failed  @ $(date)"
    print_message "  - ERROR - downloading package $pkgfile failed."
    return 1
  fi

  print_message "  - Download ended   @ $(date)"
  print_message "  - StrongLoop package $pkgfile download completed!"
  return 0

}  #  End of function  download_strongloop_debian_package.


#
#  Write StrongLoop Node installation information.
#
#  Examples:
#    _write_profile_info  1.0.0-0.3.beta ~/myapp .cache/
#
function _write_profile_info() {
  local version=$1
  local build_dir=$2
  local cache_dir=$3

  local profile_dir="$build_dir/.profile.d"
  mkdir -p "$profile_dir"

  local cfg_platform=$(basename "$(dirname "$SCRIPT_DIR")")

  local bindir=$STRONGLOOP_VENDOR_INSTALL_DIR/$STRONGLOOP_INSTALL_BIN_DIR
  [ -d "$build_dir/$bindir" ] || bindir=$(dirname $(which node))

  local default_version=$STRONGLOOP_DEFAULT_NODE_VERSION

  cat > "$profile_dir/strongloop.sh" <<MYEOF
#  StrongLoop installation information.
export STRONGLOOP_PLATFORM=${STRONGLOOP_PLATFORM:-"$cfg_platform"}
export STRONGLOOP_HOST="0.0.0.0"
export STRONGLOOP_PORT=\${PORT:-"3000"}
export STRONGLOOP_VERSION=${version:-"$default_version"}
export STRONGLOOP_BIN_DIR=$bindir
export STRONGLOOP_PACKAGE_DIR=$cache_dir
export PATH="$bindir:node_modules/.bin:\$PATH"
MYEOF

   mkdir -p "$cache_dir/.profile.d"
   cp -p "$profile_dir/strongloop.sh" "$cache_dir/.profile.d/"

}  #  End of function  _write_profile_info.


#
#  Install's StrongLoop Node debian package.
#
function install_strongloop_debian_package() {
  local version=${1:-"$STRONGLOOP_DEFAULT_NODE_VERSION"}
  local build_dir=${2:-""}
  local cache_dir=${3:-"/tmp/strongloop"}

  local pkgfile=$(_get_debian_package_name "$version")
  if [ ! -f "$cache_dir/$pkgfile" ]; then
    download_strongloop_debian_package "$version" "$cache_dir"
    rm -rf "$cache_dir/node_modules"
  fi

  print_message "  - Extracting $pkgfile package ..."
  local install_dir=$build_dir/$STRONGLOOP_VENDOR_INSTALL_DIR
  #  Extact the data.tar.gz from the debian package.
  rm -rf "$install_dir"
  mkdir -p "$install_dir"
  pushd "$install_dir" > /dev/null
  rm -rf data.tar.gz usr/
  ar -p "$cache_dir/$pkgfile" data.tar.gz | tar -zx
  popd > /dev/null

  print_message "  - Installing $pkgfile package ..."
  rm -rf "$cache_dir/node_modules"
  local cachedcopy=$(dirname "$cache_dir/$STRONGLOOP_VENDOR_INSTALL_DIR")
  mkdir -p "$cachedcopy"
  cp -RPp "$install_dir" "$cachedcopy/"

  _write_profile_info "$@"

  _print_installed_version "$install_dir"

}  #  End of function  install_strongloop_debian_package.



#
#  main():  Install StrongLoop Node debian package.
#
install_strongloop_debian_package "$@"


