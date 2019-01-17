#!/bin/bash
if [ -e firstrun.md ]; then
 echo "-- First container startup --"
 python3 -m pip install -e .
 python3 -m pip install gym[all]==0.9.5
 rm firstrun.md
fi
top
