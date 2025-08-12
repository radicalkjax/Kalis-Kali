#!/bin/bash

# Simple Application Launcher Wrapper
# Convenience script for launching individual applications

# Pass all arguments to launch-desktop.sh with --app flag
exec "$(dirname "$0")/launch-desktop.sh" --app "$@"