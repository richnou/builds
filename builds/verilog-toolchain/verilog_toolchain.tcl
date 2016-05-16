

source ../../tcl/power-build.tm

package require odfi::git 2.0.0
package require odfi::richstream 3.0.0

puts "Hello: $env(PATH)"
puts "MVN: [exec which mvn]"
#exec sh [exec which mvn]
#exit 0

set baseLocation [file normalize [file dirname [info script]]]
#set targetPlatform [exec gcc -dumpmachine]

## Prepare output folder for all
set outputBase [file normalize [file dirname [info script]]/hdl-tc]




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
                    #odfi::files::writeToFile $output/share/config.site "
#test -z \"\$LDFLAGS\" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\"
#test -z \"\$CC\" && CC=\"x86_64-w64-mingw32-gcc\"
#"

                  
                    cd tcl8.6.5/win
                    odfi::powerbuild::exec sh configure --enable-64bit --prefix=$output

                    cd ../../tk8.6.5/win
                    odfi::powerbuild::exec sh configure --enable-64bit --prefix=$output
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

            :phase package {
                 :do {
                    cd ../../tcl8.6.5/win
                    odfi::powerbuild::exec  make install 
                    cd ../../tk8.6.5/win
                    odfi::powerbuild::exec  make install
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

                    #odfi::files::writeToFile $output/share/config.site "test -z \"\$LDFLAGS\" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\""

                 
                    
                    cd tcl8.6.5/win
                    odfi::powerbuild::exec sh configure --prefix=$output

                    cd ../../tk8.6.5/win
                    odfi::powerbuild::exec sh configure  --prefix=$output
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

            :phase package {
                 :do {
                    cd ../../tcl8.6.5/win
                    odfi::powerbuild::exec  make install 
                    cd ../../tk8.6.5/win
                    odfi::powerbuild::exec  make install
                }
            }
        }

        :config x86_64-pc-linux-gnu {
            :phase init {
                :do {

                    set ::output ${outputBase}-x86_64-pc-linux-gnu
                    file mkdir ${::output}

                    cd tcl8.6.5/unix
                    odfi::powerbuild::exec sh configure --enable-64bit --prefix=$output

                    cd ../../tk8.6.5/unix
                    odfi::powerbuild::exec sh configure --enable-64bit --prefix=$output
                }
            }

            :phase compile {
                :do {
                    cd ../../tcl8.6.5/unix
                    odfi::powerbuild::exec  make -j4
                    cd ../../tk8.6.5/unix
                    odfi::powerbuild::exec  make -j4
                }
            }

            :phase package {
                 :do {
                    cd ../../tcl8.6.5/unix
                    odfi::powerbuild::exec  make install 
                    cd ../../tk8.6.5/unix
                    odfi::powerbuild::exec  make install
                }
            }
        }

        
    }
    ## EOF TCL TK

    :config nsf {

        :phase init {

            :do {
                odfi::powerbuild::exec cp $baseLocation/packages/nsf2.0.0.tar.gz .
                odfi::powerbuild::exec tar xvzf nsf2.0.0.tar.gz
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
                    #odfi::files::writeToFile $output/share/config.site "
#test -z \"\$LDFLAGS\" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\"
#test -z \"\$CC\" && CC=\"x86_64-w64-mingw32-gcc\"
#"

                   
                    cd nsf2.0.0
                    odfi::powerbuild::exec sh configure --prefix=$output

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
                    #odfi::files::writeToFile $output/share/config.site "
#test -z \"\$LDFLAGS\" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\"
#test -z \"\$CC\" && CC=\"i686-w64-mingw32-gcc\"
#"

                   
                    cd nsf2.0.0
                    odfi::powerbuild::exec sh configure --prefix=$output

                 }
            }
        }

         :config x86_64-pc-linux-gnu {
            :phase init {
                :do {

                    set ::output ${outputBase}-x86_64-pc-linux-gnu
                    file mkdir ${::output}

                     cd nsf2.0.0
                     odfi::powerbuild::exec sh configure --prefix=$output

                 }
            }
        }



        :phase compile {
            :do {
                odfi::powerbuild::exec  make -j4  
            }
        }

        :phase package {
             :do {
                odfi::powerbuild::exec  make install
            }
        }

    }
    ## EOF NSF

    :config gtkwave {
        :phase init {

	    :requirements {
                :package gperf
	    }

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
                   # odfi::files::writeToFile $output/share/config.site "test -z \"\$LDFLAGS\" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\""

                  
                    odfi::powerbuild::exec sh configure --without-gconf  --disable-xz --prefix=$output   

                }
            }

            :phase package {
                :do {
                    set gccLoc [::exec which gcc]
                    set dirLoc [::exec dirname $gccLoc]
                    catch {::exec cp -f $dirLoc/*.dll $output/bin/}
                    catch {::exec cp -f /usr/x86_64-w64-mingw32/bin/*.dll $output/bin/}
                }
            }

           
        }

        :config i686-w64-mingw32 {

            :phase init {
                :do {

                    set ::output ${outputBase}-i686-w64-mingw32
                    file mkdir ${::output}

                    cd gtkwave-3.3.72
                    ::exec mkdir -p $output/share/
                    ::exec rm -f $output/share/config.site
                    ##odfi::files::writeToFile $output/share/config.site "test -z \"\$LDFLAGS\" && LDFLAGS=\"-LC:/msys64/mingw32/bin -static-libgcc -static-libstdc++ -static -lstdc++\""

                   
                    odfi::powerbuild::exec sh configure --without-gconf  --disable-xz --prefix=$output   

                }
            }

            :phase package {
                :do {
                    set gccLoc [::exec which gcc]
                    set dirLoc [::exec dirname $gccLoc]
                    catch {::exec cp -f $dirLoc/*.dll $output/bin/}
                    catch {::exec cp -f /usr/i686-w64-mingw32/bin/*.dll $output/bin/}
                }
            }

           
        }

        :config x86_64-pc-linux-gnu {
            :phase init {
                :do {

                    set ::output ${outputBase}-x86_64-pc-linux-gnu
                    file mkdir ${::output}

                    cd gtkwave-3.3.72

                   
                    odfi::powerbuild::exec sh autogen.sh
                    odfi::powerbuild::exec sh configure  --disable-xz --prefix=$output 
                }
            }
        }

        :phase compile {
            :do {
                odfi::powerbuild::exec  make -j4
            }
        }

        :phase package {
             :do {
                odfi::powerbuild::exec  make install

                
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

        :config i686-w64-mingw32 {
            :phase init {
                :do {



                    set ::output ${outputBase}-i686-w64-mingw32
                    file mkdir ${::output}

                    odfi::powerbuild::exec cp $baseLocation/packages/ghdl-0.33-win32.zip .
                    odfi::powerbuild::exec unzip -fuo ghdl-0.33-win32.zip
                    odfi::powerbuild::exec cp -Rfv ghdl-0.33/* $output 

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

        :phase package {
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
                    #odfi::files::writeToFile $output/share/config.site "test -z \"\$LDFLAGS\" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\""

                    
                    odfi::powerbuild::exec sh autoconf.sh
                    odfi::powerbuild::exec sh configure --prefix=$output
                }
            }

           
        }

        :config i686-w64-mingw32 {
            :phase init {
                :do {


                    set ::output ${outputBase}-i686-w64-mingw32
                    file mkdir ${::output}

                    cd iverilog
                    ::exec mkdir -p $output/share/
                    ::exec rm -f $output/share/config.site
                    #odfi::files::writeToFile $output/share/config.site "test -z \"\$LDFLAGS\" && LDFLAGS=\"-static-libgcc -static-libstdc++ -static -lstdc++\""

                    
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

        :phase package {
             :do {
   
                odfi::powerbuild::exec  make install
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

        :config i686-w64-mingw32 {
            :phase init {
                :do {

                    set ::output ${outputBase}-i686-w64-mingw32
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

        :phase package {
            :do {

                ## Manager
                ##############
                if {![file exists $output/odfi]} {
                    odfi::powerbuild::exec git clone -- https://github.com/richnou/odfi-manager.git $output/odfi
                } else {
                    odfi::git::pull $output/odfi
                }

                odfi::powerbuild::exec tclsh $output/odfi/bin/odfi --update
                odfi::powerbuild::exec tclsh $output/odfi/bin/odfi --install local.dev-tcl
                #odfi::powerbuild::exec tclsh $output/odfi/bin/odfi --install local.h2dl 
                odfi::powerbuild::exec tclsh $output/odfi/bin/odfi --install local.dev-hw

                if {![file exists $output/odfi/install/h2dl]} {
                    odfi::powerbuild::exec git clone -- https://github.com/richnou/h2dl.git $output/odfi/install/h2dl
                } else {
                    odfi::git::pull $output/odfi/install/h2dl
                }

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

                    cd h2dl/indesign
                    
                }
            }
            :phase package {
                :do {
                    
                    catch {exec cp -vf src/main/scripts/hdl-analyse.bat $output/}
                 
                }
            }
        }

        :config i686-w64-mingw32 {
            :phase init {
                :do {

                    set ::output ${outputBase}-i686-w64-mingw32
                    file mkdir ${::output}

                    cd h2dl/indesign
                    
                }
            }
            :phase package {
                :do {
                    
                    catch {exec cp -vf src/main/scripts/hdl-analyse.bat $output/}
                 
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
            :phase package {
                :do {
                    
                    catch {exec cp -vf src/main/scripts/hdl-analyse.bash $output/}
                 
                }
            }

        }


        :phase compile {
            :do {
            
                set mvnpath [::exec which mvn]
                puts "MVN Path: $mvnpath"
                odfi::powerbuild::exec sh $mvnpath -U package
                
            }
        }
        :phase package {
            :do {
                
                exec cp -vf target/h2dl-module-0.0.1-SNAPSHOT-shaded.jar $output/bin/h2dl-analyse.jar
             
            }
        }

    }

    :config finish {

        :config i686-w64-mingw32 {

            :phase package {
                :do {
                    set ::output ${outputBase}-i686-w64-mingw32
                    file mkdir ${::output}

                    cd ${::output}
                    odfi::powerbuild::exec tar -zcvf ../hdl-tc-i686-w64-mingw32.tar.gz * 

                }
            }
        }

        :config x86_64-w64-mingw32 {

            :phase package {
                :do {
                    set ::output ${outputBase}-x86_64-w64-mingw32
                    file mkdir ${::output}

                    cd ${::output}
                    cd ..
                    odfi::powerbuild::exec tar -zcvf hdl-tc-x86_64-w64-mingw32.tar.gz hdl-tc-x86_64-w64-mingw32

                }
            }
        }

        :config x86_64-pc-linux-gnu {

            :phase package {
                :do {
                    set ::output ${outputBase}-x86_64-pc-linux-gnu
                    file mkdir ${::output}

                    cd ${::output}
                    cd ..
                    puts "Inside: [pwd]"
                    puts "Rin: [::exec pwd]"
                    ##set res [::exec ls]
                    odfi::powerbuild::exec tar -zcvf hdl-tc-x86_64-pc-linux-gnu.tar.gz hdl-tc-x86_64-pc-linux-gnu
                    
                    #odfi::powerbuild::exec tar -zcvf hdl-tc-x86_64-pc-linux-gnu.tar.gz -C build-x86_64-pc-linux-gnu *
                    #odfi::powerbuild::exec tar -zcvf -C build-x86_64-pc-linux-gnu hdl-tc-x86_64-pc-linux-gnu.tar.gz  .[^.]* ..?* *


                    

                }
            }
        }

    }

}

$verilogtc build [lindex $argv 0] [lindex $argv 1] 
