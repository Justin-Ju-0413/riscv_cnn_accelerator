@echo off
REM ILA Capture Wrapper — ensures output is captured
set MODE=%1
if "%MODE%"=="" set MODE=pc_trace

echo [%DATE% %TIME%] Starting ILA capture: %MODE%
echo [%DATE% %TIME%] Starting ILA capture: %MODE% > C:\Users\16084\Desktop\ila_capture.log

D:\Xilinx\Vivado\2023.2\bin\vivado.bat -mode tcl -nolog -nojournal -notrace ^
  -source C:\Users\16084\Desktop\capture_ila.tcl ^
  -tclargs %MODE% >> C:\Users\16084\Desktop\ila_capture.log 2>&1

echo [%DATE% %TIME%] Vivado exit code: %ERRORLEVEL%
echo [%DATE% %TIME%] Vivado exit code: %ERRORLEVEL% >> C:\Users\16084\Desktop\ila_capture.log
