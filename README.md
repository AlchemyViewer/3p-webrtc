# 3p-webrtc-build

This repository contains scripts and tooling to download, patch, and
build webrtc.  Patches include bugfixes and other fixes inheirited from
the repository from which this repo was forked.  [github.com/webrtc-sdk/webrtc-build](https://github.com/webrtc-sdk/webrtc-build)

The build process clones [github.com/webrtc-sdk/webrtc](https://github.com/webrtc-sdk/webrtc)
into a local source repository and launches the google tools to build the
libraries, followed by packaging by autobuild.

Typically, Github Actions is used to build the packages and release them.
It's also possible to build them locally, as noted below.

# Second Life Local Building and Debugging Notes

These notes describe the process of building the webrtc libraries locally,
installing the libraries to the Second Life viewer build, and debugging webrtc
issues.

## Build Dependencies

The following should be installed to build the webrtc libraries.

* [Autobuild](https://wiki.secondlife.com/wiki/Autobuild)

### Windows
* [Cigwyn](https://www.cygwin.com/)
or
* [git bash shell](https://git-scm.com/downloads/win)

## Building

The following instructins describe the process of building the library package

### Linux

From the root directory of the 3p-webrtc-build, run the following script:
```build-local-autobuild-package.sh```

This will build the Ubuntu 24.04 version of the WebRTC libraries and package
them as an autobuild package.  The autobuild package will be created in
the root directory, and will resemble something like:
```webrtc-m137_release.242741945-linux64-242741945.tar.bz2```

### Mac

From the root directory of the 3p-webrtc-build, run the following script:

```
build-local-autobuild-package.sh
```

This will build the OSX version of the WebRTC libraries and package
them as an autobuild package.  The autobuild package will be created in
the root directory, and will resemble something like:

```
webrtc-m137_release.242741945-darwin64-242741945.tar.bz2
```

### Windows

From the root directory of the 3p-webrtc-build, run the following script:

```
build-local-autobuild-package.sh
```

This will build the OSX version of the WebRTC libraries and package
them as an autobuild package.  The autobuild package will be created in
the root directory, and will resemble something like:

```
webrtc-m137_release.242741945-windows64-242741945.tar.bz2
```

## Installing In Viewer Builds

### Windows

In the viewer build directory, uninstall the previous webrtc package with:

```
autobuild uninstall -c <configuration> -A64 webrtc``` where `configuration` is the configuration you're building with such as `RelWithDebInfoOS.
```

Then, you can install your locally built version of the webrtc package with:

```
autobuild install -c <configuration> -A64 --local <path-to-webrtc-autobuild-package> webrtc
```

where the path is in the form for paths used by your shell, such as:

```
autobuild install -c RelWithDebInfoOS -A64 --local /c/Users/user/git/3p-webrtc-build/webrtc-m137_release.242752326-windows64-242752326.tar.bz2 webrtc
```

If you get an error such as:

```
ERROR: [WinError 5] Access is denied: 'C:\\Users\\user\\git\\viewer\\build-vc170-64\\packages\\include/webrtc/third_party/depot_tools/.cipd_bin/2.7/bin/include/Python-ast.h'
```

You may need to uninstall again, and then delete the viewer/build-vc170-64/packages/include/webrtc directory:

```
rm -rf build-vc170-64/packages/include/webrtc/
```

### Mac

In the viewer build directory, uninstall the previous webrtc package with:

```
autobuild uninstall -c <configuration> -A64 webrtc``` where `configuration` is the configuration you're building with such as `RelWithDebInfoOS.
```

Then, you can install your locally built version of the webrtc package with:

```
autobuild install -c <configuration> -A64 --local <path-to-webrtc-autobuild-package> webrtc
```

where the path is in the form for paths used by your shell, such as:

```
autobuild install -c RelWithDebInfoOS -A64 --local /c/Users/user/git/3p-webrtc-build/webrtc-m137_release.242752326-darwin64-242752326.tar.bz2 webrtc
```

### Linux

In the viewer build directory, uninstall the previous webrtc package with:

```
autobuild uninstall -c <configuration> -A64 webrtc``` where `configuration` is the configuration you're building with such as `RelWithDebInfoOS.
```

Then, you can install your locally built version of the webrtc package with:

```
autobuild install -c <configuration> -A64 --local <path-to-webrtc-autobuild-package> webrtc
```

where the path is in the form for paths used by your shell, such as:

```
autobuild install -c RelWithDebInfoOS -A64 --local /c/Users/user/git/3p-webrtc-build/webrtc-m137_release.242752326-linux64-242752326.tar.bz2 webrtc
```

## Debugging WebRTC

Using either the github actions build or a local build, you should end up
with symbols for webrtc, which will refer to the source.  You can find
the source via:

### Windows

The sources for webrtc are located within the following subdirectory of
the enlistment of 3p-webrtc-build:

```
3p-webrtc-build/build/_source/windows_x86_64/webrtc/src
```

### Mac

The sources for webrtc are located within the following subdirectory of
the enlistment of 3p-webrtc-build:

```
3p-webrtc-build/build/_source/macos_x86_64/webrtc/src
```

### Linux

Linux is a bit more difficult  as the sources is downloaded and patched within
a docker container.  To get the patched source, clone the webrtc base
repository to a convenient place:

```
git clone git@github.com:webrtc-sdk/webrtc.git
get checkout m137_release
```

Apply the following patches in order as follows, from the root of the
directory for webrtc-sdk/webrtc.git:

```
patch -p1 < <3p-webrtc-build-directory>/build/patches/add_license_dav1d.patch
patch -p1 < <3p-webrtc-build-directory>/build/patches/fix_mocks.patch
patch -p1 < <3p-webrtc-build-directory>/build/patches/upsample-to-48khz-for-echo-cancellation-for-now.patch
patch -p1 < <3p-webrtc-build-directory>/build/patches/bug_8759_workaround.patch
patch -p1 < <3p-webrtc-build-directory>/build/patches/disable_mute_of_audio_processing.patch
patch -p1 < <3p-webrtc-build-directory>/build/patches/crash_on_fatal_error.patch
```

After that, you can access the appropriate sources for webrtc

## Developing

To make modifications to the webrtc code, you need to generate a patch file and
place it in the build/patches directory of the 3p-webrtc-build enlistment
directory.

### Windows and Mac

Make your code change to the location of the sources for your OS, as specified
above.

You can then build using the build command above to generate an autobuild package.

Once everything is working, create a patch file via the following from the webrtc enlistment.

```
git diff <changed-files> > <3p-webrtc-build-directory>/build/patches/<title>.patch
```

If you are modifying files that may have been modified by previous patches,
you'll need to work out the proper diff by unapplying that patch, creating
your new patch, then reapplying the removed patch.

Once you've created your patch file, modify the `build/run.py` file to include
your patch in the appropriate OSs.  Look for the hash named PATCHES.

You can then commit and build via Github Actions, as needed.

### Linux
TBD.

## Github Actions Builds

There are two github actions of interes.

build - Run a build to validate builds.  Does not produce autobuild packages.
release - Run when a release is created.  It produces autobuild packages in the release portion of the repository.