#!/bin/bash

## Make sure we have TCL
#########
sudo aptitude install tcl8.6 itcl3

## make sure we have ODFI 
########
if [[ ! -d .odfi ]] 
then
	git clone https://github.com/richnou/odfi-manager.git .odfi
	source .odfi/setup.linux.bash
	odfi --install local.dev-tcl

fi

source .odfi/setup.linux.bash
odfi --update

## Done
