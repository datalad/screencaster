# Screencaster - Cast Helpers for Code Demonstrations

A collection of tools to create automated code demonstrations from simple bash scripts. These tools help you create polished, reproducible terminal demos for talks, videos, and documentation by scripting the commands and timing rather than recording live sessions.

![Demo](demo.gif)

## Tools

- ``cast2asciinema`` creates an [asciinema](https://asciinema.org/) from your
  code
- ``cast2narration`` creates text-to-speech output from a screencast script
- ``cast2rst`` turns an asciinema asciicast  into an RST markup
- ``cast2script`` converts a cast to a script
- ``cast_live`` creates a remote controlled terminal that can execute a code
  cast line-wise
- ``cast_bash.rc`` contains the bash configuration used by some cast helpers

## Installation

### `cast2asciinema` dependencies

- `xterm` - Terminal emulator for running the demos
- `xdotool` - For simulating keyboard input
- `asciinema` - For recording the terminal sessions
- `cowsay` - For cow sayin'

### Setup

Clone this repository:

```bash
git clone https://github.com/datalad/screencaster.git
cd screencaster
```

Optionally, add to your PATH to use from anywhere:

```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$PATH:/full/path/to/screencaster"
```

Then you can run `cast2asciinema` from any directory with your demo scripts.

## Quick Start

**demo.sh:**
```bash
#!/bin/bash

say "Welcome to my demo"
sleep 1
say "Let's run some commands"
sleep 1
run "echo 'Hello, World!'"
run "ls -la"
sleep 2

say "That's all!"
```

Make it executable and run it:

```bash
chmod +x demo.sh
# Assuming screencaster is in your PATH
# SCREENCAST_HOME avoids permission issues with default /demo directory
SCREENCAST_HOME=/tmp/demo cast2asciinema demo.sh output
```

This will create `output/demo.json`. Play it with:

```bash
asciinema play output/demo.json
```

### Converting to GIF

To convert your recording to an animated GIF, use the `agg` tool with podman:

```bash
cd output
# :Z flag required for SELinux contexts to allow container write access
podman run --rm -v "$PWD:/data:Z" docker.io/kayvan/agg /data/demo.json /data/demo.gif
```

Note: Using `podman` instead of `docker` avoids creating files owned by root.

This creates an optimized GIF suitable for embedding in documentation or sharing.

### Uploading to asciinema.org

You can upload recordings to asciinema.org for easy sharing:

```bash
asciinema upload output/demo.json
```

This returns a URL you can share. Asciinema.org also allows downloading recordings as GIF directly from their web interface.

### Available Helper Functions

- `say "text"` - Display a comment in the terminal (auto-wrapped)
- `run "command"` - Type and execute a command
- `run_expfail "command"` - Run a command expected to fail
- `show "text"` - Display multi-line text as comments
- `type "text"` - Type text without executing
- `execute` - Press Enter and wait for command completion
- `sleep N` - Pause for N seconds
- `key KeyName` - Press a specific key (e.g., `key Return`)

### Working with Virtual Environments

If your demo requires a Python virtual environment or other shell setup, activate it within the cast script using `run`:

```bash
#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Activate virtual environment in the demo terminal
run "source $SCRIPT_DIR/venv/bin/activate"

say "Now running commands with the activated environment..."
run "python --version"
run "pip list"
```

Each `run` command executes in the same persistent shell session, so environment changes persist across commands.

## Configuration

### SCREENCAST_HOME

By default, `cast2asciinema` tries to create a temporary home directory at `/demo`, which requires root access. To avoid permission issues, set the `SCREENCAST_HOME` environment variable to a writable location:

```bash
SCREENCAST_HOME=/tmp/demo cast2asciinema demo.sh output
```

This directory is used as a clean, isolated environment for your demo and is cleaned up automatically after the recording completes.

## Troubleshooting

### Asciinema configuration prompt

If `cast2asciinema` fails with "Asciinema stopped unexpectedly", asciinema may be prompting for configuration (e.g., sharing settings). This can happen on first run or if settings are reset. The recording will fail during the prompt. Simply run the command again after responding to the prompt, and it will work correctly.
