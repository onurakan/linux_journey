#!/bin/bash

# create a super fast in memory disk (=ram disk)
mkdir -p /mnt/ram
mount -t tmpfs tmpfs /mnt/ram -o size=8192M

# List ports with pid. Use to find processes which couldnt released closed&released used ports.
lsof -i -P | grep -i "listen"

# Like ls -R, but tree like output
tree

# vi favorites
# x : delete character
# dd: delete line
# ctrl + u : go one page up
#


#reference: https://github.com/engineer-man/youtube/blob/master/058/commands.sh
