#------------------------------------------------------------
# Usage: run.tcl <project_name> <dut_name>
#------------------------------------------------------------
set project_name [lindex $argv 0]
set RED "\033\[31m"
set GRN "\033\[32m"
set YEL "\033\[33m"
set CYN "\033\[36m"
set RST "\033\[0m"
set project_name [lindex $argv 0]
set dut_name     [lindex $argv 1]
set sim_dir "./simulator/$project_name.sim/sim_1/behav/xsim"
set_msg_config -severity INFO -suppress

# Check arguments
if {$project_name eq "" || $dut_name eq ""} {
    puts "${RED}Usage: run.tcl <project_name> <dut_name>${RST}"
    exit 1
}

puts "Running simulation for project: $project_name, DUT: $dut_name"
puts "${GRN}Simulation started...${RST}"

# Open project`
open_project "./simulator/$project_name.xpr"
puts "Current project: [current_project]"

# Set simulation top
set_property top $dut_name [get_filesets sim_1]

# Remove stale VCDs
foreach f [glob -nocomplain "$sim_dir/*.vcd"] {
    file delete -force $f
}


# Run simulation
set rc [catch {
    launch_simulation
    run all
   file mkdir ./coverage_reports

    catch {
        write_xsim_coverage -cov_db_name ${dut_name}_cov

        export_xsim_coverage \
            -cov_db_name ${dut_name}_cov \
            -report_format text \
            -output_dir ./coverage_reports
    } cov_err

    if {$cov_err ne ""} {
        puts "${YEL}Coverage export skipped (BASIC license).${RST}"
    }
} err]

# Always close simulator
catch {close_sim}

# Handle failure
if {$rc} {
    puts "${RED}Simulation failed:${RST}"
    puts "${RED}$err${RST}"

    close_project
    catch {file delete -force "./simulator/$project_name.sim"}

    exit 1
}

# Copy generated VCD
file mkdir ./waves

set vcd_files [glob -nocomplain "$sim_dir/*.vcd"]

if {[llength $vcd_files] > 0} {
    file copy -force [lindex $vcd_files 0] "./waves/$dut_name.vcd"
    puts "${GRN}VCD saved: ./waves/$dut_name.vcd${RST}"
} else {
    puts "${YEL}No VCD generated.${RST}"
}

# Cleanup
close_project
catch {file delete -force "./simulator/$project_name.sim"}

exit 0