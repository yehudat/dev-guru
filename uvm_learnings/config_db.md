# Standard practices:
In UVM, there are some standard practices for using the set and get methods of the uvm_config_db class to ensure clean and efficient configuration management in testbench environment. Here are some common practices:
1. Use null for Global Settings in set method: For configuration settings that apply globally across the testbench, use null as the context component in the set method. This ensures that the configuration is accessible from any part of the testbench hierarchy.
Inst_name is “*” if its scope should be across the hierarchy or it has to be specified with hierarchical path using dot(`.`) as hierarchical separator.
```uvm_config_db#(type T)::set(null, "inst_name", "field_name", value);```
2. Use ‘this’ and empty string in get method: ‘this’ gives the context (here, component name itself) which inside the get function gets its full hierarchical path.  An empty string is used to start the search starts from the context component itself for the matching field name and retrieve it to the last argument(value)
```uvm_config_db#(type T)::get(this, "", "field_name", value);```

3 context arguments below, are always translated to a string, which becomes a key in the uvm_config_db dictionary [key: value pair]. The rest are details:
```
key = {cntxt.get_fullpath(), inst_name, field_name}; //str
```

# Dependency Inversion Principle (DIP):
DIP states that high-level modules should not depend on low-level modules. Both should depend on abstractions. Additionally, abstractions should not depend on details; details should depend on abstractions.

## Application to ConfigDB:
In the context of the configuration database (configdb), DIP can be applied as follows:

- High-level Modules: In a UVM-based testbench, high-level modules such as test sequences or test environments often require access to configuration settings stored in the configdb.
- Low-level Modules: Low-level modules, such as individual components like drivers or monitors, might need to access configuration settings as well.
- Using Abstractions: Instead of high-level modules directly accessing low-level modules to retrieve configuration settings, they should depend on abstractions provided by the configdb.Abstractions here refer to the methods provided by the configdb interface (e.g., get and set methods).
- Reducing Coupling: By depending on the abstractions provided by the configdb, high-level modules are decoupled from the specific implementation details of how configuration settings are stored or retrieved.
This reduces coupling between different parts of the testbench, making it more flexible and easier to maintain.
- Promoting Reusability: Following DIP encourages the use of interfaces and abstractions, which promotes reusability of code.
Different testbenches or components can interact with the configdb in a consistent manner, leading to more modular and reusable designs.

# Configdb:

The UVM configuration database (`uvm_config_db`) is a central mechanism for setting and retrieving configuration values across the UVM-based testbench. It allows to decouple testbench components and dynamically control their behavior by setting configuration values from a centralized location.

## Key Features of `uvm_config_db`

1. **Hierarchical Configuration**:
   - The `uvm_config_db` supports hierarchical configuration, meaning you can set configuration values at various levels of the UVM component hierarchy. Components can then retrieve these values based on their position in the hierarchy.

2. **Parameterized Types**:
   - `uvm_config_db` is a parameterized class, allowing it to handle different data types. Hence, it can store and retrieve integers, strings, objects, or any other data type in the configuration database.

3. **Scoping**:
   - The configuration database allows specifying scopes (or paths) for configuration values, making it possible to apply configurations to specific components or groups of components.

## Core Methods

### Set Method:
- Used to store a configuration value in the database.
  ```systemverilog
  static function bit set (uvm_component cntxt, string inst_name, string field_name, T value);
  ```
  - cntxt: The context component from which the search will start.
  - inst_name: The hierarchical instance name or path.
  - field_name: The name of the configuration field.
  - value: The value to be stored, of parameterized type T.

  Syntax: 
  ```systemverilog
  uvm_config_db#(type T)::set(uvm_component cntxt, string inst_name, string field_name, T value);
  ```
  - type T: The type of configuration value.

### Get Method:
- Used to retrieve a configuration value from the database.
```
static function bit get (uvm_component cntxt, string inst_name, string field_name, ref T value);
```
  - cntxt: The context component from which the search will start.
  - inst_name: The hierarchical instance name or path.
  - field_name: The name of the configuration field.
  - value: A reference to the variable where the retrieved value will be stored

Syntax:
```
uvm_config_db#(type T)::get(uvm_component cntxt, string inst_name, string field_name, ref T value);
```
- type T: The type of configuration value.

