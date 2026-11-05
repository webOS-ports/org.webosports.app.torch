Torch
=====

Summary
-------
The LuneOS torch app: switches the flashlight LED through torchd.

A card with a torch on it that switches the flashlight LED through torchd
(org.webosports.service.torch), as the shell's Flashlight toggle does.

The Summary line above is read by webos_modules_init (webOS.cmake) as the
project summary, and configure stops without it: keep the heading and keep
it to one line.

Tests
-----

On the build host, with luneos-components checked out next to this
repository:

    tools/run-tests.sh [path to luneos-components]

runs `tests/tst_screens.qml`: the app with no torch, with the torch off
and with it on, at each screen in `PROFILES` - by default `mindphone`
(480x800), `q25` (720x720), `tp` (1024x768) and `radon` (720x1600, with a
notch and rounded corners, drawn over in red in its shots). It checks that
the torch stands in the middle of the window, inside it, and the line
below it is on the screen and clear of it. Each state is saved as
`build/test-output/ui/<profile>-<state>.png`. torchd is not on the host's
bus, so what it would report is set on the window directly.
