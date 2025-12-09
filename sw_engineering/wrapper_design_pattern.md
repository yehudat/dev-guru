
## **Wrapper (Decorator) Pattern**

In the **Wrapper Pattern**, also known as the **Decorator Pattern**, the goal is to "wrap" a class to extend or modify its functionality without altering its structure. This pattern can be useful when you want to enhance an object’s behavior dynamically (without changing the original class). In this case, you migh With the Wrapper, you can add layers, like cloths in an order you desire, at run-time.

You can create a wrapper class that holds the array and provides methods for initialization and rearrangement. The advantage is that you can still maintain separation of concerns and extend functionality (e.g., logging, caching) without modifying the core data structure.

### **Usecase**

If you just need a central class to manage and manipulate the array, while keeping the methods (initialize, rearrange) contained in the same class.

## **Wrapper (Decorator) Pattern** Example

### Scenario

You have a basic multidimensional array class that handles the data structure. You want to "wrap" it with additional functionalities, like logging or data validation, without modifying the original class.

### Structure

- **Component**: Defines the common interface that both the concrete class and decorators will implement.
- **ConcreteComponent**: The basic implementation (in your case, the array database).
- **Decorator**: The abstract class or interface for wrapping behavior around the component.
- **ConcreteDecorator**: Implements the additional behavior while wrapping the component.

### Code

```python
# The base class (Component) which the Decorators and ConcreteComponent will share
class ArrayDatabase:
    def __init__(self, dimensions):
        # Initialize a multidimensional array
        self.data = [[0 for _ in range(dimensions[1])] for _ in range(dimensions[0])]

    def initialize(self, values):
        # Initialize the array with provided values
        for i in range(len(values)):
            for j in range(len(values[i])):
                self.data[i][j] = values[i][j]

    def rearrange(self):
        # Rearranging is the default operation, let's reverse rows as an example
        for row in self.data:
            row.reverse()

# Decorator base class (This will be the wrapper)
class ArrayDatabaseDecorator:
    def __init__(self, array_database):
        self.array_database = array_database  # Holds a reference to the original object

    def initialize(self, values):
        # Pass-through for the original object's methods
        self.array_database.initialize(values)

    def rearrange(self):
        # Pass-through for rearranging the array
        self.array_database.rearrange()

# Concrete decorator class to add logging functionality

class LoggingArrayDatabaseDecorator(ArrayDatabaseDecorator):
    def initialize(self, values):
        print("Initializing array with values:", values)
        super().initialize(values)

    def rearrange(self):
        print("Rearranging array...")
        super().rearrange()
        print("Array rearranged to:", self.array_database.data)

# Concrete decorator class to add validation functionality

class ValidationArrayDatabaseDecorator(ArrayDatabaseDecorator):
    def initialize(self, values):
        # Validate before initializing
        if self._validate_values(values):
            print("Values validated.")
            super().initialize(values)
        else:
            print("Invalid values for initialization!")

    def _validate_values(self, values):
        # Example validation: Ensure it's a 2D array with integers only
        return all(isinstance(row, list) and all(isinstance(x, int) for x in row) for row in values)

# Client code

# First, create the base array database object
db = ArrayDatabase((3, 3))

# Now, wrap it with a logging decorator
logged_db = LoggingArrayDatabaseDecorator(db)

# You can also add multiple decorators, here we add validation
validated_logged_db = ValidationArrayDatabaseDecorator(logged_db)

# Initialize and rearrange the array using the wrapped object
validated_logged_db.initialize([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
validated_logged_db.rearrange()
```

### Explanation

1. **ArrayDatabase**: The base class that holds and manipulates the array. It provides basic `initialize` and `rearrange` functionality.
2. **ArrayDatabaseDecorator**: The abstract decorator class, which wraps the `ArrayDatabase` and forwards method calls to it.
3. **LoggingArrayDatabaseDecorator**: A concrete decorator that adds logging functionality to the `initialize` and `rearrange` methods.
4. **ValidationArrayDatabaseDecorator**: Another concrete decorator that adds validation before initializing the array.

### Benefits:

- **Extension of Behavior**: You can add new functionalities (like logging or validation) without modifying the core array manipulation logic.
- **Flexibility**: You can chain multiple decorators, as shown in the example (logging + validation).
- **Single Responsibility**: Each decorator focuses on a single task, keeping concerns separated (e.g., logging vs. validation).

### Key Takeaway

The **Wrapper (Decorator) Pattern** is about **extending** or **enhancing** behavior dynamically, while the **Strategy Pattern** is about **changing algorithms or behavior** based on different contexts or strategies. 

In this corrected example, the Wrapper Pattern adds extra behavior (like logging or validation) without changing the fundamental operations on the array, making it the right pattern for augmenting behavior.