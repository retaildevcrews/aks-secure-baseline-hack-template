#!/bin/sh

# install WebV (using the beta for testing)
# we can't install this in the base image
dotnet tool install -g --version 2.0.0-beta2 webvalidate

# configure git per team standards
git config --global core.whitespace blank-at-eol,blank-at-eof,space-before-tab
git config --global pull.rebase false
git config --global init.defaultbranch main
git config --global core.pager more
