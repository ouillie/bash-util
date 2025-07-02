# Bash Utilities

A small library of standard functions for modern Bash scripts (v4.4+).

## Usage

```bash
source 'util.sh'
```

## Reference

### `parse-options`

A modern version of `getopt`.

Parses all command-line options and positional arguments
into a simple associative array and sequential array, respectively.

Options can be overloaded with multiple aliases separated by commas.

Handles the help message automatically.

Example:

```bash
# Configure the option parser,
# then pass the script's real arguments after `--`.
# Pass an optional help message description to stdin.
parse-options \
  --foo,-f:FOO-ARG~'the foo help' \
  -b~'the bar help' \
  -q,-u,-x:Q \
  @'positional argument help' \
  -- 'positional value' -bf 'foo value' -- -q \
  <<HELP
This is the help message description.
HELP

# Access options in `options` using the canonical name.
[[ -v "options[-b]" ]]
[[ "${options[--foo]}" == 'foo value' ]]
[[ ! -v "options[-q]" ]]

# Access positional arguments in `arguments`.
[[ "${arguments[0]}" == 'positional value' ]]
[[ "${arguments[1]}" == '-q' ]]
```

Corresponding help message:

```
Usage: <program name> [--foo FOO-ARG] [-b] [-q Q] [--] positional argument help

This is the help message description.

Options:
    -h, --help
        Print this help message and exit.
    --foo=FOO-ARG, -f FOO-ARG
        the foo help
    -b
        the bar help
    -q Q, -u Q, -x Q
```

### `initialize-formatting`

Set a bunch of global variables with [ANSI escape sequences] for text formatting:

- `bold`
- `underline`
- `red`
- `green`
- `yellow`
- `blue`
- `magenta`
- `cyan`
- `reset` &mdash; remove formatting

[ANSI escape sequences]: https://en.wikipedia.org/wiki/ANSI_escape_code

### `assert-command-available`

If the named command cannot be found on `$PATH`,
log an error and exit.

### Logging Functions

- `log-error`
- `log-warn`
- `log-info`
- `log-debug`
