package provide odfi::powerbuild 1.0.0
package require odfi::language 1.0.0
package require odfi::log 1.0.0

namespace eval odfi::powerbuild {


    odfi::language::Language default {

        :config name {
            +exportTo Config
            +exportToPublic
            +expose name

            +method getFullName args {
                if {[:isRoot]} {
                    return [:name get]
                } else {
                    return [:formatHierarchyString {$it name get} -]-[:name get]
                }
            
            
            }
            


            :task name {
                +expose name
            }

            :phase name {
                +expose name

                :requirements {
                    :package name {
                        +var version ""
                    }
                }

                :do script {

                }

                ## Run 
                +method run directory {

                    odfi::log::info "Running Phase from [pwd]"
                    ## Do Requirements 
                    :shade odfi::powerbuild::Requirements eachChild {

                        ## Package 
                        $it shade odfi::powerbuild::Package eachChild {
                            {package i} => 

                                odfi::log::info "Package requirement [$package name get]"
                                set res [exec aptitude show [$package name get]]

                                ## Look for state 
                                #puts "res $res"
                                regexp -line {^State:\s+(.+)$} $res -> state
                                odfi::log::info "State $state"

                                ## test 
                                if {$state=="not installed"} {
                                    if {[catch {exec sudo aptitude -y install [$package name get]}]} {
                                        error "Could not install package [$package name get]"
                                    }
                                } else {
                                    odfi::log::info "Package present"
                                }

                        }
                    }

                    ## Run scripts 
                    :shade odfi::powerbuild::Do eachChild {
                        eval [$it script get]
                    }
                      

                }
            }


            ## Building 
            ##################
            +method runPhase {name directory} {

                :shade odfi::powerbuild::Phase eachChild {
                  
                    if {[$it name get]==$name} {
                       
                        $it run $directory
                    }
                }
                

            }
            +method build {targetMatch phase {buildDirectory build} } {

                ## prepare build folder 
                set buildDirectory [pwd]/$buildDirectory

                odfi::log::info "Build Directory is $buildDirectory"

                :shade odfi::powerbuild::Config walkDepthFirstPreorder {

                    odfi::log::info "Testing node [$node getFullName]"
                    if {[string match $targetMatch [$node getFullName]]} {
                        

                        ## Set Build Folder 
                        set buildFolder $buildDirectory/[$node getFullName]
                        file mkdir $buildFolder

                        odfi::log::info "Building [$node name get] in $buildFolder"

                        set __current [pwd]
                        cd $buildFolder
                        try {
                            ## Run Phases and requirements
                            set allNodes [[$node getPrimaryParents]  += $node]
                            set phases {
                                init 
                                generate-sources
                                compile 
                                package
                                deploy
                            }
                            foreach phase $phases {
                                odfi::log::info "*** Entering Phase $phase ***"
                                $allNodes foreach {
                                    $it runPhase "$phase" $buildFolder
                                }
                            }
                        } finally {
                            cd ${__current}
                        }
                        

                    }
                }
            }
        }
    }


}
