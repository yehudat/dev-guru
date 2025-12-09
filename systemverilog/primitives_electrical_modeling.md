# Context: Why drive strength and pull-ups matter in I²C

The I²C bus uses open-drain (or open-collector) signaling:

- Devices only pull the lines low
- A pull-up resistor restores the line to high when no one is pulling it down
- This ensures that multiple masters can safely share the same SDA/SCL lines

# SystemVerilog Constructs for This

| Construct  | Purpose in SV How it relates to I²C |
|------------|------------------------------------------------------------------------|
| pullup | Pulls a wire up (like a resistor) Models passive pull-up on SDA/SCL
| pulldown | Pulls a wire down (less common here) Not typically used in I²C
| tran | Bidirectional switch without strength Models open-drain interconnect
| rtran | Resistive bidirectional switch Can be used for analog-like modeling
| strong0, weak1, etc | Allow multiple drivers with resolution Simulates bus contention or passive state

# How to use this in your I²C UVC interface

Let’s say you’re modeling SDA or SCL. Multiple agents (master, slave, monitor) may try to pull the line low, but no one drives it high directly — that’s the pull-up’s job.
SystemVerilog modeling example:

```verilog
wire sda_wire;
pullup(sda_wire); // Always trying to pull the line up (like a resistor)
```

Then each agent connects like this:

```verilog
logic sda_drv; // 0 = pull low, Z = high-Z
assign sda_wire = sda_drv; // Only pulls low or releases
// Somewhere in the driver:
sda_drv = 0; // Pull down to signal
sda_drv = 'z; // Release — let pullup take over
```

If you want contention modeling or multi-driver bus, use tran elements:

```verilog
logic master_sda_drv, slave_sda_drv;
wire sda_bus;
pullup(sda_bus);
tran (sda_bus, master_sda_drv);
tran (sda_bus, slave_sda_drv);
```

Each side sets its *_drv to 'z or 0. 

- [x] If both try to drive 0 at once — fine.
- [x] If one drives 0 and one 'z — fine.
- [x] If both try to drive conflicting values (e.g., one 0, one 1 by mistake) — you get x, a resolved state.

# Practical Notes for Your UVC

- Define SDA/SCL as wire, not logic
- Drive only 0 or 'z from each agent
- Add pullup() once in your top or interface
- Use tran or assign connections in your UVC interface to model proper bus behavior
- To monitor the bus state, observe the resolved wire (sda_wire), not the internal drivers