## Code smells for Refactoring

### 1. **Duplicated Code**

#### Smelly Code:

```python
def calculate_area_rectangle(width, height):
    return width * height

def calculate_area_square(side):
    return side * side

area1 = calculate_area_rectangle(5, 10)
area2 = calculate_area_square(4)
```

#### Refactored Code:

```python
def calculate_area(shape, *dimensions):
    if shape == 'rectangle':
        return dimensions[0] * dimensions[1]
    elif shape == 'square':
        return dimensions[0] * dimensions[0]

area1 = calculate_area('rectangle', 5, 10)
area2 = calculate_area('square', 4)
```

### 2. **Long Method**

#### Smelly Code:

```python
def process_order(order):
    discount = 0
    if order.customer.has_loyalty_card:
        discount = 10
    total = 0

    for item in order.items:
        total += item.price

    total -= discount
    print(f"Order processed for {order.customer.name} with total: ${total}")
```

#### Refactored Code:

```python
def apply_discount(order):
    return 10 if order.customer.has_loyalty_card else 0

def calculate_total(order):
    return sum(item.price for item in order.items)

def process_order(order):
    discount = apply_discount(order)
    total = calculate_total(order) - discount
    print(f"Order processed for {order.customer.name} with total: ${total}")
```

### 3. **Large Class**

#### Smelly Code:

```python
class Order:
    def __init__(self, customer, items):
        self.customer = customer
        self.items = items

    def calculate_total(self):
        return sum(item.price for item in self.items)

    def apply_discount(self):
        if self.customer.has_loyalty_card:
            return 10
        return 0

    def generate_invoice(self):
        total = self.calculate_total() - self.apply_discount()
        print(f"Invoice for {self.customer.name}: ${total}")
```

#### Refactored Code:

```python
class Order:
    def __init__(self, customer, items):
        self.customer = customer
        self.items = items

    def calculate_total(self):
        return sum(item.price for item in self.items)

class Invoice:
    def __init__(self, order):
        self.order = order

    def apply_discount(self):
        return 10 if self.order.customer.has_loyalty_card else 0

    def generate(self):
        total = self.order.calculate_total() - self.apply_discount()
        print(f"Invoice for {self.order.customer.name}: ${total}")
```

### 4. **Long Parameter List**

#### Smelly Code:

```python
def create_order(customer_name, customer_address, item_name, item_quantity, item_price):
    total = item_quantity * item_price
    print(f"Order created for {customer_name}, {customer_address}: {item_quantity}x {item_name} - Total: ${total}")
```

#### Refactored Code:

```python
class Customer:
    def __init__(self, name, address):
        self.name = name
        self.address = address

class Item:
    def __init__(self, name, quantity, price):
        self.name = name
        self.quantity = quantity
        self.price = price

def create_order(customer, item):
    total = item.quantity * item.price
    print(f"Order created for {customer.name}, {customer.address}: {item.quantity}x {item.name} - Total: ${total}")
```

### 5. **Divergent Change**

#### Smelly Code:

```python
class Report:
    def __init__(self, data):
        self.data = data

    def generate_html(self):
        # Generate HTML report
        pass

    def generate_pdf(self):
        # Generate PDF report
        pass

    def save_to_file(self, file_format):
        if file_format == "html":
            self.generate_html()
        elif file_format == "pdf":
            self.generate_pdf()
```

#### Refactored Code:

```python
class Report:
    def __init__(self, data):
        self.data = data

class HTMLReport(Report):
    def generate(self):
        # Generate HTML report
        pass

class PDFReport(Report):
    def generate(self):
        # Generate PDF report
        pass

def save_report(report):
    report.generate()
```

### 6. **Shotgun Surgery**

#### Smelly Code:

```python
class Customer:
    def __init__(self, name, address, phone):
        self.name = name
        self.address = address
        self.phone = phone

    def update_address(self, new_address):
        self.address = new_address
        # Also, update other related systems
        # Update billing system
        # Update shipping system
```

#### Refactored Code:

```python
class Address:
    def __init__(self, street, city, postal_code):
        self.street = street
        self.city = city
        self.postal_code = postal_code

class Customer:
    def __init__(self, name, address, phone):
        self.name = name
        self.address = address
        self.phone = phone

    def update_address(self, new_address):
        self.address = new_address
        self._notify_related_systems()

    def _notify_related_systems(self):
        # Notify billing, shipping, etc.
        pass
```

### 7. **Feature Envy**

#### Smelly Code:

```python

class Order:
    def __init__(self, customer, items):
        self.customer = customer
        self.items = items

    def get_customer_address(self):
        return f"{self.customer.street}, {self.customer.city}, {self.customer.zipcode}"
```

#### Refactored Code:

```python
class Customer:
    def __init__(self, name, street, city, zipcode):
        self.name = name
        self.street = street
        self.city = city
        self.zipcode = zipcode

    def get_address(self):
        return f"{self.street}, {self.city}, {self.zipcode}"

class Order:
    def __init__(self, customer, items):
        self.customer = customer
        self.items = items

    def get_customer_address(self):
        return self.customer.get_address()
```

