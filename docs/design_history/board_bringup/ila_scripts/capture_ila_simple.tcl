# Ultra-simple ILA capture with forced immediate trigger
set mode [lindex $argv 0]
set base "C:/Users/16084/Documents/Graduation_Design_Library/04_Experiments/Board_BringUp/2026-04-28_board_connection_check"

if {$mode eq "pc_trace"} {
    set probefile "$base/bootvec_sysclk_ila_artifacts/debug_nets.ltx"
    set csvfile   "C:/Users/16084/Desktop/ila_pc_trace.csv"
} elseif {$mode eq "nice_activity"} {
    set probefile "$base/cnn_sysclk_ila_artifacts/system.ltx"
    set csvfile   "C:/Users/16084/Desktop/ila_nice_activity.csv"
} else {
    puts "Usage: -tclargs <pc_trace|nice_activity>"
    exit 1
}

puts "=== ILA Capture: $mode ==="

open_hw_manager
connect_hw_server
open_hw_target

set dev [lindex [get_hw_devices] 0]
puts "Device: $dev"

# Set probes WITHOUT programming (FPGA keeps running)
set_property PROBES.FILE $probefile $dev
refresh_hw_device $dev

set ila [lindex [get_hw_ilas] 0]
puts "ILA: $ila"

# Use immediate trigger - force capture NOW
set_property CONTROL.TRIGGER_MODE BASIC_ONLY $ila
set_property CONTROL.TRIGGER_POSITION 512 $ila

run_hw_ila $ila
after 3000

# Force immediate trigger
trigger_hw_ila $ila
after 2000

# Read data
set data [get_hw_ila_data $ila]
set sample_count [get_property SAMPLE_COUNT [get_hw_ila_datas]]
puts "Sample count: $sample_count"

write_hw_ila_data -csv_file $csvfile $data -force
puts "CSV: $csvfile"

close_hw_manager
puts "Done"
