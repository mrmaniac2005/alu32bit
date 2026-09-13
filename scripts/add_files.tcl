set project_name [lindex $argv 0]
set RED "\033\[31m"
set GRN "\033\[32m"
set YEL "\033\[33m"
set CYN "\033\[36m"
set RST "\033\[0m"
set_msg_config -severity INFO -suppress
if {$project_name eq ""} {
    puts "no project name passed"
    exit 
}

puts "${CYN}Attempting to add files to proj: $project_name ${RST}"

open_project ./simulator/$project_name.xpr

puts "${GRN}current project: $project_name ${RST}"

foreach k [get_files] {
    remove_files $k
}

foreach k [glob -nocomplain ./source/*] {
    add_files $k
    puts "${YEL}added file: $k to sources ${RST}"
}

foreach k [glob -nocomplain ./simulation/*] {
    add_files -fileset sim_1 $k
    puts "${YEL}added file: $k to simulation ${RST}"
}

foreach k [glob -nocomplain ./synthesized/*] {
    add_files -fileset sim_1 $k
    puts "${YEL}added file: $k to simulation ${RST}"
}

puts "${GRN}successfully added files to project: $project_name ${RST}"

close_project

exit