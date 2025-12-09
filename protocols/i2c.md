## I2C Master Operation and the ACK Signal

### Overview of I2C Master Operation (SCL and SDA Control)

An I2C master is responsible for orchestrating communication on the two-wire I2C
bus. The bus consists of a serial clock line (SCL) and a serial data line (SDA),
which are open-drain signals requiring pull-up resistors. This means devices
drive the lines low to send a logical 0, and drive them to high-impedance
(letting the pull-up raise the line) to send a logical 1 . The master always
drives the SCL clock pulses and generates special start/stop signals. In fact,
when a master initiates communication, it pulls SDA low while SCL is high (a
START condition), then it takes control of SCL, toggling it for each data bit,
and finally releases SDA while SCL is high to signal a STOP condition . All
other devices observe the bus and only drive SDA when they are explicitly
allowed (such as sending data as a slave or sending an ACK).

During data transfer, the master controls SCL and places or samples bits on SDA
in sync with the clock. One bit is transferred per SCL cycle. By I2C convention,
data is valid (must remain stable) whenever SCL is high; SDA should only change
when SCL is low . The master adheres to this rule by updating SDA (or releasing
it) during SCL-low periods and capturing or outputting data during SCL-high
periods. The master typically sends a 7-bit address (most significant bit first)
plus a read/write bit, then either transmits or receives data bytes as needed.
In all cases, the master drives the clock and controls when new bits start,
while the SDA line may be driven by either master or slave depending on
direction (master drives SDA for address and for data in a write, whereas the
slave drives SDA for data in a read). Importantly, both lines being open-drain
means multiple devices can pull them low without electrical conflict. If no
device is pulling a line low, it "floats" high (logic 1) due to the pull-up .

### Significance of the ACK Signal in I2C Transactions

I2C uses an acknowledge (ACK) mechanism as a handshake to confirm each byte of
data transfer. After the master sends an address or data byte (8 bits), it
releases the SDA line on the 9th clock pulse so that the receiver can answer.
The receiving device (whether master or slave) must then drive SDA low during
that 9th bit to ACK, indicating it successfully received the byte . In other
words, an ACK is signaled by the receiver pulling SDA to 0 on the 9th clock
pulse, and a NACK (not-acknowledge) is indicated by leaving SDA high (no device
drives it low) during that 9th pulse . This ACK bit is crucial: it allows the
transmitter to know whether to continue. :If an address byte is not acknowledged
(SDA remains high), it means no slave device responded to that address - the
master will typically abort the transaction in that case (either issue a Stop or
a repeated Start for another attempt) . If a data byte is not acknowledged by
the receiver, it could mean the receiver is unable to accept more data or didn't
understand the byte, so the master may also terminate the transfer.

