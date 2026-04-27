if {$argc != 3} {
  error "Usage: vivado -mode batch -source capture_vivado_ila.tcl -tclargs <system.bit> <system.ltx> <output_dir>"
}

set bitfile [lindex $argv 0]
set probesfile [lindex $argv 1]
set output_dir [lindex $argv 2]

foreach path [list $bitfile $probesfile] {
  if {![file exists $path]} {
    error "Required file not found: $path"
  }
}
file mkdir $output_dir

set summary_file [file join $output_dir "ila_summary.txt"]
set fh [open $summary_file "w"]
proc logline {fh msg} {
  puts $msg
  puts $fh $msg
  flush $fh
}

open_hw_manager
connect_hw_server

set targets [get_hw_targets *]
logline $fh "HW_TARGETS=$targets"
if {[llength $targets] == 0} {
  error "No hardware targets found"
}

set opened 0
foreach target $targets {
  if {[catch {open_hw_target $target} err]} {
    logline $fh "OPEN_TARGET_FAILED=$target"
    logline $fh "OPEN_TARGET_ERROR=$err"
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
set_property PROGRAM.FILE $bitfile $dev
set_property PROBES.FILE $probesfile $dev
program_hw_devices $dev
refresh_hw_device $dev

logline $fh "PROGRAM_PASS=$bitfile"
logline $fh "PROBES_FILE=$probesfile"

set ilas [get_hw_ilas]
logline $fh "HW_ILAS=$ilas"
if {[llength $ilas] == 0} {
  logline $fh "ILA_STATUS=NO_HW_ILAS_FOUND"
  close $fh
  exit 0
}

foreach ila $ilas {
  logline $fh "ILA=$ila"
  foreach prop [list NAME CORE_UUID CONTROL.DATA_DEPTH CONTROL.TRIGGER_POSITION STATUS] {
    if {![catch {set value [get_property $prop $ila]}]} {
      logline $fh "ILA_PROPERTY.$prop=$value"
    }
  }
}

set probes [get_hw_probes]
logline $fh "HW_PROBES=$probes"
foreach probe $probes {
  set pname [get_property NAME $probe]
  set pwidth ""
  catch {set pwidth [get_property WIDTH $probe]}
  logline $fh "PROBE=$pname WIDTH=$pwidth"
}

set ila [lindex $ilas 0]
set capture_status "NOT_RUN"
current_hw_ila $ila
catch {set_property CONTROL.CAPTURE_MODE ALWAYS $ila}
if {![catch {run_hw_ila -trigger_now $ila} run_err]} {
  if {[catch {wait_on_hw_ila -timeout 0.2 $ila} wait_err]} {
    set capture_status "WAIT_FAILED=$wait_err"
  } else {
    set capture_status "CAPTURED"
    if {![catch {set data [upload_hw_ila_data $ila]} upload_err]} {
      set csv_file [file join $output_dir "ila_capture.csv"]
      if {[catch {write_hw_ila_data -force -csv_file $csv_file $data} write_err]} {
        logline $fh "ILA_CSV_WRITE_FAILED=$write_err"
        set capture_status "CSV_WRITE_FAILED"
      } else {
        logline $fh "ILA_CSV=$csv_file"
      }
    } else {
      logline $fh "ILA_UPLOAD_FAILED=$upload_err"
      set capture_status "UPLOAD_FAILED"
    }
  }
} else {
  set capture_status "RUN_FAILED=$run_err"
}
logline $fh "ILA_CAPTURE_STATUS=$capture_status"

close $fh
