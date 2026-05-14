# ILA Capture Script - Vivado 2023.2 Tcl
# Usage: vivado -mode tcl -source capture_ila.tcl -tclargs <pc_trace|nice_activity>

set mode [lindex $argv 0]
if {$mode eq ""} { puts "Usage: ... -tclargs <pc_trace|nice_activity>"; exit 1 }

set base "C:/Users/16084/Documents/Graduation_Design_Library/04_Experiments/Board_BringUp/2026-04-28_board_connection_check"

if {$mode eq "pc_trace"} {
    set bitfile   "$base/bootvec_sysclk_ila_artifacts/system.bit"
    set probefile "$base/bootvec_sysclk_ila_artifacts/debug_nets.ltx"
    set csvfile   "C:/Users/16084/Desktop/ila_pc_trace.csv"
    set trig_pos  256
    puts "=== ILA Capture: PC Boot Trace ==="
} elseif {$mode eq "nice_activity"} {
    set bitfile   "$base/cnn_sysclk_ila_artifacts/system.bit"
    set probefile "$base/cnn_sysclk_ila_artifacts/system.ltx"
    set csvfile   "C:/Users/16084/Desktop/ila_nice_activity.csv"
    set trig_pos  512
    puts "=== ILA Capture: NICE CNN Accelerator Activity ==="
} else {
    puts "Unknown mode: $mode"
    exit 1
}

# [1] Open hardware
puts "\[1/5\] Opening Hardware Manager..."
open_hw_manager
connect_hw_server
open_hw_target

# [2] Get device
puts "\[2/5\] Detecting device..."
set dev [lindex [get_hw_devices] 0]
puts "  Device: $dev"

# [3] Program
puts "\[3/5\] Programming..."
set_property PROBES.FILE $probefile $dev
set_property PROGRAM.FILE $bitfile $dev
program_hw_devices $dev
refresh_hw_device $dev
puts "  Programmed OK"

# [4] Get ILA & set trigger position
puts "\[4/5\] Setting up ILA..."
set ila [lindex [get_hw_ilas] 0]
puts "  ILA: $ila"
set_property CONTROL.TRIGGER_POSITION $trig_pos $ila

# [5] Run & wait
puts "\[5/5\] Running ILA capture..."

# Reset ILA state to ensure clean capture
reset_hw_ila $ila

# Let FPGA boot up after programming
puts "  Waiting for FPGA to boot..."
after 3000
refresh_hw_device $dev

# Arm ILA with immediate trigger
run_hw_ila $ila -trigger
after 2000
wait_on_hw_ila $ila

# If still no data, try direct trigger
after 1000
set data [get_hw_ila_data $ila]
if {[llength $data] == 0} {
    puts "  No data from first attempt, retrying with manual trigger..."
    run_hw_ila $ila
    after 3000
    trigger_hw_ila $ila
    after 2000
    set data [get_hw_ila_data $ila]
}
puts "  Capture done"

# [6] Export CSV
set data [get_hw_ila_data $ila]
write_hw_ila_data -csv_file $csvfile $data -force
puts "  CSV: $csvfile"

close_hw_manager
puts "=== Done: $mode ==="
