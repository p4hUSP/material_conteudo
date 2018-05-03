#!/bin/sh

sudo apt-get install libgdal1-dev libproj-dev apt-file

sudo apt-file update

apt-file search proj_api.h

Rscript build.R
