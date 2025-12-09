## `wait` statement from delta-tick perspective

In SystemVerilog, when you use `wait (a == 1)`, the behavior of this statement in the context of delta cycles (also known as delta ticks) is critical to understand, particularly for simulation timing and event scheduling.

### Understanding Delta Cycles:

- **Delta Cycle**: In digital simulation, a delta cycle is a zero-time step in which events are processed. Delta cycles allow for multiple events to occur within the same simulation time without advancing the actual simulation clock.
- **Order of Execution**: Events in the same simulation time but different delta cycles follow a specific order: active events (such as continuous assignments or blocking assignments), inactive events, non-blocking assignments, and finally monitor events.

### Behavior of `wait (a == 1)`:

- **Immediate Check**: When the `wait (a == 1)` statement is encountered, it immediately checks the condition of `a`.
- **Evaluation and Suspension**: If `a` is not equal to 1 at that moment, the process is suspended, and it will be re-evaluated whenever there is a change in the value of `a`.
- **Within a Delta Cycle**: If `a` changes due to another assignment within the same delta cycle (for example, a non-blocking assignment later in the same time step), the `wait` statement will recognize this change and can proceed without advancing the simulation time.

### Example:

```verilog
initial begin
 a = 0;
 #0;
 a <= 1;   // Non-blocking assignment, scheduled for the end of the current delta cycle.
 wait (a == 1);
 $display("a is 1 at time %0t", $time);  // This will execute within the same time step.
end
```

In the example above:

- At the `#0;` statement, the simulation moves to the next delta cycle, but the time doesn’t advance.
- The non-blocking assignment `a <= 1` schedules the update of `a` to 1 at the end of the current delta cycle.
- `wait (a == 1)` checks if `a` is 1. Since `a` is still 0 in the current delta cycle, the process suspends.
- As soon as the non-blocking assignment `a <= 1` is processed in the same delta cycle, the `wait` condition is rechecked, and since `a` is now 1, the `wait` statement proceeds without advancing the simulation time.

### Conclusion:
`wait (a == 1)` inside a delta cycle suspends the process until the condition `a == 1` becomes true. If `a` changes within the same delta cycle, the wait is satisfied, and the process can continue without advancing time. This behavior is crucial for simulating circuits with precise timing and event ordering.

## How to defer `wait` evaluation to be aligned to a clock?

### Approach 1: Using `#0; wait (a == 1);`

This method:

- **#0 Delay**: This delays the execution to the next delta cycle, ensuring that any updates to `a` in the current cycle are considered.
- **wait (a == 1)**: Waits for `a` to be `1`. The `wait` statement is re-evaluated whenever `a` changes.

### Approach 2: Using `@posedge a;` Followed by a Wait

Instead of waiting for the next delta cycle and checking if `a == 1`, you can directly wait for the next positive edge of `a` and then proceed with a one-clock cycle wait.

```verilog
initial begin
    @posedge a; // Wait for the positive edge of 'a'
    #1; // Optionally, you could add a one-time unit delay to wait for one clock cycle.
    $display("a is 1 at time %0t", $time);
end
```

### Explanation:

- **@posedge a**: This event control waits for the next rising edge of `a`. As soon as `a` transitions from `0` to `1`, the process resumes.
- **#1 Delay**: After catching the positive edge, you could wait for one time unit (which could represent one clock cycle depending on your time scale). This gives you a controlled way to wait for one clock cycle after detecting the rising edge.

### Comparison:

1. **@posedge a**: Triggers on the next positive edge of `a`, meaning `a` must change from `0` to `1`. This might not be what you want if `a` is already `1` when you enter the block.
2. **#0; wait (a == 1);**: Checks for `a` being `1` after the current delta cycle, regardless of whether `a` is already `1` or not. This is more flexible if `a` might already be `1` and you want to react immediately after any updates are settled.

### Conclusion:

- **@posedge a** followed by a wait for one clock cycle is useful when you want to respond specifically to an edge transition of `a` from `0` to `1`.
- **#0; wait (a == 1);** is more appropriate if you want to ensure `a` is `1`, regardless of when or how `a` becomes `1`, particularly if you're not specifically interested in an edge transition but rather the state.