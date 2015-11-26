#!/bin/sh
lsmod > lsmod.before && dmesg > dmesg.before && xinit > xinit.out 2>&1 && dmesg > dmesg.after && lsmod > lsmod.after
