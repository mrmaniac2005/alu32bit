set project_name [lindex $argv 0]

set_msg_config -severity INFO -suppress

if {$project_name eq ""} {
    puts "no project name passed"
    exit 1
}

puts "Initializing project creation $project_name"

create_project $project_name ./simulator -force

puts "project created successfully: $project_name"

close_project

exit