#!/usr/bin/perl

use strict;
use warnings;
use 5.10.1;
use Parser::FIT;

my $fit = Parser::FIT->new();

#$fit->parse("./examples/968.fit");
my $result = $fit->parse("./FitSDKRelease_21.54.01/examples/Activity.fit");

my $conversion = 180/2**31;
#say "Trackpoints: " . join(";", map { ($_->{position_lat}*$conversion) . "," . ($_->{position_long}*$conversion) } @{$fit->{result}->{record}});

say "Fit Messages: " . join(", ", keys %{$result});

say "Total Calories: " . $result->{session}->[0]->{total_calories};
# $fit->parse("/tmp/2021-06-23-09-38-06.fit");
#$fit->parse("/tmp/2021-06-23-18-04-36.fit");
