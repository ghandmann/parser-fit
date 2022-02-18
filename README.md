![Tests](https://github.com/ghandmann/parser-fit/actions/workflows/test.yml/badge.svg)
[![Coverage Status](https://coveralls.io/repos/github/ghandmann/parser-fit/badge.svg?branch=main)](https://coveralls.io/github/ghandmann/parser-fit?branch=main)

# Parse FIT (Flexibel & Interopberable data Transfer) Files

## FIT SDK and Documentation
For legal reasons the FIT SDK itself is not part of this Repository.

See [Garmin](https://developer.garmin.com/fit/).

## Building Profile Data
The FIT file format defines messages and corresponding fields in an so called "profile". This profile is documented and shared via an Excel file.

In order to auto generated perl datastructures of this profile one can use the `build-profile.pl` helper script.

It expects the `Messages` Table from the Garmin FIT Profile Excel-Sheet as CSV-Input. And produces a new `Profile.pm` module.

Usage:
`$ perl build-profile.pl ./path/to/profile.csv`

You may use the command line option `-f` to overwrite an already existing `Profile.pm` file.

## TODOs
* Write tests to validate message type parsing/naming/lookups
* Skip over messages with an unknown GlobalMessageNumber

## Ideas

* Provide an event based interface (like XML::Parser)

Test commit to see if dependency caching works. :)