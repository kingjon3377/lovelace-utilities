#!/bin/bash
# Splitting into packages for emerge to pretend to install is the point
# shellcheck disable=SC2046
emerge -p1 $(eix --installed-without-use test --format '<installedversions:NAMEASLOT>' | grep :) | grep '\*'
