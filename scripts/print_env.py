#!/usr/bin/env python

from __future__ import print_function
import os
import sys


def help_message(error):
    if error:
        print(error, file=sys.stderr)

    print(
        """
Usage: print_env <target>

    <target> - the variable prefix to match

    Example: a target of FOO will match all variables starting FOO_
             such as FOO_TEST1 and FOO_TEST2
""",
        file=sys.stderr,
    )


def print_env(target):

    prefix = "%s_" % target

    for name, value in os.environ.items():
        if not name.startswith(prefix):
            continue
        new_name = name.lstrip(prefix)
        print("export %s=%s" % (new_name, value))


def main(args):
    if len(args) != 1:
        help_message("Exactly one argument required")
        sys.exit(1)

    target = args[0]

    if not target:
        help_message("Prefix cannot be empty")
        sys.exit(1)

    print_env(target)


if __name__ == "__main__":
    main(sys.argv[1:])
