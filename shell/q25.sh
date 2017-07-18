#!/bin/bash

for d in "$(find $1 -maxdepth 1 -type d)"
do
	find $d -maxdepth 1 -type f 2>/dev/null | grep fscaps
done
