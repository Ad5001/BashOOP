# BashOOP

This idea was inspired from https://stackoverflow.com/a/40981277 in order to be adapted into making a proper OOP with constructors, properties and namespace system for bash.

## Reference:

- .shn: **SH**ell **N**amespace
- .shc: **SH**ell **C**lass

## Syntax:


To declare objects, there exists 3 scripts.

- The main script in which we'll use our object (suggested extension: `.sh`)
- The namespace declaration script (suggested extension: `.shn`)
- The class declaration script (suggested extension: `.shc`)

The full example is available in the "example" directory.

### Declaring objects.

An object has a type name, properties and functions.    
To declare a property, you can use the `property` function. For example, for an class named `Object`, you can declare a property name using:
```bash
property Object.name
```
**NOTE**: Bash doesn't have a typing system, so you cannot set property types.
You can also set default values by adding a property after the declaration, e.g:
```bash
property Object.name "Example"
```

Class functions are declared the same way you would in bash, except it uses a prefix with object type. For example:
```bash
Object.print() {
    echo "Example OOP from $(this.name)!"
}
```
As you can see here, you can access properties of the object using the `this` keyword in a function call.    
Similarly, you can set properties using a `=` and value argument. For example:
```bash
this.name = "New name"
```

Objects can also have constructors which will be called at the creation of the object with arguments provided at the creation.   
They are simply a function with the name `constructor`. They aren't mandatory for any object.

### Creating a namespace.
While you can import objects directly in the global namespace, it's recommanded to use a separate namespace file.

When you've created your namespace file, you can specify the name of the namespace using the `namespace` keyword:
```bash
namespace Example
```
You can then declare object classes using the `class` directive by specifying it's name and associated script file. For example:
```bash
class Object "Object.shc"
```

All objects created under this class will be accessible with namespace as prefix (here our Object class would be accessible under `Example.Object`).

Similarly, static classes can be declared using the `static_class` keyword.
```bash
static_class Static "Static.shc"
```

**NOTE**: Static classes can't have properties. However, you can declare "namespace properties" using first the `createPropertyHolder` and then declare properties directly in the namespace file like this:
```bash
createPropertyHolder Example

property Example.name
```

### Using objects.
Now that we've created our namespace, we will want to use it and our objects in our script.   
First things first, we'll want to import the library `oop.sh`. Depending on where it's located, you will want to use a global variable indicating it's location.    
```bash
. $OOP_ROOT/oop.sh # Import library.
```

After that, we'll want to import our namespace file with all it's classes prefixed in the namespace name.
```bash
importNamespace "Example.shn"
```

After that you can declare the object using the following syntax: `<ObjectType> <variableName> [constructor arguments...]`. For example:
```bash
Example.Object obj1 "Test"
```

You can then call it's functions.
```bash
$obj1.print
obj1.print
```
**NOTE**: The $ is not mandatory, but is recommanded for clarity.

... or access and edit it's properties.
```bash
name=$(obj1.name)
obj1.name = "New name"
```

You can store objects in variables as a string. For example, you can have have objects as class arguments, function returs or arrays of objects like this:
```bash
Example.Object obj1 "First Object"
Example.Object obj2 "Second Object"
objs=($obj1 $obj2)
${objs[0]}.print
${objs[1]}.print
```

You can also access the static classes by using their class type directly. For example:
```bash
Example.Static.print "Example text"
```

If you find that using the namespace everytime is a bit cumbersome, you can use the `using` keyword to alias all classes of a namespace into the global namespace.    
Example usage:
```bash
using Example

Object usingObj "New"

$usingObj.print
```
**NOTE**: When `using` a namespace which contains static classes, please note that the static class file will be re-imported.
**NOTE**: `using` is not file contextual. So `using` a namespace will use it in every bash script.
