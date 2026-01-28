[中文版本](README_Chinese.md) | English

# Running CursorCLI Agent with Custom glibc 2.28 on CentOS 7

## Overview

This project provides a startup script to run the CursorCLI Agent using a custom glibc 2.28 on CentOS 7 systems without modifying the original agent script. The CursorCLI Agent requires glibc 2.28 or higher, while CentOS 7's default system glibc is 2.17.

## Prerequisites

This script assumes you have already:

1. Compiled and installed **glibc 2.28** and **GCC 9.5.0** in your user directory
2. The custom glibc should be installed at `$HOME/opt/glibc-2.28`
3. GCC 9.5.0 should be installed at `$HOME/opt/gcc-9.5.0`

For detailed instructions on compiling and installing glibc 2.28, GCC 9.5.0, and Make 4.2, please refer to the [opencode-on-centos7 project](https://github.com/Tao-Yida/opencode-on-centos7), which provides comprehensive documentation for setting up the required environment.

## Quick Start

### 1. Verify Prerequisites

Check that the required tools are installed:

```bash
# Check glibc 2.28
$HOME/opt/glibc-2.28/lib/ld-linux-x86-64.so.2 --version

# Check GCC 9.5.0
$HOME/opt/gcc-9.5.0/bin/gcc --version

# Check if Agent is installed
which agent
# Usually located at ~/.local/bin/agent
```

### 2. Use the Script

The main script is located at `scripts/agent_with_custom_glibc.sh`. You can run it directly:

```bash
cd /home/taoyida/cursorcli-glibc-shim
./scripts/agent_with_custom_glibc.sh [arguments]
```

Or create an alias in your shell configuration:

```bash
# Add to ~/.bashrc
cursor-cli() {
    /home/taoyida/cursorcli-glibc-shim/scripts/agent_with_custom_glibc.sh "$@"
}
```

Then reload your configuration:

```bash
source ~/.bashrc
```

Now you can use:

```bash
cursor-cli [arguments]
```

## How It Works

The script works as follows:

1. **Locates the Agent script**: Finds the agent binary at `~/.local/bin/agent`
2. **Sets up environment**: Configures environment variables for running with custom glibc:
   - Sets `LANG` and `LC_ALL` to `en_US.UTF-8` for proper encoding
   - Adds GCC 9.5.0 lib64 path to `LD_LIBRARY_PATH` for `libgcc_s.so.1` support
   - Does NOT add glibc-2.28 to `LD_LIBRARY_PATH` to avoid conflicts
3. **Runs with custom glibc**: Uses the custom glibc linker `$HOME/opt/glibc-2.28/lib/ld-linux-x86-64.so.2` to start node
4. **Restores environment**: Restores original environment variables after agent exits

## Key Features

- **Non-invasive**: Does not modify the original agent script
- **Environment isolation**: Only affects the agent process, not other system programs
- **Automatic environment restoration**: Ensures no impact on external shell after exit
- **Error handling**: Comprehensive error checking with helpful error messages

## Important Notes

1. **LD_LIBRARY_PATH Handling**: The script only adds GCC lib64 path to `LD_LIBRARY_PATH`, NOT the glibc path. This is intentional to prevent system bash subprocesses from crashing due to glibc version mismatch.

2. **Libgcc_s.so.1 Dependency**: The script sets `LD_LIBRARY_PATH` to include GCC 9.5.0 lib64 path to provide `libgcc_s.so.1` for `pthread_cancel` functionality. This is required for the agent to perform complex tasks like file searching.

3. **User Installation**: All software should be installed in user directories (e.g., `$HOME/opt/`) without requiring root privileges.

## File Structure

```
cursorcli-glibc-shim/
├── assets/
│   └── album.png
├── scripts/
│   └── agent_with_custom_glibc.sh
├── README.md           # This file
└── README_Chinese.md   # Chinese version
```

## Troubleshooting

### Error: Executable node not found

**Cause**: The agent binary is not installed or not in the expected location.

**Solution**: Install the CursorCLI Agent first. It should be installed at `~/.local/bin/agent`.

### Error: Custom glibc linker not found

**Cause**: The custom glibc 2.28 is not installed at the expected location.

**Solution**: Ensure glibc 2.28 is installed at `$HOME/opt/glibc-2.28/lib/ld-linux-x86-64.so.2`. Refer to the [opencode-on-centos7 project](https://github.com/Tao-Yida/opencode-on-centos7) for installation instructions.

### Error: libgcc_s.so.1 must be installed for pthread_cancel to work

**Cause**: GCC 9.5.0 lib path is not in `LD_LIBRARY_PATH`.

**Solution**: The script automatically handles this. If you still encounter this issue, verify that GCC 9.5.0 is installed at `$HOME/opt/gcc-9.5.0`.

## Related Projects

For information on compiling and installing the prerequisites (glibc 2.28, GCC 9.5.0, Make 4.2), please refer to the [opencode-on-centos7 project](https://github.com/Tao-Yida/opencode-on-centos7).

## License

This project is licensed under the MIT License, free to use and modify.

---

**Last Updated**: January 28, 2026

**Author**: Yida Tao