## Implementation of set and get function of configdb:
```
// Assuming uvm_pkg.sv includes the necessary UVM components
package uvm_pkg;

 // Import necessary UVM classes
 import uvm_component;

 // Template class for uvm_config_db
 class uvm_config_db #(type T = int);

   // Hash table to store the configuration values
   static uvm_typed_hash_map #(string, T) m_store;

   // Set function
   static function bit set (uvm_component cntxt, string inst_name, string field_name, T value);
     string full_name;

     // Construct the full name key
     if (cntxt == null) begin
       full_name = inst_name;
     end else begin
       full_name = {cntxt.get_full_name(), ".", inst_name};
     end

     // Create the full key by combining the instance name and the field name
     string key = {full_name, ".", field_name};

     // Store the value in the hash map
     m_store[key] = value;

     return 1;
   endfunction
   
    static function bit get (uvm_component cntxt, string inst_name, string field_name, ref T value);
     string full_name;
     string key;
     bit found;

     // Construct the full name key
     if (cntxt == null) begin
       full_name = inst_name;
     end else begin
       full_name = {cntxt.get_full_name(), ".", inst_name};
     end

     // Create the full key by combining the instance name and the field name
     key = {full_name, ".", field_name};

     // Retrieve the value from the hash map
     found = m_store.exists(key);
     if (found) begin
       value = m_store[key];
     end else begin
       // Optionally handle the case where the key is not found
       value = '0;  // Default value, handle appropriately
     end

     return found;
   endfunction

 endclass
```
## Example of set method of config db in svunit framework with explanation:

In the build function of the top file( module_ut file), set function is called to pass parameterized virtual interface from top file to driver component using following code:
```
uvm_config_db#(virtual cmd_if#(ADDR_WIDTH, BE_WIDTH, RD_SIZE_WIDTH, DATA_IN_WIDTH, DATA_OUT_WIDTH))::set(null,"env.m_driver", "cmd_vif", cmd_if);
```
The purpose of this configuration setting is to provide the m_driver component within the env environment with a specific virtual interface cmd_if.
The set method is used to store a value in the configuration database.
- null: passing null  indicates that the setting should apply globally or be accessible from any starting point in the hierarchy.
- "env.m_driver": This is the instance name or the hierarchical path within the UVM component hierarchy where this configuration setting should apply. In this case, the configuration is being set for the component named m_driver within the component env.
- "cmd_vif": This is the field name or key under which the configuration value is stored. It identifies the specific configuration setting. In this case, it indicates that the configuration is for a virtual interface named cmd_vif.
- cmd_if: This is the value being stored in the configuration database. cmd_if is the virtual interface instance that you want to configure for any component in the hierarchy.

### Wild card usage in set function:
```
uvm_config_db#(virtual cmd_if#(ADDR_WIDTH, BE_WIDTH, RD_SIZE_WIDTH, DATA_IN_WIDTH, DATA_OUT_WIDTH))::set(null,"* ", "cmd_vif", cmd_if);
```

```"*"```: This is the instance name or hierarchical path. The ```"*"``` wildcard means that the setting applies to all instances in the hierarchy. Any component that tries to retrieve the cmd_vif configuration will match this setting.

### Two Precedence rules of set:
There are two precedence rules applicable to uvm_config_db. In the build_phase,
1. A set() call in a context higher up the component hierarchy takes precedence over a set() call that occurs lower in the hierarchical path.
2. On having same context field, the last set() call takes precedence over the earlier set() call.

## Example of get method of config db in svunit framework with explanation:

In the build phase of the component(here, driver), get function is called to receive parameterized virtual interface that matches field_name(here, cmd_vif) using following code:
```
uvm_config_db #(virtual cmd_if #(ADDR_WIDTH, BE_WIDTH, RD_SIZE_WIDTH, DATA_IN_WIDTH, DATA_OUT_WIDTH))::get(this,"", "cmd_vif", vif);
```
The get method is used to retrieve a value from the configuration database.
- this: It refers to the current instance of the component that is trying to retrieve the configuration value.
- “” : An empty string "" means that the search starts from the context component itself.
- "cmd_vif": This is the field name or key under which the configuration value is stored. It identifies the specific configuration setting. Here, it indicates that the configuration is for a virtual interface named cmd_vif.
- vif: This is the variable where the retrieved value will be stored. vif is expected to be declared as a virtual interface of the appropriate type in the component.




