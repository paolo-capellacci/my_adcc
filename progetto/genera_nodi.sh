#!/bin/bash

shopt -s nocasematch
read -p " Execute script? (y/n): " response
if [[ $response == y ]]; then
    printf " Loading....\\n"
    #for ((x = 2; x<5; x++)); do
    #done
    
    printf " Open %s Terminal node1@localhost\\n" 
    osascript -e 'tell application "Terminal" to do script "erl -sname node1@localhost"' >/dev/null
    printf " Open %s Terminal node2@localhost\\n"
    osascript -e 'tell application "Terminal" to do script "erl -sname node2@localhost"' >/dev/null
    printf " Open %s Terminal node3@localhost\\n"
    osascript -e 'tell application "Terminal" to do script "erl -sname node3localhost"' >/dev/null
    printf " Open %s Terminal node4@localhost\\n"
    osascript -e 'tell application "Terminal" to do script "erl -sname node4localhost"' >/dev/null
fi
shopt -u nocasematch
