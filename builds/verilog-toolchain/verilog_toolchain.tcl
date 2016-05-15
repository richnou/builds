

source ../../tcl/power-build.tm

package require odfi::git 2.0.0
package require odfi::richstream 3.0.0

puts "Hello"

set baseLocation [file normalize [file dirname [info script]]]
set targetPlatform [exec gcc -dumpmachine]

## Prepare output folder for all
set outputBase [file normalize [file dirname [info script]]/build]


proc bgerror {message} {
    set timestamp [clock format [clock seconds]]
    puts  "$timestamp: bgerror in $::argv '$message'"
   
}
interp bgerror {} bgerror


odfi::powerbuild::config verilogtc {

    :config tcltk {

        :phase init {

            :do {
              puts "Puts inside folder: [pwd]"  
              #odfi::powerbuild::exec wget http://prdownloads.sourceforge.net/tcl/tcl8.6.5-src.tar.gz
              odfi::powerbuild::exec cp $baseLocation/packages/tcl8.6.5-src.tar.gz .
              odfi::powerbuild::exec tar xvzf tcl8.6.5-src.tar.gz

              odfi::powerbuild::exec cp $baseLocation/packages/tk8.6.5-src.tar.gz .
              odfi::powerbuild::exec tar xvzf tk8.6.5-src.tar.gz
            }
        }

        :config x86_64-w64-mingw32 {
            :phase init {
                :do {

                    set ::output ${outputBase}-x86_64-w64-mingw32
                    file mkdir ${::output}

                    
                    set localpwd [::exec pwd]
                    ::exec mkdir -p $output/share/
                    ::exec rm -f $output/share/config.site
                    odfi::files::writeToFile $output/share/config.site "
test -z \"\$LDFLAGS\" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\"
test -z \"\$CC\" && CC=\"x86_64-w64-mingw32-gcc\"
"

                    #::exec echo test -z "\$LDFLAGS" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\" > $output/share/config.site
                    cd tcl8.6.5/win
                    odfi::powerbuild::exec sh configure --enable-64bit --prefix=$output

                    cd ../../tk8.6.5/win
                    odfi::powerbuild::exec sh configure --enable-64bit --prefix=$output
                }
            }

            
        }

        :config i686-w64-mingw32 {
            :phase init {
                :do {

                    set ::output ${outputBase}-i686-w64-mingw32
                    file mkdir ${::output}

                    
                    set localpwd [::exec pwd]
                    ::exec mkdir -p $output/share/
                    ::exec rm -f $output/share/config.site

                    odfi::files::writeToFile $output/share/config.site "test -z \"\$LDFLAGS\" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\""

                    #::exec echo test -z "\$LDFLAGS" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\" > $output/share/config.site
                    
                    cd tcl8.6.5/win
                    odfi::powerbuild::exec sh configure --prefix=$output

                    cd ../../tk8.6.5/win
                    odfi::powerbuild::exec sh configure  --prefix=$output
                }
            }
        }

        :config x86_64-pc-linux-gnu {
            :phase init {
                :do {

                    set ::output ${outputBase}-x86_64-pc-linux-gnu
                    file mkdir ${::output}

                    cd tcl8.6.5/win
                    odfi::powerbuild::exec sh configure --enable-64bit --prefix=$output

                    cd ../../tk8.6.5/win
                    odfi::powerbuild::exec sh configure --enable-64bit --prefix=$output
                }
            }
        }

        :phase compile {
            :do {
                cd ../../tcl8.6.5/win
                odfi::powerbuild::exec  make -j4
                cd ../../tk8.6.5/win
                odfi::powerbuild::exec  make -j4
            }
        }

        :phase deploy {
             :do {
                cd ../../tcl8.6.5/win
                odfi::powerbuild::exec  make install 
                cd ../../tk8.6.5/win
                odfi::powerbuild::exec  make install
            }
        }
    }

    :config gtkwave {
        :phase init {

            :do {
              puts "Puts inside folder: [pwd]"  
              #odfi::powerbuild::exec wget http://prdownloads.sourceforge.net/tcl/tcl8.6.5-src.tar.gz
              odfi::powerbuild::exec cp $baseLocation/packages/gtkwave-3.3.72.tar.gz .
              odfi::powerbuild::exec tar xvzf gtkwave-3.3.72.tar.gz
            }
        }

        :config x86_64-w64-mingw32 {

            :phase init {
                :do {

                    set ::output ${outputBase}-x86_64-w64-mingw32
                    file mkdir ${::output}

                    cd gtkwave-3.3.72
                    ::exec mkdir -p $output/share/
                    ::exec rm -f $output/share/config.site
                    odfi::files::writeToFile $output/share/config.site "test -z \"\$LDFLAGS\" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\""

                    #::exec echo test -z "\$LDFLAGS" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\" > $output/share/config.site
                    odfi::powerbuild::exec sh configure --without-gconf --prefix=$output   

                }
            }

           
        }

        :config x86_64-pc-linux-gnu {
            :phase init {
                :do {

                    set ::output ${outputBase}-x86_64-pc-linux-gnu
                    file mkdir ${::output}

                    cd gtkwave-3.3.72

                    #::exec echo test -z "\$LDFLAGS" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\" > $output/share/config.site
                    odfi::powerbuild::exec sh autogen.sh
                    odfi::powerbuild::exec sh configure  --prefix=$output 
                }
            }
        }

        :phase compile {
            :do {
                odfi::powerbuild::exec  make -j4
            }
        }

        :phase deploy {
             :do {
                odfi::powerbuild::exec  make install
                set gccLoc [::exec which gcc]
                set dirLoc [::exec dirname $gccLoc]
                ::exec cp -f $dirLoc/*.dll $output/bin/
            }
        }
    }

    :config ghdl {
        :phase init {

            :do {
                ## Create folder dev-tcl
                #puts "INit iverilog from [pwd]"
                #if {![file exists iverilog]} {
               #     odfi::powerbuild::exec git clone https://github.com/tgingold/ghdl.git ghdl
               # } else {
                #    odfi::git::pull ghdl
                #}
                
            }
        }


        :config x86_64-w64-mingw32 {
            :phase init {
                :do {



                    set ::output ${outputBase}-x86_64-w64-mingw32
                    file mkdir ${::output}

                    odfi::powerbuild::exec cp $baseLocation/packages/ghdl-0.33-win32.zip .
                    odfi::powerbuild::exec unzip -fuo ghdl-0.33-win32.zip
                    odfi::powerbuild::exec cp -Rfv ghdl-0.33/* $output 

                    #cd ghdl
                    #::exec mkdir -p $output/share/
                    #::exec rm -f $output/share/config.site
                    #odfi::files::writeToFile $output/share/config.site "test -z \"\$LDFLAGS\" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\""

                    # odfi::powerbuild::exec sh configure --prefix=$output --with-llvm-config

                }
            }

           
        }

        :config x86_64-pc-linux-gnu {
            :phase init {
                :do {

                    set ::output ${outputBase}-x86_64-pc-linux-gnu
                    file mkdir ${::output}

                    odfi::powerbuild::exec cp $baseLocation/packages/ghdl-0.33-x86_64-linux.tgz .
                    odfi::powerbuild::exec tar xvzf ghdl-0.33-x86_64-linux.tgz
                    odfi::powerbuild::exec cp -Rfv ghdl-0.33/* $output 

                    #cd ghdl
                    #odfi::powerbuild::exec sh configure  --prefix=$output --with-llvm-config
                }
            }
        }

        :phase compile {
            :do {
                #odfi::powerbuild::exec  make -j4
            }
        }

        :phase deploy {
             :do {
                #odfi::powerbuild::exec  make install
            }
        }

        
    }

    :config iverilog {

        :phase init {

            :requirements {
                :package flex 
                :package bison
                :package gperf
            }

            :do {
                ## Create folder dev-tcl
                puts "INit iverilog from [pwd]"
                if {![file exists iverilog]} {
                    odfi::powerbuild::exec git clone -b v10-branch -- git://github.com/steveicarus/iverilog.git iverilog
                } else {
                    odfi::git::pull iverilog
                }
            }
        }

        :config x86_64-w64-mingw32 {
            :phase init {
                :do {


                    set ::output ${outputBase}-x86_64-w64-mingw32
                    file mkdir ${::output}

                    cd iverilog
                    ::exec mkdir -p $output/share/
                    ::exec rm -f $output/share/config.site
                    odfi::files::writeToFile $output/share/config.site "test -z \"\$LDFLAGS\" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\""

                    #::exec echo test -z "\$LDFLAGS" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\" > $output/share/config.site
                    odfi::powerbuild::exec sh autoconf.sh
                    odfi::powerbuild::exec sh configure --prefix=$output
                }
            }

           
        }

        :config x86_64-pc-linux-gnu  {
            :phase init {
                :do {

                    set ::output ${outputBase}-x86_64-pc-linux-gnu
                    file mkdir ${::output}

                    cd iverilog
                    
                    #::exec echo test -z "\$LDFLAGS" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\" > $output/share/config.site
                    odfi::powerbuild::exec sh autoconf.sh
                    odfi::powerbuild::exec sh configure --prefix=$output
                }
            }

           
        }

        :phase compile {
            :do {
   
                odfi::powerbuild::exec  make -j4
            }
        }

        :phase deploy {
             :do {
   
                odfi::powerbuild::exec  make install
            }
        }

    }

    :config h2dl-indesign {

        :phase init {

            :requirements {
                :package maven 
            }

            :do {
                ## Create folder dev-tcl
                puts "INit iverilog from [pwd]"
                if {![file exists h2dl]} {
                    odfi::powerbuild::exec git clone -- https://github.com/richnou/h2dl.git
                } else {
                    odfi::git::pull h2dl
                }
            }
        }

        :config x86_64-w64-mingw32 {
            :phase init {
                :do {

                    set ::output ${outputBase}-x86_64-w64-mingw32
                    file mkdir ${::output}

                    cd h2dl
                    
                }
            }
        }

        :config x86_64-pc-linux-gnu {
            :phase init {
                :do {

                    set ::output ${outputBase}-x86_64-pc-linux-gnu
                    file mkdir ${::output}

                    cd h2dl/indesign
                    
                }
            }
        }


        :phase compile {
            :do {
            
                odfi::powerbuild::exec mvn package
               
            }
        }
        :phase deploy {
            :do {
                
                exec cp -vf target/h2dl-module-0.0.1-SNAPSHOT-shaded.jar $output/bin/h2dl-analyse.jar
             
            }
        }

    }

    :config odfi {

        :config x86_64-w64-mingw32 {
            :phase init {
                :do {

                    set ::output ${outputBase}-x86_64-w64-mingw32
                    file mkdir ${::output}
                    
                }
            }
        }

        :config x86_64-pc-linux-gnu {
            :phase init {
                :do {

                    set ::output ${outputBase}-x86_64-pc-linux-gnu
                    file mkdir ${::output}
                    
                }
            }
        }

        :phase deploy {
            :do {

            }
        }

    }

}

$verilogtc build [lindex $argv 0] [lindex $argv 1] 