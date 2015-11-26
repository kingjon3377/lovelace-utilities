#!/bin/sh -v
man "$1"
rm -i "$(man -W "$1" | grep -v man/)"
