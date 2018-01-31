#!/usr/bin/env python

import os
import sys


def helpMessage():
    print('Expected usage: `print_env $name`. Must be a string at least 1 character in length.')

def main():
    args = sys.argv

    if len(args) != 2:
        helpMessage()
        sys.exit(1)

    target = args[1]

    if not len(target):
        helpMessage()
        sys.exit(1)

    prefix = '%s_' % target

    for name, value in os.environ.items():
        if not name.startswith(prefix):
            continue
        new_name = name[len(prefix):]
        print 'export %s=%s' % (new_name, value)


if __name__ == '__main__':
    main()
