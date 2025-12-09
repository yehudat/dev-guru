# Collecting code coverage for specific instance hierarchy

## User Guide

[A link to Questa® Verification Run Manager User Guide](file:///usr/share/doc/questa_20231_ug/mgchelp.htm#context=vrm_user&id=209&tag=id0fde3fae-3f89-4a5d-8dc8-a6c7da021a8b)

## Scripting `vlog/vcom` & `vopt` Do Files

```tcl
set cmd "vlog -permissive -sv -work tb_lib -L tb_lib +incdir+$env(ESL_GENERATED_TB)/i2c_multiuser_test_pkg/ +incdir+$env(ESL_GENERATED_TB)/misc/include +incdir+$env(ESL_GENERATED_TB)/tb"
append cmd " $env(ESL_GENERATED_TB)/i2c_multiuser_test_pkg/i2c_multiuser_test_pkg.sv"
eval $cmd

set cmd "vlog -permissive -sv -L tb_lib -L lphud_fpga_lib -L iic_ctrl_2_lib  -timescale 1ps/1ps +incdir+$env(ESL_GENERATED_TB)/ +incdir+$env(ESL_GENERATED_TB)/misc/include "
append cmd " $env(ESL_GENERATED_TB)/tb_top.sv"
eval $cmd

set cmd "vopt -novopt -incr tb_top -o tb_top_opt +cover=sbecft+/tb_top/lphud_i2c_top_i. +fcover +acc=arn+tb_top +acc=rn+tb_top/lphud_i2c_top_i. -L lphud_fpga_lib -L tb_lib -L bit_lib -L c17_lib -L ddr2_periphery_lib -L iic_core_lib -L iic_ctrl_2_lib -L shared_data_types_lib  +floatgenerics "
eval $cmd
```

## Scripting `vsim` Do File

```tcl
eval vsim tb_top \
  -L lphud_fpga_lib \
  -L tb_lib \
  -L bit_lib \
  -L c17_lib \
  -L ddr2_periphery_lib \
  -L iic_core_lib \
  -L iic_ctrl_2_lib \
  -L my_data_type \
  -L shared_data_types_lib \
  +UVM_TESTNAME=$test_name -l  ${test_name}_${curr_time}.log \
  -voptargs=+acc \
  \
  -voptargs="+cover=sbecft+/tb_top/lphud_i2c_top_i" \
  -coverage \
  \
  -solvefaildebug=1 \
  +UVM_VERBOSITY=UVM_MEDIUM \
  -uvmcontrol=all \
  -classdebug \
  -sv_seed 1 \
  -error 3473 \
  -lic_plus \
  -onfinish ask \
  +UVM_NO_RELNOTES
echo "SEED value : $Sv_Seed"
```