
source ../../tcl/power-build.tm

package require odfi::git 2.0.0
package require odfi::richstream 3.0.0


set runKit {#!/bin/bash

location="$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"
source $location/env.bash
#./build/pre.sh
./<% return ${::kitcreator} %>
}


odfi::powerbuild::config odfi {

    :phase init {
        :requirements {
            :package git
        }
    }

    :config tcl-kit {

        :object method addKitPackage name {
            exec echo "export KITCREATOR_PKGS=\"\$KITCREATOR_PKGS $name\"" >> env.bash
        }
        ##:object variable kitcreator "kitcreator"

        :phase init {
            :requirements {
                :package fossil
            }

            :do {   

                ## Default Kit Creator command
                set ::kitcreator kitcreator

                ## Get Kit Creator 
                if {![file exists kitcreator.fossil]} {
                    odfi::log::info "Cloning KIT Creator"
                    puts [exec fossil clone http://kitcreator.rkeene.org/fossil kitcreator.fossil]
                    puts [exec fossil open kitcreator.fossil]
                } else {
                    odfi::log::info "Updating KIT Creator"
                    puts [exec fossil pull http://kitcreator.rkeene.org/fossil]
                    puts [exec fossil update]
                }
                
                ## Custom env 
                exec rm  -f env.bash 
                exec touch env.bash

                ## Init 
                exec echo "export KITCREATOR_PKGS=\"\$KITCREATOR_PKGS tk\"" >> env.bash
                exec echo "export KITCREATOR_PKGS=\"\$KITCREATOR_PKGS itcl\"" >> env.bash

            }
        }

        :phase compile {
            :do {
                odfi::log::info "Running kit creator with ${::kitcreator}"
                #exec source env.bash && kitcreator

                odfi::richstream::template::stringToFile $runKit make-kit.sh
                exec chmod +x make-kit.sh

                catch {exec sh ./build/pre.sh}
                exec sh make-kit.sh 2>@1
               
            }
        }

        ## Dev TCL 
        :config dev-tcl {

            :phase init {

                :do {
                    ## Create folder dev-tcl
                    if {![file exists dev-tcl]} {
                        odfi::git::clone https://github.com/unihd-cag/odfi-dev-tcl.git dev-tcl
                    } else {
                        odfi::git::pull dev-tcl
                    }

                    ## Create Build File 
                    odfi::richstream::template::stringToFile {#!/bin/bash

## 
mkdir   -p  out/lib/odfi-dev-tcl 
mkdir   -p  inst/lib/odfi-dev-tcl 
cp      -Rf tcl/* out/lib/odfi-dev-tcl/
cp      -Rf tcl/* inst/lib/odfi-dev-tcl/

                    } dev-tcl/build.sh
                    exec chmod +x dev-tcl/build.sh

                    ## Run Kit 
                    #exec export KITCREATOR_PKGS="\$KITCREATOR_PKGS dev-tcl"
                    exec echo "export KITCREATOR_PKGS=\"\$KITCREATOR_PKGS nsf dev-tcl\"" >> env.bash
                  
                    #exec kitcreator
                }
                

                

            }

            :phase compile {

            }

            ## H2DL 
            ##########
            :config h2dl {

                :phase init {

                    :do {

                        ## Create folder
                        if {![file exists h2dl]} {
                            odfi::git::clone git@github.com:richnou/h2dl.git h2dl
                        } else {
                            odfi::git::pull h2dl
                        }

                        ## Create Build File 
                        odfi::richstream::template::stringToFile {#!/bin/bash

## 
mkdir   -p  out/lib/h2dl
mkdir   -p  inst/lib/h2dl
cp      -Rf tcl/* out/lib/h2dl
cp      -Rf tcl/* inst/lib/h2dl

                        } h2dl/build.sh
                        exec chmod +x h2dl/build.sh

                        ## Run Kit 
                        #exec export KITCREATOR_PKGS="\$KITCREATOR_PKGS dev-tcl"
                        exec echo "export KITCREATOR_PKGS=\"\$KITCREATOR_PKGS h2dl\"" >> env.bash

                    }
                }

                ## RFG 
                #########################
                :config rfg {

                    :phase init {

                        ## RFG 3
                        :do {


                            ## Create folder
                            if {![file exists rfg3]} {
                                odfi::git::clone http://ipe-iperic-srv1.ipe.kit.edu:8082/adl/rfg3.git rfg3
                            } else {
                                odfi::git::pull rfg3
                            }

                            ## Create Build File 
                            odfi::richstream::template::stringToFile {#!/bin/bash

        ## 
        mkdir   -p  out/lib/rfg3
        mkdir   -p  inst/lib/rfg3
        cp      -Rf tcl/* out/lib/rfg3
        cp      -Rf tcl/* inst/lib/rfg3

                            } rfg3/build.sh
                            exec chmod +x rfg3/build.sh

                            ## Run Kit 
                            #exec export KITCREATOR_PKGS="\$KITCREATOR_PKGS dev-tcl"
                            exec echo "export KITCREATOR_PKGS=\"\$KITCREATOR_PKGS rfg3\"" >> env.bash
                          
                            #exec kitcreator
                        }

                        ## RFG 2 
                        :do {
                            ## Create folder dev-tcl
                            if {![file exists rfg2]} {
                                odfi::git::clone https://github.com/unihd-cag/odfi-rfg.git rfg2
                            } else {
                                odfi::git::pull rfg2
                            }

                            ## Create Build File 
                            odfi::richstream::template::stringToFile {#!/bin/bash

        ## 
        mkdir   -p  out/lib/rfg2
        mkdir   -p  inst/lib/rfg2
        cp      -Rf tcl/* out/lib/rfg2
        cp      -Rf tcl/* inst/lib/rfg2

                            } rfg2/build.sh
                            exec chmod +x rfg2/build.sh

                            ## Run Kit 
                            #exec export KITCREATOR_PKGS="\$KITCREATOR_PKGS dev-tcl"
                            exec echo "export KITCREATOR_PKGS=\"\$KITCREATOR_PKGS rfg2\"" >> env.bash
                          
                            #exec kitcreator
                        }
                    

                    }
                    ## EOF Phase init 

                    ## Add CC Target
                    :config mingw64 {

                        :phase init {

                            :requirements {
                                :package "mingw-w64"
                            }
                            :do {
                                set ::kitcreator "build/make-kit-win64 --enable-kit-storage=zip"
                            }

                        }

                        :phase deploy {

                            :do {
                                exec scp tclkit-8.6.4 rleys@buddy.idyria.com:/data/access/osi/files/builds/tcl/rfg-full-latest.exe
                            }
                        }
                    }

                }
                ## EOF RFG
            }
            ## EOF H2DL

                

    
        

        }
        ## EOf Dev TCL

        

    }
    ## EOF Kit

}

$odfi build *mingw64* package 
