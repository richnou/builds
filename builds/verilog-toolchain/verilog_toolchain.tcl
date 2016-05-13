

source ../../tcl/power-build.tm

package require odfi::git 2.0.0
package require odfi::richstream 3.0.0

puts "Hello"

set targetPlatform [exec gcc -dumpmachine]

## Prepare output folder for all
set output [file normalize [file dirname [info script]]/build-$targetPlatform]
file mkdir $output

proc bgerror {message} {
    set timestamp [clock format [clock seconds]]
    puts  "$timestamp: bgerror in $::argv '$message'"
   
}
interp bgerror {} bgerror


odfi::powerbuild::config verilogtc {

    :config tcl {

        :phase init {

            :do {
              puts "Puts inside folder: [pwd]"  
              odfi::powerbuild::exec wget http://prdownloads.sourceforge.net/tcl/tcl8.6.5-src.tar.gz
              odfi::powerbuild::exec tar xvzf tcl8.6.5-src.tar.gz
            }
        }

        :config x86_64-w64-mingw32 {
            :phase init {
                :do {
                    cd tcl8.6.5/win
                    set localpwd [::exec pwd]
                    ::exec mkdir -p $output/share/
                    ::exec rm -f $output/share/config.site

                    odfi::files::writeToFile $output/share/config.site "test -z \"\$LDFLAGS\" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\""

                    #::exec echo test -z "\$LDFLAGS" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\" > $output/share/config.site
                    odfi::powerbuild::exec sh configure --enable-64bit --prefix=$output
                }
            }

            
        }

        :config i686-w64-mingw32 {
            :phase init {
                :do {
                    cd tcl8.6.5/win
                    set localpwd [::exec pwd]
                    ::exec mkdir -p $output/share/
                    ::exec rm -f $output/share/config.site

                    odfi::files::writeToFile $output/share/config.site "test -z \"\$LDFLAGS\" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\""

                    #::exec echo test -z "\$LDFLAGS" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\" > $output/share/config.site
                    odfi::powerbuild::exec sh configure  --prefix=$output
                }
            }
        }

        :phase compile {
            :do {
                #cd tcl8.6.5/win
                odfi::powerbuild::exec  make -j4
            }
        }

        :phase deploy {
             :do {
                #cd tcl8.6.5/win
                odfi::powerbuild::exec  make install
            }
        }
    }

    :config gtkwave {

    }

    :config ghdl {
        :phase init {

            :do {
                ## Create folder dev-tcl
                puts "INit iverilog from [pwd]"
                if {![file exists iverilog]} {
                    odfi::powerbuild::exec git clone https://github.com/tgingold/ghdl.git ghdl
                } else {
                    odfi::git::pull ghdl
                }
            }
        }


        :config x86_64-w64-mingw32 {
            :phase init {
                :do {
                    cd ghdl
                    ::exec mkdir -p $output/share/
                    ::exec rm -f $output/share/config.site
                    odfi::files::writeToFile $output/share/config.site "test -z \"\$LDFLAGS\" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\""

                    #::exec echo test -z "\$LDFLAGS" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\" > $output/share/config.site
                    odfi::powerbuild::exec sh configure --prefix=$output --with-llvm-config

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

    :config iverilog {

        :phase init {

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

        :phase compile {
            :do {
                cd iverilog
                odfi::powerbuild::exec  make -j4
            }
        }

        :phase deploy {
             :do {
                cd iverilog
                odfi::powerbuild::exec  make install
            }
        }

    }

}

$verilogtc build [lindex $argv 0] [lindex $argv 1] 