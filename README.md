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

Handles the help message automatically.

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
