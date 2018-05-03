#!/bin/sh

sudo apt-get install apt-file

sudo apt-file update

apt-file search proj_api.h

Rscript build.R