### 8. **Inappropriate Intimacy**

#### Smelly Code:

```python
class Customer:
    def __init__(self, name, address):
        self.name = name
        self.address = address

class Order:
    def __init__(self, customer):
        self.customer = customer

    def update_customer_address(self, new_address):
        self.customer.address = new_address
```

#### Refactored Code:

```python
class Customer:
    def __init__(self, name, address):
        self.name = name
        self.address = address

    def update_address(self, new_address):
        self.address = new_address

class Order:
    def __init__(self, customer):
        self.customer = customer

    def update_customer_address(self, new_address):
        self.customer.update_address(new_address)
```

### 9. **Lazy Class**

#### Smelly Code:

```python
class Address:
    def __init__(self, street, city, postal_code):
        self.street = street
        self.city = city
        self.postal_code = postal_code
```

#### Refactored Code:

```python
class Customer:
    def __init__(self, name, street, city, postal_code):
        self.name = name
        self.street = street
        self.city = city
        self.postal_code = postal_code
```

### 10. **Data Clumps**

#### Smelly Code:

```python
def display_address(street, city, postal_code):
    print(f"{street}, {city}, {postal_code}")

display_address("123 Main St", "Anytown", "12345")
```

#### Refactored Code:

```python
class Address:
    def __init__(self, street, city, postal_code):
        self.street = street
        self.city = city
        self.postal_code = postal_code

def display_address(address):
    print(f"{address.street}, {address.city}, {address.postal_code}")

address = Address("123 Main St", "Anytown", "12345")
display_address(address)
```

### 11. **Primitive Obsession**

#### Smelly Code:

```python
class Order:
    def __init__(self, customer_name, customer_email, customer_phone):
        self.customer_name = customer_name
        self.customer_email = customer_email
        self.customer_phone = customer_phone
```

#### Refactored Code:

```python

class Customer:

    def __init__(self, name, email, phone):
        self.name = name
        self.email = email
        self.phone = phone

class Order:

    def __init__(self, customer):
        self.customer = customer
```

### 12. **Switch Statements**

#### Smelly Code:

```python
def get_shipping_cost(country):
    if country == "US":
        return 10
    elif country == "Canada":
        return 20
    elif country == "Mexico":
        return 15
    else:
        return 25
```

#### Refactored Code:

```python
class ShippingCostStrategy:
    def get_cost(self):
        raise NotImplementedError

class USAShipping(ShippingCostStrategy):
    def get_cost(self):
        return 10

class CanadaShipping(ShippingCostStrategy):
    def get_cost(self):
        return 20

class MexicoShipping(ShippingCostStrategy):
    def get_cost(self):
        return 15

def get_shipping_cost(strategy):
    return strategy.get_cost()

cost = get_shipping_cost(USAShipping())
```

### 13. **Temporary Field**

#### Smelly Code:

```python
class Order:
    def __init__(self, items):
        self.items = items
        self.discount = 0

    def apply_discount(self):
        if len(self.items) > 10:
            self.discount = 5
```

#### Refactored Code:

```python
class DiscountCalculator:
    def __init__(self, items):
        self.items = items

    def apply_discount(self):
        return 5 if len(self.items) > 10 else 0

class Order:
    def __init__(self, items):
        self.items = items

    def calculate_total(self):
        discount_calculator = DiscountCalculator(self.items)
        discount = discount_calculator.apply_discount()
        # Apply the discount to total calculation
```

### 14. **Message Chains**

#### Smelly Code:

```python
class Address:
    def __init__(self, street, city):
        self.street = street
        self.city = city

class Customer:
    def __init__(self, name, address):
        self.name = name
        self.address = address

class Order:
    def __init__(self, customer):
        self.customer = customer

    def get_customer_city(self):
        return self.customer.address.city
```

#### Refactored Code:

```python
class Address:
    def __init__(self, street, city):
        self.street = street
        self.city = city

    def get_city(self):
        return self.city

class Customer:
    def __init__(self, name, address):
        self.name = name
        self.address = address

    def get_city(self):
        return self.address.get_city()

class Order:
    def __init__(self, customer):
        self.customer = customer

    def get_customer_city(self):
        return self.customer.get_city()
```

### 15. **Middle Man**

#### Smelly Code:

```python
class Address:
    def __init__(self, city):
        self.city = city

class Customer:
    def __init__(self, address):
        self.address = address

    def get_city(self):
        return self.address.city

class Order:
    def __init__(self, customer):
        self.customer = customer

    def get_customer_city(self):
        return self.customer.get_city()
```

#### Refactored Code:

```python

class Address:
    def __init__(self, city):
        self.city = city

    def get_city(self):
        return self.city

class Customer:
    def __init__(self, address):
        self.address = address

class Order:
    def __init__(self, customer):
        self.customer = customer

    def get_customer_city(self):
        return self.customer.address.get_city()
```

