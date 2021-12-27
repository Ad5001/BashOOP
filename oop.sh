#!/bin/bash

# This file contains all functions required to create a namespace.
# Internal variables are marked with a beginning underscore, like in most other languages.
# Signatures are a list of arguments.. Those within <> are mandatory, the ones within [] are optional.
_namespace=""
_namespacePath=""

# Namespace declaration.
# Signature: ([string namespaceName])
namespace() {
    _namespace=$1;
}

# Imports a namespace into the current shell.
# Signature: (<string namespaceFile>)
importNamespace() {
    namespaceFile=$1
    # Save the path in order to get the absolute path of the file.
    _namespacePath=$(realpath $(dirname $namespaceFile))
    . $namespaceFile
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
    # Create property array.
    eval "declare -Ag _${varName}_properties"
    # Imports the file and replace all "<Type>." with the variable name.
    . <(sed s/this\\./$varName./g <(sed s/$type\\./$varName./g $associatedFile))
    # Call the constructor
    eval "$varName.constructor $constructorArguments"
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
    eval "$objFullName() { _createObject $type $associatedFile \$@;  }"
}

# Associated function for properties
# Signature: (<string variableName>, <string propertyName>, [string operator, string value])
_accessProperty() {
    varName=$1
    prop=$2
    if [ "$3" == "=" ]; then
        eval "_${varName}_properties[$prop]='${@:4}'"
    else
        eval "echo \${_${varName}_properties[$prop]}"
    fi
}

# Declares a property.
# Signature: (<string propertyFullName>)
property() {
    propertyFullName=$1
    # Split the name by ".". First element is variable name,
    # second is property name.
    propertyNames=($(echo $propertyFullName | tr "." "\n"))
    varName=${propertyNames[0]}
    prop=${propertyNames[1]}
    # Default value
    eval "_${varName}_properties[$prop]=''"
    # Property alias 
    eval "$propertyFullName() { _accessProperty $varName $prop \$@;  }"
}
