#!/usr/bin/env python

import os
import sys


def helpMessage():
    print('Expected usage: `set_aws_credentials $namespace`. Must be a string at least 1 character in length.')


def main():
    args = sys.argv

    if len(args) != 2:
        helpMessage()
        sys.exit(1)

    namespace = args[1]

    if not len(namespace):
        helpMessage()
        sys.exit(1)

    access_key_id = os.environ.get('%s_AWS_ACCESS_KEY_ID' % namespace)
    secret_access_key = os.environ.get('%s_AWS_SECRET_ACCESS_KEY' % namespace)

    print 'export %s=%s' % ('AWS_ACCESS_KEY_ID', access_key_id)
    print 'export %s=%s' % ('AWS_SECRET_ACCESS_KEY', secret_access_key)


if __name__ == '__main__':
    main()
