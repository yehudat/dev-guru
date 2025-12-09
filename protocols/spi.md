# SPI Waveforms (CPOL=0, CPHA=0)

```
| Time       | t0  | t1  | t2  | t3  | t4  | t5  | t6  | t7  | t8  | t9  | t10 | t11 | t12 | t13 | t14 | t15 |
|------------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|

| SCK        | ____|¯¯¯¯ |____ |¯¯¯¯ |____ |¯¯¯¯ |____ |¯¯¯¯ |____ |¯¯¯¯ |____ |¯¯¯¯ |____ |¯¯¯¯ |____ |¯¯¯¯ |

| MOSI       | 1   | 0   | 1   | 1   | 0   | 0   | 1   | 0   | 1   | 1   | 1   | 0   | 0   | 1   | 0   | 1   |

| MISO       |     | 1   |     | 0   |     | 1   |     | 0   |     | 1   |     | 0   |     | 1   |     | 0   |

| CSN        |_____|¯¯¯¯ |_____|¯¯¯¯ |_____|¯¯¯¯ |_____|¯¯¯¯ |_____|¯¯¯¯ |_____|¯¯¯¯ |_____|¯¯¯¯ |_____|¯¯¯¯ |
```

# Explanation

1. **Clock Polarity and Phase (CPOL = 0, CPHA = 0)**:
   - **SCK** (Serial Clock): The clock line, which toggles for each bit.
   - **MOSI** (Master Out Slave In): The line used by the master to send data to the slave.
   - **MISO** (Master In Slave Out): The line used by the slave to send data to the master.
   - **CSN** (Chip Select): __Active Low Signal__ used to select the slave device.
2. **Byte Transmission**:
   - During the SPI transfer, one byte is transmitted from the master to the slave over MOSI, and one byte is received from the slave over MISO.
3. **Sampling MISO**:
   - The master samples MISO on the rising edge of SCK. Each bit is read sequentially.

# Numerical Example

- **Assume the master wants to read a byte `10101010 == 0xAA` from the slave**.
- The master generates the clock and selects the slave by pulling CSN.
- At each rising edge of SCK, the master samples the bit on MISO.

# Byte Example (10101010)

- **t1**: Sampled bit = `1`
- **t3**: Sampled bit = `0`
- **t5**: Sampled bit = `1`
- **t7**: Sampled bit = `0`
- **t9**: Sampled bit = `1`
- **t11**: Sampled bit = `0`
- **t13**: Sampled bit = `1`
- **t15**: Sampled bit = `0`

The sampled byte on MISO is `10101010`. This byte is read into the master's register, completing the data reception.