From the master's perspective, the ACK is a way to detect the presence of the
slave and the success of data transfer. After sending an address, the master
reads the ACK bit: if no ACK (a NACK) is received, the master knows the
addressed device didn't respond and can decide to stop or try a different
address . During data bytes in a write, if the slave ever NACKs (e.g. maybe it
can't handle more data), the master should stop the transfer. From the slave's
perspective, ACK is how the slave signals "byte received OK." For example, when
a slave is addressed and recognizes its address, it pulls SDA low on the ACK bit
to say "Yes, that's me" . As it receives each data byte, it continues to ACK to
tell the master to keep going. If the slave needs to NACK (perhaps it's busy or
cannot accept more data), leaving SDA high tells the master to stop sending.

ACK works similarly when the master is receiving data (i.e. the slave is the one
transmitting the data byte). In that case, after the slave puts an 8-bit data
byte on SDA, it's the master's turn to ACK: the slave releases SDA on the 9th
bit, and the master pulls SDA low to acknowledge receipt . This tells the slave
that the master got the byte and is ready for the next. If the master is
finished reading and doesn't want more data, it will issue a NACK instead of an
ACK after the last byte, by simply not pulling SDA low (allowing it to stay
high) during the 9th clock. A master-receiver uses this NACK to politely
indicate "no more data" . For example, if a master only needed two bytes from a
slave, it will ACK the first byte (to request another) and then NACK the second
byte to signal the slave to stop transmitting. In summary, an ACK (SDA pulled
low) means "Got it, continue" and a NACK (SDA left high) means "Stop - either I
didn't get that, or I'm done." The I2C spec enumerates reasons a NACK might
occur, including a device being busy or not present, an unsupported command, a
receiver's buffer full, or simply the end of a read sequence by the master .

### I2C Transaction Waveforms (ASCII Examples)

Below are ASCII waveform diagrams illustrating a simple I2C transaction,
highlighting the Start condition, address phase (with ACK/NACK), data byte
transfer, and Stop condition. In these diagrams, time flows from left to right.
SCL is the clock line and SDA is the data line. A horizontal line indicates the
line is stable at a high (`-`) or low (`_`) logic level, and transitions are shown
with slanting edges (`\` or `/`). Note: SDA changes state only when SCL is low
(except for the special Start/Stop cases). ACK bits are indicated by SDA being
pulled low on the 9th clock pulse.

#### Start Condition

A START condition is signaled by the master as a high-to-low transition on SDA
while SCL is high. This is the event that initiates a transaction on an idle bus
. In the ASCII below, the master drives SDA from 1 to 0 while SCL is high (SCL
remains high and unchanged at that moment):

```
SCL: --------- (SCL remains high)
SDA: ----\____ (SDA goes from high to low while SCL is high -> START)
```

Above: I2C START condition (SDA falling while SCL is high). After this, the bus
is busy and the master will begin clocking SCL for data transfer.

#### Address Phase (7-bit Address + R/W + ACK)

Immediately after the Start, the master sends the 7-bit address and the
read/write (R/W) bit, totaling 8 bits. These bits are sent most-significant-bit
first, with one bit transmitted per SCL pulse. The master drives SDA for these
bits, setting SDA to the proper level during each SCL-low period, and the value
is latched by receivers when SCL is high. The diagram below shows an example
address byte (1010 0101 in binary, for illustration) being written, followed by
the ACK bit:

```
SCL: __|--|__|--|__|--|__|--|__|--|__|--|__|--|__|--|__|--| (Clock pulses for 8 bits + ACK)
SDA: _/-----\_____/-----\___________/-----\_____/-----\____ (Address bits + ACK)
```

In the above ASCII waveform for the address phase: " The SCL line (top) is
toggling at each bit: it goes low (`__`), then high (`--`) for each bit. There are 9
rising edges shown: 8 for the address/RW bits and the 9th for the ACK bit.
"The SDA line (bottom) shows the master driving the bits 1 0 1 0 0 1 0 1 (binary)
in our example. When SDA is high (represented by `-`) or low (represented by `_`)
during the SCL high period, that indicates a 1 or 0 bit respectively. For
instance, the first bit is 1 (SDA stayed high through the first clock), the
second bit 0 (SDA low on the second clock), etc.  " SDA only changes when SCL is
low: notice the slanted edges (`/` or `\`) on the SDA line occur during SCL-low
times. For example, after sending a 1 (high) for the first bit, the master pulls
SDA low (`-\____`) to send 0 as the next bit, and it does so while SCL is low.  "
After the 8 address+R/W bits, the master releases SDA for the 9th bit (the ACK
cycle). In the diagram above, the SDA line is pulled low during the 9th clock
pulse by the slave, indicating an ACK. This ACK means a slave device recognized
the address. If no device pulled SDA low here (i.e. SDA stayed high), that would
be a NACK, meaning the address wasn't recognized by any slave . In that case the
master would typically issue a Stop or a repeated Start to try another address.

Address ACK/NACK: The ACK bit is critical at the end of the address. An ACK (SDA
= 0) confirms that a slave is present at that address . A NACK (SDA = 1) tells
the master that no device responded. The master in the latter case will abort
the transaction - either by stopping or perhaps trying a different address. In
our example above, we showed an ACK (SDA pulled low). If it were a NACK, the SDA
line would have remained high during that 9th clock.

#### Data Byte Transfer (with ACK/NACK)

After the address is acknowledged, data bytes are transferred between master and
slave. Each data byte is also 8 bits, followed by an ACK bit. The process is
essentially identical to the address phase in terms of waveform: the transmitter
(master when writing, or slave when reading) puts 8 data bits on SDA (one per
SCL cycle), and the receiver responds with ACK or NACK on the ninth bit . The
ACK/NACK on data bytes works the same way as described above: the receiver pulls
SDA low to ACK, or leaves it high to NACK .

One key difference in data transfer is the direction of data flow can vary. If
the master is writing data to the slave, the master continues to drive SDA for
the 8 data bits, and the slave will drive the ACK bit. If the master is reading
data from the slave, then the roles switch for those 8 bits: the slave drives
SDA (sending the data bits), and the master will drive the ACK bit (after each
byte). In both cases, the pattern of 8 bits followed by an ACK is the same on
the bus.

For example, suppose the master is reading two bytes from a slave. It will have
sent a read-address, and the slave will start driving SDA to send data. The
master will clock SCL for 8 bits, then must ACK the first byte to signal it
wants another. For the second (last) byte, the master will respond with a NACK
instead of ACK to indicate "that's all, stop now." The slave will detect that
NACK and conclude the master is done reading. The master would then issue a Stop
condition to end the transfer.

The following ASCII snippet illustrates the ACK vs NACK on an arbitrary data
byte. It shows the 9th clock pulse (ACK cycle) for two scenarios: one where the
receiver ACKs (pulls SDA low) and one where it NACKs (leaves SDA high):

```
SCL        : __|--|__ (one clock pulse for ACK/NACK)
SDA (ACK)  : -\____/- (ACK: SDA driven low during SCL high)
SDA (NACK) : -------- (NACK: SDA remains high)
```

Above: ACK vs NACK on the 9th bit. In the ACK case, the SDA line, which was high
(released) before, is pulled low (`\____`) by the receiver during the SCL high
time. In the NACK case, the SDA line stays high (`--------`) - no device pulled it
low.

In practice, a master-transmitter will interpret a NACK from the slave as "stop
sending data". A master-receiver will deliberately issue a NACK to indicate it
has finished reading the required data . All other data bytes in a multi-byte
transfer should be ACKed to keep the transmission going .

#### Stop Condition

When the master wants to terminate the transaction, it issues a STOP condition.
A STOP is defined as a low-to-high transition on SDA while SCL is high -
essentially the inverse of the Start. The master first ensures SCL is high (it
may need to clock it to high from a low state) and then releases SDA from low to
high. This releases the bus and signals to all devices that the transaction is
complete. The bus then goes into an idle state (both lines high due to pull-ups)
and is free for another master or transaction. The ASCII below shows a Stop
condition:

```
SCL: --------- (SCL high)
SDA: ____/---- (SDA goes from low to high while SCL is high -> STOP)
```

Above: I2C STOP condition (SDA rising while SCL is high). The master releases
SDA to high to end the transaction. A brief bus-free time is then required
before the next Start can occur.

After a Stop, the bus is idle (both SCL and SDA high). If another transaction is
needed, the master will wait the minimum bus free time (e.g. ~4.7 us in standard
mode ) and can then issue a new Start.

### Implementing an I2C Master in VHDL (FPGA Considerations)

Designing a robust I2C Master in VHDL for an FPGA involves careful planning of
the control logic (typically a finite state machine), meeting timing
requirements, and handling the open-drain nature of the lines. Here are key
considerations:

#### State Machine Design

Implement the master as a finite state machine (FSM) that sequences through the
I2C protocol steps. Typical states might include: Idle, Start, sending Address
bits, waiting for ACK, sending or receiving Data bits, ACK handling, Stop, etc.
For example, one proven design enters a Start state to issue the start
condition, then a state to output the address and R/W bit, then a state to
sample the slave's ACK (let's call it slv_ack1), then states to either transmit
data (wr states) or receive data (rd states) depending on R/W, followed by
another ACK state (slv_ack2 for write or mstr_ack for read), and eventually a
Stop state . This structured approach ensures the master handles each part of
the transaction in order. In hardware, each byte can be broken down further into
bit sub-states (shifting out bits and toggling SCL) and an ACK sub-state. Using
counters or sub-states to count the 8 bits and then the 9th bit (ACK) is common.
The FSM should also handle repeated starts if a read follows a write to the same
slave (switching direction without releasing the bus), as well as detect when to
issue a Stop (for example, after the last byte of a transfer). Planning these
states and transitions upfront, perhaps drawing a state diagram, is very
helpful.

Importantly, the FSM should incorporate checks for the ACK bits from the slave.
For instance, after sending the address, the FSM transitions to an "ACK check"
state where it samples SDA on the 9th clock to see if the slave pulled it low .
If not, it might transition to an error or stop state. Similarly, after sending
each data byte in a write, the FSM should verify the ACK (and abort if NACKed).
If reading data, the FSM must output the master's ACK or NACK at the proper time
(for reads, typically you'll have a state where you drive SDA low for ACK after
a byte, or keep it high for NACK on the last byte). Handling these ACK responses
in the state machine is crucial for proper handshaking.

#### Timing and Clock Generation

I2C has specific timing requirements (especially for standard mode 100 kHz or
fast mode 400 kHz). The FPGA design must ensure SCL is toggled at the correct
frequency and duty cycle, and that SDA meets setup/hold times relative to SCL .
Typically, you'll use a clock divider or enable signal to derive the SCL timing
from a faster FPGA clock. For example, with a 50 MHz FPGA clock, dividing down
to get a 100 kHz SCL means counting ~500 cycles per half-period (or using a
simpler formula with a prescaler). In VHDL, one might have a counter that
enables the state machine to advance only at specific tick intervals to achieve
the desired SCL high and low durations.

Ensure that SCL high and low each meet the minimum times (e.g. 4.0 us high, 4.7
us low for 100 kHz standard mode ). The state machine should insert delays (in
terms of FPGA clock cycles) to hold SCL high or low long enough. Also ensure the
bus free time between a Stop and next Start (T_buf) is met (e.g. 4.7 us) ,
usually by staying in Idle for that duration before a new Start.

Another timing consideration is the I2C setup and hold times for SDA relative to
SCL. The master must change SDA only while SCL is low, and maintain SDA stable
for a short hold time after SCL rises . In practice, if your FSM only changes
SDA on clock enable events when SCL is low, and you respect the high period, you
will meet these requirements. It's wise to simulate the waveform to check that
SDA transitions occur at the proper SCL phases.

Be aware of clock stretching: some I2C slave devices may hold SCL low after a
byte to slow down the master (for example, a sensor might need more time to
prepare data). As a master, your design should accommodate this by synchronizing
to the actual SCL line. In an FPGA, if you're directly driving SCL, you can also
monitor the SCL input - if the slave holds it low (SCL_in stays low even when
you tried to release it high), your FSM should wait until it releases. In
essence, after you flip SCL output to high, check SCL_in; if it's not high yet,
delay until it goes high (the slave is done stretching). This can be as simple
as waiting in the SCL-high state until SCL_in reads as '1'. Ignoring clock
stretching could cause your master to violate timing if a slave stretches. In a
basic master for known non-stretching slaves you might not need this, but it's a
good design practice to include. (The I2C spec allows slaves to stretch SCL. For
example, "Slave can hold SCL low to force wait time between bytes." ).

### Common Pitfalls and Tips

Open-Drain Outputs: Remember that SCL and SDA are open-drain. In VHDL on an
FPGA, these are typically implemented as tri-statable signals (Std_logic with an
output enable). A common mistake is to drive a '1' onto SDA or SCL directly -
don't do this. Instead, drive a '0' to pull the line low, or configure the pin
as high-impedance (Z) to let it go high via the pull-up . Many I2C master
designs use two signals for each line: one for the output value and one for
output enable. For example, sda_o <= '0' to pull low, or leave sda_o don't-care
but set sda_oen <= '1' (output enable low-active) to let it float high. Ensure
that when you're not actively driving SDA (during slave ACK or when the slave is
sending data), your SDA pin is indeed released (output disable) so the slave can
control it. Failing to do so can result in bus contention (both master and slave
driving SDA) or an ACK bit that is always read as 0 because the master never
released the line. In simulation, improper open-drain handling shows up as 'X'
unknown values on SDA/SCL - using 'Z' for release (with pull-ups modeled or
using resolved signals) resolves this .

ACK Handling: Be careful to sample and generate ACKs at the correct times. The
master should sample the SDA line after the 8th data bit during the ACK clock
pulse to detect a slave's ACK. In VHDL, this might mean latching SDA at a
specific state of your bit counter (e.g., when bit count = 8 and SCL is high).
When the master needs to ACK (as a receiver), design the FSM such that it drives
SDA low only during the ACK bit window. For instance, you might preload a flag
like master_ack <= '1' for all but the final byte, which causes the SDA line to
be pulled low during the 9th bit of those bytes. One pitfall is holding SDA low
too long - make sure to release it immediately after the ACK clock if you intend
to release the bus or switch direction.

Timing Pitfalls: If using a fast FPGA clock, you might need multi-cycle path
constraints or careful synchronization for signals like SCL and SDA, since they
change at a much slower rate relative to the FPGA clock. Ensure that your
outputs meet I/O timing - usually not an issue at 100 kHz, but at 400 kHz
Fast-mode you have shorter high/low times (~1.3 us) which still are easy for
FPGA, but if your FPGA clock is much faster, you need to ensure your logic
toggles the I/O at the right times without jitter. Another subtle issue is
synchronizing SDA input sampling with your state machine's clock. Since SDA
(from a slave) can change relative to SCL which your master controls, sampling
it when SCL is high is deterministic. But if your design uses a different clock
domain or if you allow clock stretching, synchronize the SCL/SDA inputs to your
internal clock to avoid metastability (the Digikey reference design for I2C
master, for example, synchronizes the SCL and SDA inputs before detecting
start/stop conditions and changes).

Bus Clear and Reset Conditions: Ensure the FSM can recover from unexpected
conditions. For example, if a transaction is interrupted or a slave holds the
bus, your master might need to timeout or reset the bus. A common practice is to
send 9 clock pulses (to flush any stuck slave state) and a stop if the bus is
stuck. While this is advanced, keep in mind in a robust design.

Testing and Simulation: Simulate the I2C master FSM with various scenarios - ACK
vs NACK, different data bytes, etc. You'll need to model pull-ups and a dummy
slave (or testbench that drives SDA for ACK/data) to verify that your master
releases and drives lines correctly. Watch for SDA turning to 'X' in simulation
- that's a sign of two drivers or not handling Z correctly. Also, test the clock
stretching if applicable by modelling a slave that holds SCL low and see that
your master waits.

Common Mistakes Summary: driving lines incorrectly (not using open-drain), not
checking ACK and continuing blindly, violating the start/stop or data valid
timing (e.g., changing SDA at the wrong time), and not handling bus states
(idle/busy) correctly. By focusing on the state-machine sequence and adhering to
the I2C spec timing , you can avoid these pitfalls. Use the I2C spec as a guide
- for instance, the spec timings above give you a sense of how long to hold
signals - and always ensure SDA is only driven low when it's supposed to be.
With careful design and testing, implementing a simple I2C master in VHDL is
very achievable and a great exercise in digital design with hardware protocols.

Sources: The behavior and timing described are based on the official I2C-bus
specification and common design practices , as well as practical insights from
FPGA implementation references . These ensure that the VHDL implementation will
interoperate correctly on the I2C bus.