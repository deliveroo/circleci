#!/usr/bin/env python

import os
import sys


def main():
    args = sys.argv
    if len(args) != 2:
        print 'Usage: %s $name' % args[0]
        sys.exit(1)
    prefix = '%s_' % args[1]
    for name, value in os.environ.items():
        if not name.startswith(prefix):
            continue
        new_name = name[len(prefix):]
        print 'export %s=%s' % (new_name, value)


if __name__ == '__main__':
    main()
