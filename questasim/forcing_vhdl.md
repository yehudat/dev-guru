# Motivation

Using Verilog "force" on VHDL code doesn't always work. It's even less likely to work on an internal VHDL design hierarchy.
Questa recommends using $signal_force task provided by Questa instead.

- `force $root.tb_top.DUT.<MY_VHDL_SIGNAL> = 1'b1;`
- `release $root.tb_top.DUT.<MY_VHDL_SIGNAL>;`
- `$signal_force(<dest_object>, <value>, <rel_time>, <force_type>, <cancel_period>, <verbose>);`
- `$signal_release(<dest_object>, <verbose>);`

# Arguments

- `<dest_object>`: Required string. A full hierarchical path (or relative downward path with reference to the calling block) to an existing VHDL signal, SystemVerilog or Verilog register/bit of a register/net. Use the path separator to which your simulation is set (for example, “/” or “.”). A full hierarchical path must begin with a “/” or “.”. The path must be contained within double quotes.
- `<value>`: Required string. Specifies the value to which the dest_object is to be forced. The specified value must be appropriate for the type.
- `<rel_time>`: The default is 0. Optional time. Specifies a time relative to the current simulation time for the force to occur.
- `<force_type>`: It is recommended to choose 3.
	- 0 - default - which is “freeze” for unresolved objects or “drive” for resolved objects
	- 1 - deposit
	- 2 - drive
	- 3 - freeze
- `<cancel_period>`: Default is -1 ms. Optional time or integer. Cancels the signal_force command after the specified period of time units. Cancellation occurs at the last simulation delta cycle of a time unit. A value of zero cancels the force at the end of the current time period.  A negative value means that the force will not be cancelled.
- `<verbose>`: It is recommended to choose 1. Optional integer. Possible values are 0 or 1. Specifies whether you want a message reported in the Transcript stating that the value is being forced on the dest_object at the specified time.
	- 0:  Does not report a message. Default.
	- 1: Reports a message. 

# Examples

Force freeze MY_VHDL_SIGNAL to ONE and display a report message when force is performed:

```
$signal_force("/tb_top/DUT/MY_VHDL_SIGNAL", "1", 0, 3,        -1, 1);
```

Force freeze  MY_VHDL_SIGNAL to ONE during a period defined by 100000000*time unit and display a report message when force is performed:

```
$signal_force("/tb_top/DUT/MY_VHDL_SIGNAL", "1", 0, 3, 100000000, 1);
```

To release:

```
$signal_release("/tb_top/DUT/MY_VHDL_SIGNAL", 1);
```

# Notes

There is a drawback to use those proprietary commands since our code will not be compatible with another simulator.
