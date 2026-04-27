if {$argc != 1} {
  error "Usage: vivado -mode batch -source program_vivado_bit.tcl -tclargs <system.bit>"
}

set bitfile [lindex $argv 0]
if {![file exists $bitfile]} {
  error "Bitstream not found: $bitfile"
}

open_hw_manager
connect_hw_server

set targets [get_hw_targets *]
if {[llength $targets] == 0} {
  error "No hardware targets found"
}

set opened 0
foreach target $targets {
  if {[catch {open_hw_target $target} err]} {
    puts "OPEN_TARGET_FAILED=$target"
    puts "OPEN_TARGET_ERROR=$err"
  } else {
    set opened 1
    break
  }
}

if {$opened == 0} {
  error "No FPGA device detected on the JTAG chain"
}

set devs [get_hw_devices xc7a100t_0]
if {[llength $devs] == 0} {
  error "Expected xc7a100t_0 was not found"
}

set dev [lindex $devs 0]
current_hw_device $dev
refresh_hw_device $dev
set_property PROGRAM.FILE $bitfile $dev
program_hw_devices $dev
puts "PROGRAM_PASS: $bitfile"
