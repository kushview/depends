#!/bin/bash
set -e
make -j4 HOST=x86_64-apple-darwin
make -j4 HOST=arm-apple-darwin
python3 lipo.py
