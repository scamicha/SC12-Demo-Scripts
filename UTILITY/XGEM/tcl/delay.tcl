catch {cd tcl/}
source ~swany/XGEM/tcl/anue_tcl_library.tcl

set delay [lindex $argv 0]

est_com 192.168.31.100:2003:1
puts "Setting delay on Blade #1 to $delay"
gem_set_delay 0 $delay 
close_com

est_com 192.168.31.100:2003:3
puts "Setting delay on Blade #3 to $delay"
gem_set_delay 0 $delay
close_com
