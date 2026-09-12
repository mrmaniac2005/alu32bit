set project_name [lindex $argv 0]
set RED "\033\[31m"
set GRN "\033\[32m"
set YEL "\033\[33m"
set CYN "\033\[36m"
set RST "\033\[0m"

if {$project_name eq ""} {
    puts "no project name passed"
    exit 
}

puts "${CYN}Trying to read files from proj: $project_name ${RST}"

open_project ./simulator/$project_name.xpr

puts "${CYN}======================= Source Files ===============================${RST}"
foreach k [get_files -of_objects [get_filesets sources_1]] {
    puts "${YEL} $k $project_name${RST}"
}

puts "${CYN}===================== Simulation Files =============================${RST}"
foreach k [get_files -of_objects [get_filesets sim_1]] {
    puts "${YEL} $k $project_name${RST}"
}

close_project

exit