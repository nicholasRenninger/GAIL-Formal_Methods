#!/bin/bash

# Starting shell scripts with set -e is considered a best practice, since it is
# usually safer to abort the script if some error occurs. If a command may fail
# harmlessly, I usually append || true to it.
set -e

# need to set ip to this for macOS to work
jupyter notebook --no-browser --ip 0.0.0.0 --port=8888