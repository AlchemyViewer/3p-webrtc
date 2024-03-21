#!/usr/bin/env bash

cd "$(dirname "$0")"

# turn on verbose debugging output for logs.
exec 4>&1; export BASH_XTRACEFD=4; set -x

# make errors fatal
set -e

# bleat on references to undefined shell variables
set -u

top="$(pwd)"
stage="${top}"/stage

# load autobuild provided shell functions and variables
case "$AUTOBUILD_PLATFORM" in
    windows*)
        autobuild="$(cygpath -u "$AUTOBUILD")"
    ;;
    *)
        autobuild="$AUTOBUILD"
    ;;
esac
source_environment_tempfile="$stage/source_environment.sh"
"$autobuild" source_environment > "$source_environment_tempfile"
. "$source_environment_tempfile"

pushd "build"
case "$AUTOBUILD_PLATFORM" in
    windows*)
        python run.py build windows_x86_64 --debug --source-dir 'C:\webrtc' --build-dir 'C:\webrtc-build' --commit m114_release
        python run.py package windows_x86_64 --debug --source-dir 'C:\webrtc' --build-dir 'C:\webrtc-build'
        package_path="${top}/build/_package/windows_x86_64/webrtc.tar.bz2"
    ;;
    darwin*)
        python3 run.py build macos_x86_64 --webrtc-fetch --commit m114_release
        python3 run.py package macos_x86_64
        package_path="${top}/build/_package/macos_x86_64/webrtc.tar.bz2"
    ;;
    linux*)
        python3 run.py build ubuntu-22.04_x86_64 --commit m114_release
        python3 run.py package ubuntu-22.04_x86_64
        package_path="${top}/build/_package/ubuntu-22.04_x86_64/webrtc.tar.bz2"
    ;;
    *)
        autobuild="$AUTOBUILD"
    ;;
esac
popd

pushd "$stage"

# download the artifact
cp "${package_path}" .

tar xjf webrtc.tar.bz2 --strip-components=1
rm webrtc.tar.bz2

# Munge the WebRTC Build package contents into something compatible
# with the layout we use for other autobuild pacakges
mv include/ webrtc/
mkdir -p include
mv webrtc include
mv lib/ release/
mkdir -p lib
mv release/ lib/
mkdir -p LICENSES
mv NOTICE LICENSES/webrtc-license.txt

case "$AUTOBUILD_PLATFORM" in
    darwin64)
        mv Frameworks/WebRTC.xcframework/macos-x86_64/WebRTC.framework lib/release
    ;;
esac

build=${AUTOBUILD_BUILD_ID:=0}
echo "114.5735.08.${build}" > "VERSION.txt"
popd

