#!/bin/bash

find . -type f | egrep "\.(coffee|css|haml|md|rb)" | xargs egrep -n "\t"
