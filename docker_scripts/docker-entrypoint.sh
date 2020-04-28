#!/bin/bash

# Starting shell scripts with set -e is considered a best practice, since it is
# usually safer to abort the script if some error occurs. If a command may fail
# harmlessly, I usually append || true to it.
set -e

jupyter notebook --no-browser --allow-root --port 1234