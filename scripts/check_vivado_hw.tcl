open_hw_manager
connect_hw_server

set targets [get_hw_targets *]
puts "HW_TARGETS=$targets"

if {[llength $targets] == 0} {
  error "No hardware targets found. Check the JTAG cable and Vivado cable drivers."
}

set opened 0
foreach target $targets {
  puts "TRY_OPEN_TARGET=$target"
  if {[catch {open_hw_target $target} err]} {
    puts "OPEN_TARGET_FAILED=$target"
    puts "OPEN_TARGET_ERROR=$err"
  } else {
    set opened 1
    break
  }
}

if {$opened == 0} {
  error "Hardware target exists, but no FPGA device was detected on the JTAG chain. Check board power, JTAG wiring, and mode switches."
}

set devices [get_hw_devices]
puts "HW_DEVICES=$devices"

if {[llength $devices] == 0} {
  error "No hardware devices found after opening target"
}

foreach dev $devices {
  puts "HW_DEVICE=[get_property PART $dev] NAME=$dev"
}

if {[llength [get_hw_devices xc7a100t_0]] == 0} {
  error "Expected xc7a100t_0 was not found"
}

puts "CHECK_PASS: xc7a100t_0 detected"