### 16. **Incomplete Library Class**

#### Smelly Code:

```python
import datetime

class MyDate:
    def __init__(self, year, month, day):
        self.date = datetime.date(year, month, day)

    def add_days(self, days):
        return self.date + datetime.timedelta(days=days)
```

#### Refactored Code:

```python
from datetime import date, timedelta

class ExtendedDate(date):
    def add_days(self, days):
        return self + timedelta(days=days)

my_date = ExtendedDate(2024, 8, 29)
print(my_date.add_days(10))
```

### 17. **Data Class**

#### Smelly Code:

```python
class Customer:
    def __init__(self, name, email):
        self.name = name
        self.email = email
```

#### Refactored Code:

```python
class Customer:
    def __init__(self, name, email):
        self.name = name
        self.email = email

    def send_email(self, message):
        # Logic to send an email
        print(f"Sending email to {self.email}: {message}")

customer = Customer("John Doe", "john@example.com")
customer.send_email("Welcome!")
```

### 18. **Refused Bequest**

#### Smelly Code:

```python
class Bird:
    def fly(self):
        print("Flying")

class Penguin(Bird):
    def fly(self):
        raise NotImplementedError("Penguins can't fly!")
```

#### Refactored Code:

```python
class Bird:
    def move(self):
        raise NotImplementedError

class FlyingBird(Bird):
    def move(self):
        print("Flying")

class Penguin(Bird):
    def move(self):
        print("Swimming")

penguin = Penguin()
penguin.move()
```

### 19. **Comments**

#### Smelly Code:

```python
def calculate_area(width, height):
    # Calculate the area by multiplying width and height
    return width * height
```

#### Refactored Code:

```python
def calculate_rectangle_area(width, height):
    return width * height
```

### 20. **Speculative Generality**

#### Smelly Code:

```python
class Shape:
    def draw(self):
        raise NotImplementedError("This method should be overridden")
```

#### Refactored Code:

```python
class Circle:
    def draw(self):
        # Draw a circle
        pass

class Square:
    def draw(self):
        # Draw a square
        pass
```

### 21. **Parallel Inheritance Hierarchies**

#### Smelly Code:

```python

class Employee:
    def calculate_salary(self):
        pass

class FullTimeEmployee(Employee):
    def calculate_salary(self):
        return 5000

class EmployeeDatabase:
    def save(self, employee):
        pass

class FullTimeEmployeeDatabase(EmployeeDatabase):
    def save(self, employee):
        # Save a full-time employee
        pass
```

#### Refactored Code:

```python
class Employee:
    def calculate_salary(self):
        pass

class FullTimeEmployee(Employee):
    def calculate_salary(self):
        return 5000

class EmployeeDatabase:
    def save(self, employee):
        # Save an employee
        pass
```

### 22. **Alternative Classes with Different Interfaces**

#### Smelly Code:

```python
class XmlExporter:
    def export_as_xml(self, data):
        # Export data as XML
        pass

class JsonExporter:

    def to_json(self, data):
        # Export data as JSON
        pass
```

#### Refactored Code:

```python
class Exporter:
    def export(self, data):
        raise NotImplementedError

class XmlExporter(Exporter):
    def export(self, data):
        # Export data as XML
        pass

class JsonExporter(Exporter):
    def export(self, data):
        # Export data as JSON
        pass
```

### 23. **Incomplete/Incorrect Library Usage**

#### Smelly Code:

```python
import re

def find_words(text):
    return re.findall(r'\b\w+\b', text)
```

#### Refactored Code:

```python
import re

def find_words(text):
    return re.findall(r'\w+', text)

text = "This is a test."
print(find_words(text))
```

### 24. **God Object (God Class)**

#### Smelly Code:

```python
class Application:
    def __init__(self):
        self.data = []
        self.users = []
        self.settings = {}

    def add_user(self, user):
        self.users.append(user)

    def save_data(self, item):
        self.data.append(item)

    def update_settings(self, key, value):
        self.settings[key] = value
```

#### Refactored Code:

```python
class DataStore:
    def __init__(self):
        self.data = []

    def save_data(self, item):
        self.data.append(item)

class UserManagement:
    def __init__(self):
        self.users = []

    def add_user(self, user):
        self.users.append(user)

class Settings:
    def __init__(self):
        self.settings = {}

    def update_settings(self, key, value):
        self.settings[key] = value
```

### 25. **Excessive Indentation/Nesting**

#### Smelly Code:

```python
def process_order(order):
    if order.is_valid():
        if order.has_items():
            if order.payment_successful():
                print("Order processed")
            else:
                print("Payment failed")
        else:
            print("No items in order")
    else:
        print("Invalid order")
```

#### Refactored Code:

```python
def process_order(order):
    if not order.is_valid():
        print("Invalid order")
        return

    if not order.has_items():
        print("No items in order")
        return

    if not order.payment_successful():
        print("Payment failed")
        return

    print("Order processed")
```