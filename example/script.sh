#!/bin/bash
#
# BashOOP - Simple OOP implementation for bash.
# Copyright (C) 2021  Ad5001 <mail@ad5001.eu>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

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
