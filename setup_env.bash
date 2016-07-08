#!/bin/bash

loc=$(dirname "$(readlink -f ${BASH_SOURCE[0]})")


## Make sure we have TCL
#########
sudo aptitude install tcl8.5 tcl8.6 itcl3

## make sure we have ODFI 
########
if [[ ! -d $loc/.odfi ]] 
then
	git clone https://github.com/richnou/odfi-manager.git $loc/.odfi
	source $loc/.odfi/setup.linux.bash
	odfi --install local.dev-tcl

fi

source .odfi/setup.linux.bash
odfi --update

## Done
