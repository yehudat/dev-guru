### Definition

The **State Design Pattern** is a **behavioral design pattern** that allows an object to change its behavior when its internal state changes. The pattern encapsulates state-based behaviors within separate classes, and the context object (the object whose behavior depends on its state) delegates state-related tasks to the current state object.

This pattern is useful when an object can be in multiple states, and its behavior changes based on those states. It allows for a cleaner way of managing state-specific logic by isolating it in separate state classes rather than using conditionals (e.g., `if` or `switch` statements).


### Example in Python

Let's consider an example where we have a `TrafficLight` system. The traffic light has three states: `Red`, `Green`, and `Yellow`. Depending on its current state, it will behave differently.

```python
from abc import ABC, abstractmethod

# State interface
class TrafficLightState(ABC):
   @abstractmethod
   def switch(self, traffic_light):
       pass

# Concrete state for Red
class RedState(TrafficLightState):
   def switch(self, traffic_light):
       print("Switching from Red to Green.")
       traffic_light.set_state(GreenState())

# Concrete state for Green
class GreenState(TrafficLightState):
   def switch(self, traffic_light):
       print("Switching from Green to Yellow.")
       traffic_light.set_state(YellowState())

# Concrete state for Yellow
class YellowState(TrafficLightState):
   def switch(self, traffic_light):
       print("Switching from Yellow to Red.")
       traffic_light.set_state(RedState())

# Context class
class TrafficLight:
   def __init__(self):
       self.state = RedState()  # Initial state is Red
   def set_state(self, state):
       self.state = state
   def switch(self):
       self.state.switch(self)

# Client code
if __name__ == "__main__":
   traffic_light = TrafficLight()
   # Simulate state transitions
   traffic_light.switch()  # Red -> Green
   traffic_light.switch()  # Green -> Yellow
   traffic_light.switch()  # Yellow -> Red
   traffic_light.switch()  # Red -> Green again
```

### Explanation

1. **TrafficLightState**: This is an abstract base class (interface) for the different states. It defines a `switch` method that every concrete state must implement.
2. **RedState**, **GreenState**, and **YellowState**: These are concrete implementations of the `TrafficLightState`. They define what happens when the traffic light is in their respective state and how to transition to the next state.
3. **TrafficLight**: This is the context class. It holds a reference to the current state and allows switching between states. It delegates the task of switching to the current state object.
In this example, the `TrafficLight` starts in the `RedState`. When you call the `switch()` method, it delegates to the current state (e.g., `RedState`), which knows how to transition to the next state (e.g., `GreenState`).