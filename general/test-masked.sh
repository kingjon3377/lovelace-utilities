#!/bin/bash
emerge -p1 $(eix --installed-without-use test --format '<installedversions:NAMEASLOT>' | grep :) | grep '\*'
