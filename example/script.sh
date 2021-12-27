#!/bin/bash
OOP_ROOT=..

. $OOP_ROOT/oop.sh # Import library.

importNamespace Example.shn

Example.Object t1 "Test"
Example.Object t2 "Example"

t1.print
t2.print

t1.name = "New name"

t1.print
