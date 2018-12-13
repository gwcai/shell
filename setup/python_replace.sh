#!/bin/bash

echo "decompress python:"
tar -xf python3.tar.gz -C /usr/local
mv /usr/bin/python /usr/bin/python_old2
ln -s /usr/local/python3/bin/python3 /usr/bin/python