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

# This file contains all functions required to create a namespace.
# Internal variables are marked with a beginning underscore, like in most other languages.
# Signatures are a list of arguments.. Those within <> are mandatory, the ones within [] are optional.

# Namespace related variables.
_namespace=""
_namespacePath=$(realpath $(dirname ${BASH_SOURCE[0]}))

# This dictionnary saves all classes for each namespace so they can be retreived and aliased.
declare -Ag _namespacesClasses
# This dictionnary links all files for static namespaces.
declare -Ag _namespacesStaticClasses

# Namespace declaration.
# Signature: ([string namespaceName])
namespace() {
    _namespace=$1;
}

# Imports a namespace into the current shell.
# It saves the path of the file so that relative paths can be
# properly resolved.
# For example, if the object Object exists within namespace Example, it
# will be accessible with "Example.Object".
# Signature: (<string namespaceFile>)
importNamespace() {
    namespaceFile=$1
    # Save the path in order to get the absolute path of the file.
    _namespacePath=$(realpath $(dirname $namespaceFile))
    . $namespaceFile
}

# Aliases the classes in global namespace.
# For example, if the object Object exists within namespace Example, it
# will be accessible with "Example.Object" and "Object".
# Signature: (<string namespaceName>)
using() {
    namespaceName=$1
    # Import static classes
    if [ "${_namespacesStaticClasses[$namespaceName]}" != "" ]; then
        oldNamespace=_namespace
        namespace # Reset namespace
        # Split all 
        staticClasses=$(echo "${_namespacesStaticClasses[$namespaceName]}" | tr ";" "\n")
        for cl in $staticClasses; do
            parts=$(echo "$cl" | tr ":" "\n")
            static_class ${parts[0]} ${parts[1]}
        done
        namespace $oldNamespace
    fi
    # Import static classes
    if [ "${_namespacesClasses[$namespaceName]}" != "" ]; then
        classes=$(echo "${_namespacesClasses[$namespaceName]}" | tr ";" "\n")
        for type in $classes; do
            eval "$type() { $namespaceName.$type \$@; }"
        done
    fi
}

# Creates a "property holder" based on a name.
# A "property holder" is a dictionnary maintaining the values of properties for a specific variable.
# One is created each time an object is declared, but this function can also be used for namespaces to have global
# properties.
# Signature: (<string name>)
createPropertyHolder() {
    name=$1
    eval "declare -Ag _${name}_properties"
}

# Creates an object instance.
# Signature: (<string type>, <string associatedFile>, <string variableName>, [string[] constructorArguments])
_createObject() {
    type=$1
    associatedFile=$2
    varName=$3
    constructorArguments=${@:4}
    
    # Declare dummy constructor.
    eval "$varName.constructor() { :; }"
    # Declare base properties.
    eval "$varName.type() { echo $type; }"
    eval "$varName.source() { echo $associatedFile; }"
    # Create property array.
    createPropertyHolder $varName
    # alias the "varName" variable to itself, so that it can be used and transmitted in other variables (e.g: $varName.name would alias to varName.name)
    eval "$varName='$varName'"
    # Imports the file and replace all "<Type>." with the variable name.
    . <(sed s/this\\./$varName./g <(sed s/$type\\./$varName./g $associatedFile))
    # Call the constructor
    $varName.constructor $constructorArguments
}

# Object creation.
# Signature: (<string type>, <string associatedFile>)
class() {
    type=$1 # Type of the object as declared within the file.
    associatedFile=$2
    objFullName=$type # Type of the object referenced elsewhere
    
    if [ "$_namespace" != "" ]; then
        objFullName="${_namespace}.$type"
    fi
    
    if [ ${associatedFile::1} != "/" ]; then # Relative path, we save only the absolute path
        associatedFile="$_namespacePath/$associatedFile"
    fi
    # Declares a new function for object initialisation.
    eval "$objFullName() { _createObject $type $associatedFile \$@; }"
    # Save the class in the dictionnary for reference.
    if [ "$_namespace" != "" ]; then
        if [ "${_namespacesClasses[$_namespace]}" == "" ]; then
            _namespacesClasses[$_namespace]=$type
        else
            _namespacesClasses[$_namespace]="${_namespacesClasses[$_namespace]};$type"
        fi
    fi
}

# Static class creation
# Signature: (<string type>, <string associatedFile>)
static_class() {
    type=$1 # Type of the object as declared within the file.
    associatedFile=$2
    objFullName=$type # Type of the object referenced elsewhere
    
    if [ "$_namespace" != "" ]; then
        objFullName="${_namespace}.$type"
    fi
    
    if [ ${associatedFile::1} != "/" ]; then # Relative path, we save only the absolute path
        associatedFile="$_namespacePath/$associatedFile"
    fi

    # Imports the file and replace all "<Type>." with the variable name.
    . <(sed s/this\\./$objFullName./g <(sed s/$type\\./$objFullName./g $associatedFile))
    # Save the class in the dictionnary for reference.
    if [ "$_namespace" != "" ]; then
        if [ "${_namespacesStaticClasses[$_namespace]}" == "" ]; then
            _namespacesStaticClasses[$_namespace]="$type:$associatedFile"
        else
            _namespacesStaticClasses[$_namespace]="${_namespacesStaticClasses[$_namespace]};$type:$associatedFile"
        fi
    fi
}

# Associated function for properties
# Signature: (<string variableName>, <string propertyName>, [string operator, string value])
_accessProperty() {
    varName=$1
    prop=$2
    val="${@:4}"
    if [ "$3" == "=" ]; then
        eval "_${varName}_properties[$prop]=\"\$val\""
    else
        eval "echo \"\${_${varName}_properties[$prop]}\""
    fi
}

# Declares a property with an optional default value.
# Signature: (<string propertyFullName>, [string propertyValue])
property() {
    propertyFullName=$1
    propertyValue=$2
    # Split the name by ".". First element is variable name,
    # second is property name.
    propertyNames=($(echo $propertyFullName | tr "." "\n"))
    varName=${propertyNames[0]}
    prop=${propertyNames[1]}
    # Default value
    eval "_${varName}_properties[$prop]='$propertyValue'"
    # Property alias 
    eval "$propertyFullName() { _accessProperty $varName $prop \$1 \"\${@:2}\";  }"
}
