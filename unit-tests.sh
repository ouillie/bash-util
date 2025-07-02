#!/usr/bin/bash

set -e

source './util.sh'

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


assert-equals "$reset" ''
assert-equals "$bold" ''
assert-equals "$underline" ''
assert-equals "$red" ''
assert-equals "$green" ''
assert-equals "$yellow" ''
assert-equals "$blue" ''
assert-equals "$magenta" ''
assert-equals "$cyan" ''

initialize-formatting

assert-equals "$reset" "$(tput sgr0)"
assert-equals "$bold" "$(tput bold)"
assert-equals "$underline" "$(tput smul)"
assert-equals "$red" "$(tput setaf 1)"
assert-equals "$green" "$(tput setaf 2)"
assert-equals "$yellow" "$(tput setaf 3)"
assert-equals "$blue" "$(tput setaf 4)"
assert-equals "$magenta" "$(tput setaf 5)"
assert-equals "$cyan" "$(tput setaf 6)"


assert-command-available bash

! assert-command-available that-would-be-crazy-if-this-were-a-command-on-some-machine \
  2>&1 | assert-output "\
[${red}ERROR${reset}] ${bold}that-would-be-crazy-if-this-were-a-command-on-some-machine${reset} required but not found
"


< /dev/null parse-options -- -h | assert-output "\
Usage: ${bold}${0}${reset}

Options:
    ${bold}-h${reset}, ${bold}--help${reset}, ${bold}-?${reset}
        Print this help message and exit.
"


{
  parse-options \
    -f,--foo:FOO-ARG~'foo help' \
    -b~'bar
help' \
    --baz,-x,--qux,-y,-z \
    @'positional args docs' \
    -- -h \
    <<HELP

 This is the help message description. 
 
HELP
} | assert-output "\
Usage: ${bold}${0}${reset} [${bold}-f${reset} FOO-ARG] [${bold}-b${reset}] [${bold}--baz${reset}] [${bold}--${reset}] positional args docs


 This is the help message description. 
 

Options:
    ${bold}-h${reset}, ${bold}--help${reset}, ${bold}-?${reset}
        Print this help message and exit.
    ${bold}-f${reset} FOO-ARG, ${bold}--foo${reset}=FOO-ARG
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
  -- --foo='a value' 'an argument' -x 'another argument'
assert-equals "${#options[@]}" 2
assert-equals "${options[-f]}" 'a value'
assert-equals "${options[-x]}" ''
assert-equals "${#arguments[@]}" 2
assert-equals "${arguments[0]}" 'an argument'
assert-equals "${arguments[1]}" 'another argument'


parse-options \
  --foo,-f:FARG \
  -b \
  -- -bf 'a value'
assert-equals "${#options[@]}" 2
assert-equals "${options[--foo]}" 'a value'
assert-equals "${options[-b]}" ''
assert-equals "${#arguments[@]}" 0


parse-options \
  +foo,-f:FARG \
  -- -h \
  2>&1 | assert-output "\
[${red}ERROR${reset}] Invalid option: ${bold}+foo${reset}
[${blue}INFO${reset}] Options must match the regex ${bold}-.|--.+${reset}
"


parse-options \
  --foo:ARG \
  -- --foo \
  2>&1 | assert-output "\
[${red}ERROR${reset}] Missing argument for ${bold}--foo${reset}
Usage: ${bold}${0}${reset} [${bold}--foo${reset} ARG]

Options:
    ${bold}-h${reset}, ${bold}--help${reset}, ${bold}-?${reset}
        Print this help message and exit.
    ${bold}--foo${reset}=ARG
"


parse-options \
  --foo \
  -- --foo=surprise \
  2>&1 | assert-output "\
[${red}ERROR${reset}] Unexpected argument for ${bold}--foo${reset}
Usage: ${bold}${0}${reset} [${bold}--foo${reset}]

Options:
    ${bold}-h${reset}, ${bold}--help${reset}, ${bold}-?${reset}
        Print this help message and exit.
    ${bold}--foo${reset}
"


parse-options \
  --foo \
  -- --bar \
  2>&1 | assert-output "\
[${red}ERROR${reset}] Unrecognized option: ${bold}--bar${reset}
Usage: ${bold}${0}${reset} [${bold}--foo${reset}]

Options:
    ${bold}-h${reset}, ${bold}--help${reset}, ${bold}-?${reset}
        Print this help message and exit.
    ${bold}--foo${reset}
"
