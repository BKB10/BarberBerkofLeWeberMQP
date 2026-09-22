#set VERILOG_FILES chi.v
#set TOP_MODULE chi
#
#set fp [open "synthesize.ys" r]
#while {[gets $fp line] >= 0} {
#    set line [string trim $line]
#    if {$line eq "" || [string index $line 0] eq "#"} continue
#    set line [subst $line]
#    yosys $line
#}
#close $fp


set VERILOG_FILES chi.v
set TOP_MODULE chi

set fp [open "synthesize.ys" r]
set body [read $fp]
close $fp

# Strip comment-only lines so subst doesn't trip over them
set cleaned [join [lmap l [split $body "\n"] {
    set t [string trim $l]
    expr {[string index $t 0] eq "#" ? "" : $l}
}] "\n"]

set script [subst $cleaned]
exec yosys -p $script