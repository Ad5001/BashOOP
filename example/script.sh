#!/bin/bash
OOP_ROOT=..

. $OOP_ROOT/oop.sh # Import library.

# Import library
importNamespace Example.shn

# OOP Example
Example.Object obj1 "First Object"
Example.Object obj2 "Second Object"

$obj1.print
# The $ is not mandatory, but is recommanded.
obj2.print

objs=($obj1 $obj2)
${objs[0]}.print
${objs[1]}.print

$obj1.name = "New name"

$obj1.print

# Static example
Example.Static.print "Example text"

# Using directive.
using Example

Object usingObj "New"

$usingObj.print
