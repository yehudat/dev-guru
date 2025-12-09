### Motivation

The SystemVerilog LRM (1800-2023), in chapter __21. Input/output system tasks and system functions__, 

| **Function/Task** | **Purpose** | **Returns** | **Modifies Input Variable?** | **Direct Print?** | **Typical Use Case** |
|-------------------|-------------|-------------|------------------------------|-------------------|----------------------|
| `$display` | A system task for displaying information. It adds a newline characted to the end of its output | `void` | No | Yes | Print values for debug |
| `$write`   | Like `$display`, but doesn't add a newline characted to the end of its output | `void` | No | Yes | Print values for debug |
| `$fdisplay` | If `$display` writes to STDOUT, `fdisplay` writes to a file. | `void` | No | No | Print values to a log file |
| `$fwrite`   | See the description of `$display` above | `void` | No | No | Print values to a log file |
| `$swrite`   | Assigns a string to the first argument. | `void` | No | No | Assigns compiled string to an output variable |
| `sformat`  | Same, as above, but interprets its 2nd argument | `void` | Yes | No | Updating an existing string variable |
| `sformatf` | Formats a string and returns it. Interprets its 2nd variable | `string` | No | No | Inline use or assignment |

The reset of the printing commands, either belong to one of the families above, or propriatry to a specific simulator.