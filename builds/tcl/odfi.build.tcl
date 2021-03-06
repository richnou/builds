
source ../../tcl/power-build.tm

package require odfi::git 2.0.0
package require odfi::richstream 3.0.0


set buildScriptLocation [file normalize [file dirname [info script]]]

set runKit {#!/bin/bash

location="$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"
source $location/env.bash
./build/pre.sh  2>@1
./<% return ${::kitcreator} %>  2>@1
}

set tclVersion 8.6.5

odfi::powerbuild::config odfi {

    :phase init {
        :requirements {
            :package git
        }
    }

    :config tclkit {

        :object method addKitPackage name {
            exec echo "export KITCREATOR_PKGS=\"\$KITCREATOR_PKGS $name\"" >> env.bash
        }
        ##:object variable kitcreator "kitcreator"

        :phase init {
            :requirements {
                :package fossil 
                :package autoconf
                :package patch
                :package make 
            }

            :do {   

                ## Default Kit Creator command
                set ::kitcreator "kitcreator ${::tclVersion}"

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
                exec echo "export PATH=\"\$PATH:[pwd]/common/helpers\"" >> env.bash
                exec echo "export KITCREATOR_PKGS=\"\$KITCREATOR_PKGS tk nsf\"" >> env.bash
                exec echo "export KITCREATOR_PKGS=\"\$KITCREATOR_PKGS itcl\"" >> env.bash
                 exec echo "export KITCREATOR_PKGS=\"\$KITCREATOR_PKGS tclvfs\"" >> env.bash
                  exec echo "export KITCREATOR_PKGS=\"\$KITCREATOR_PKGS mk4tcl\"" >> env.bash

            }
        }

        :phase compile {
    

            :do {
                odfi::log::info "Running kit creator with ${::kitcreator}"
                #exec source env.bash && kitcreator

                odfi::richstream::template::stringToFile $runKit make-kit.sh
                exec chmod +x make-kit.sh

       
                odfi::powerbuild::exec sh make-kit.sh
               
            }
        }

        ## Add CC Target
        :config win64 {

            :phase init {

                :requirements {
                    :package "mingw-w64"
                    :package "zip"
                }
                :do {
                    set ::kitcreator "build/make-kit-win64 ${::tclVersion} --enable-64bit --enable-kit-storage=cvfs"
                }

            }

            :phase deploy {

                :do {
                    exec scp tclkit-${::tclVersion} ${::env(USER)}@buddy.idyria.com:/data/access/osi/files/builds/tcl/tclkit-${::tclVersion}-latest-win64.exe
                }
            }
        }

        ## Dev TCL 
        ###############################
        :config dev_tcl {

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
                  
                   
                }
                

                

            }

            :phase compile {

            }

            ## Add CC Target
            :config win64 {

                

                :phase deploy {

                    :do {
                        exec scp tclkit-${::tclVersion} ${::env(USER)}@buddy.idyria.com:/data/access/osi/files/builds/tcl/dev-tcl-full-latest-win64.exe
                    }
                }
            }

             ## Add CC Target
            :config x86_64-w64-mingw32 {
                set :ignore true
                :phase init {

                    :requirements {
                        :package "mingw-w64"
                        :package "zip"
                    }
                    :do {
                        set ::kitcreator "./kitcreator ${::tclVersion} --enable-64bit --enable-kit-storage=cvfs"
                    }

                }

                :phase deploy {

                    :do {
                        #exec scp tclkit-${::tclVersion} ${::env(USER)}@buddy.idyria.com:/data/access/osi/files/builds/tcl/dev-tcl-full-latest-win64.exe
                    }
                }
            }


            ## Add CC Target
            :config x86_64-gnu-linux {

                :phase deploy {

                    :do {
                        exec scp tclkit-${::tclVersion} ${::env(USER)}@buddy.idyria.com:/data/access/osi/files/builds/tcl/dev-tcl-full-latest-x86_64-gnu-linux.exe
                    }
                }
            }

            ## H2DL 
            ##########
            :config h2dl {

                :phase init {

                    :do {

                        ## Create folders
                        if {![file exists h2dl]} {
                            odfi::git::clone git@github.com:richnou/h2dl.git h2dl
                        } else {
                            odfi::git::pull h2dl
                        }
                        if {![file exists odfi-dev-hw]} {
                            odfi::git::clone git@github.com:unihd-cag/odfi-dev-hw.git dev-hw
                        } else {
                            odfi::git::pull dev-hw
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
                        odfi::richstream::template::stringToFile {#!/bin/bash

## 
mkdir   -p  out/lib/dev-hw
mkdir   -p  inst/lib/dev-hw
cp      -Rf tcl/* out/lib/dev-hw
cp      -Rf tcl/* inst/lib/dev-hw

                        } dev-hw/build.sh


                        exec chmod +x dev-hw/build.sh

                        ## Run Kit 
                        #exec export KITCREATOR_PKGS="\$KITCREATOR_PKGS dev-tcl"
                        exec echo "export KITCREATOR_PKGS=\"\$KITCREATOR_PKGS h2dl dev-hw\"" >> env.bash

                    }
                }

                ## Add CC Target
                :config win64 {


                    :phase deploy {

                        :do {
                            exec scp tclkit-${::tclVersion} ${::env(USER)}@buddy.idyria.com:/data/access/osi/files/builds/tcl/h2dl-full-latest-win64.exe
                        }
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
                                odfi::git::clone https://github.com/kit-adl/rfg3.git rfg3
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
                          
                           
                        }
                    

                    }
                    ## EOF Phase init 

                    ## Add CC Target
                    :config win64 {

                        :phase deploy {

                            :do {
                                odfi::powerbuild::exec scp tclkit-${::tclVersion} ${::env(USER)}@buddy.idyria.com:/data/access/osi/files/builds/tcl/rfg-full-latest-win64.exe
                            }
                        }
                    }

                    ## Add CC Target
                    :config x86_64-gnu-linux {


                        :phase deploy {

                            :do {
                                odfi::powerbuild::exec scp tclkit-${::tclVersion} ${::env(USER)}@buddy.idyria.com:/data/access/osi/files/builds/tcl/rfg-full-latest-x86_64-gnu-linux
                            }
                        }
                    }

                }
                ## EOF RFG
            }
            ## EOF H2DL


            ## Duckdoc 
            ##########
            :config duckdoc {

                :phase init {

                    :do {



                        ## Create folders
                        if {![file exists duckdoc]} {
                            odfi::git::clone git@github.com:richnou/odfi-doc.git duckdoc
                        } else {
                            odfi::git::pull duckdoc
                        }
                       

                        ## Create Build File 
                        odfi::richstream::template::stringToFile {#!/bin/bash

## 
mkdir   -p  out/lib/duckdoc
mkdir   -p  inst/lib/duckdoc
mkdir   -p  inst/bin/
mkdir   -p  out/bin/
cp      -Rf tcl/* out/lib/duckdoc
cp      -Rf tcl/* inst/lib/duckdoc
cp      -Rf bin/* inst/bin/
cp      -Rf bin/* out/bin/

                        } duckdoc/build.sh
                        exec chmod +x duckdoc/build.sh
                        

                        ## Run Kit 
                        #exec export KITCREATOR_PKGS="\$KITCREATOR_PKGS dev-tcl"
                        exec echo "export KITCREATOR_PKGS=\"\$KITCREATOR_PKGS  tcllib duckdoc\"" >> env.bash
                       

                    }
                }

                ## Package Starpack
                :phase package {

                    :do {
                        puts "Creating Starpack"

                        ## Go to Duck doc
                        cd duckdoc
                        try {

                            ## Copy
                            #cp ../tclkit-${::tclVersion} tclkit
                            exec chmod +x bin/duckdoc 
                            $odfi makeStarPack ../tclkit-${::tclVersion} bin/duckdoc

                        } finally {
                            cd ..
                        }
                    }
                }

                ## Add CC Target
                :config win64 {

                    :phase deploy {

                        :do {
                            odfi::powerbuild::exec scp tclkit-${::tclVersion} ${::env(USER)}@buddy.idyria.com:/data/access/osi/files/builds/tcl/duckdoc-full-latest-win64.kit.exe
                            odfi::powerbuild::exec scp duckdoc/duckdoc ${::env(USER)}@buddy.idyria.com:/data/access/osi/files/builds/tcl/duckdoc-win64.exe
                        }
                    }
                }

                ## Add CC Target
                :config x86_64-gnu-linux {

                    :phase deploy {

                        :do {
                            $odfi scpCopy tclkit-${::tclVersion}  x86_64-gnu-linux duckdoc-latest.kit rleys
                            $odfi scpCopy duckdoc/duckdoc         x86_64-gnu-linux duckdoc            rleys

                            #odfi::powerbuild::exec scp tclkit-${::tclVersion} ${::env(USER)}@buddy.idyria.com:/data/access/osi/files/builds/tcl/x86_64-gnu-linux/duckdoc-latest.kit
                            #odfi::powerbuild::exec scp duckdoc/duckdoc        ${::env(USER)}@buddy.idyria.com:/data/access/osi/files/builds/tcl/x86_64-gnu-linux/duckdoc
                        }
                    }
                }



               
            }
            ## EOF Duckdoc
                

    
        

        }
        ## EOf Dev TCL

        

    }
    ## EOF Kit


    ## Utilities
    #########################

    :public object method scpCopy {source system destination {user ""}} {

        if {$user==""} {
            set user ${::env(USER)}
        }

        #puts "Iploadung scp $source ${user}@buddy.idyria.com:/data/access/osi/files/builds/tcl/$system/$destination"
        
        #odfi::powerbuild::exec ssh ${user}@buddy.idyria.com "mkdir -p [file dirname $destination]"

        exec scp $source ${user}@buddy.idyria.com:/data/access/osi/files/builds/tcl/$system/$destination
    }

    :public object method makeStarPack {tclkit baseScript} {

        set baseScript [file normalize $baseScript]
        set baseScriptName [lindex [split [file tail $baseScript] .] 0]

        ## base script must be .tcl, if not copy
        if {![string match *.tcl $baseScript]} {

            exec cp $baseScript [file dirname $baseScript]/$baseScriptName.tcl 
            set baseScript  [file dirname $baseScript]/$baseScriptName.tcl 
 
        }

        set tclkit [file normalize $tclkit]

        puts "CREATIN STARTPACK: $baseScript from [pwd] with kit $tclkit"
        set sdxPath ${::buildScriptLocation}/starpack/sdx.kit 

        ## Clean 
        exec rm -Rf ${baseScriptName}
        exec rm -Rf ${baseScriptName}.kit
        exec rm -Rf ${baseScriptName}.vfs

        ## Copy kit
        odfi::powerbuild::exec cp "$tclkit" tclkit

        ## QWrap
        odfi::powerbuild::exec $tclkit $sdxPath qwrap ${baseScript}

        ## Unwrap and Wrap with runtime
        odfi::powerbuild::exec $tclkit $sdxPath unwrap ${baseScriptName}.kit
        odfi::powerbuild::exec $tclkit $sdxPath wrap ${baseScriptName} -runtime tclkit
        exec rm -f tclkit

    }

}

$odfi build [lindex $argv 0] [lindex $argv 1] 
