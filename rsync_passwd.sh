#!/bin/bash

# load passwd from remote site
rsync -avzu nesono.com:~/.passwd ~/.passwd > /dev/null 2>&1
rsync -avzu ~/.passwd nesono.com:~/.passwd > /dev/null 2>&1
