#!/usr/bin/bash

set -e

source './bashlib.sh'

# Assert that the first argument (actual) equals the seconds argument (expected).
function assert-equals {
  if [[ "$1" != "$2" ]]
  then
    log-error "Assertion failed: '$1' != '$2'"
    return 1
  fi
}

# Assert that standard input is equal to the first argument.
function assert-output {
  local expected="$1"
  # Read all of standard input into the variable `actual`.
  IFS= read -rd '' actual || true
  if [[ "$actual" != "$expected" ]]
  then
    log-error "Output assertion failed"
    echo >&2 '┌──────────────────────────────────┤EXPECTED├──────────────────────────────────┐'
    echo >&2 "$expected"
    echo >&2 '└──────────────────────────────────────────────────────────────────────────────┘'
    echo >&2 '┌───────────────────────────────────┤ACTUAL├───────────────────────────────────┐'
    echo >&2 "$actual"
    echo >&2 '└──────────────────────────────────────────────────────────────────────────────┘'
    return 1
  fi
}


< /dev/null parse-options -- -h | assert-output "Usage: ${bold}${0}${reset}

Options:
    ${bold}-h${reset}, ${bold}--help${reset}
        Print this help message and exit.
"


{
  parse-options \
    -f,--foo:FARG~'foo help' \
    -b~'bar
help' \
    --baz,-x,--qux,-y,-z \
    @'positional args docs' \
    -- \
    -h \
    <<HELP

 This is the help message description. 
 
HELP
} | assert-output "Usage: ${bold}${0}${reset} [${bold}-f${reset} FARG] [${bold}-b${reset}] [${bold}--baz${reset}] [${bold}--${reset}] positional args docs


 This is the help message description. 
 

Options:
    ${bold}-h${reset}, ${bold}--help${reset}
        Print this help message and exit.
    ${bold}-f${reset} FARG, ${bold}--foo${reset}=FARG
        foo help
    ${bold}-b${reset}
        bar
        help
    ${bold}--baz${reset}, ${bold}-x${reset}, ${bold}--qux${reset}, ${bold}-y${reset}, ${bold}-z${reset}
"


parse-options \
  -f,--foo:FARG~"foo help" \
  -b~"bar help" \
  -x \
  -- \
  --foo='a value' 'an argument' -x
assert-equals "${#options[@]}" 2
assert-equals "${options[-f]}" 'a value'
assert-equals "${options[-x]}" ''
assert-equals "${#arguments[@]}" 1
assert-equals "${arguments[0]}" 'an argument'


parse-options \
  --foo,-f:FARG \
  -b \
  -- \
  -bf 'a value'
assert-equals "${#options[@]}" 2
assert-equals "${options[--foo]}" 'a value'
assert-equals "${options[-b]}" ''
assert-equals "${#arguments[@]}" 0
