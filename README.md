# BashOOP

This idea was inspired from https://stackoverflow.com/a/40981277 in order to be adapted into making a proper OOP with constructors, properties and namespace system for bash.

## Reference:

- .shn: **SH**ell **N**amespace
- .shc: **SH**ell **C**lass

## Example syntax:

### Declaring objects.

`script.sh`:
This is the main script which will use our objects.

```bash
. $OOP_ROOT/oop.sh # Import library.

importNamespace Example.shn

Example.Object t1 "Test"
Example.Object t2 "Example"

t1.print
t2.print

t1.name = "New name"

t1.print
```

`Example.shn`:
This file declares our namespace and all the objects within it.

```bash
# Namespace declaration.
namespace Example
# If namespace is set to null (no argument), then the object will be declared globally.
# Otherwise, the object will be declared within the namespace.

# Object declaration, from class name to file name.
class Object "Object.shc"

```

`Object.shc`:
This file will contain the object code.

```bash
# Property declaration
property Object.name

# Optional constructor.
Object.constructor() {
    Object.name = $1
}

# Example function
Object.print() {
    echo "Example OOP from $($this.name)!"
}
```
