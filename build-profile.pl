#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use Text::CSV qw(csv);
use Mojo::JSON qw/j/;
use Data::Dumper;
use Getopt::Long;

my $forceEnabled = undef;
GetOptions("force" => \$forceEnabled);

my $file = $ARGV[0];

my $data = csv(in => $file, headers => "auto", blank_is_undef => 1);
my $profile = parseProfileData($data);
writeProfileModule($profile);

sub writeProfileModule {
    my $profileFileName = "Profile.pm";

    if(-f $profileFileName and !$forceEnabled) {
        say STDERR "[ERROR] Profile.pm already exists! Use force (--force) to overwrite!";
        exit 1;
    }

    open(my $fh, ">", $profileFileName) or die "Failed to open '$profileFileName': $!";
    say $fh "# WARNING! This file is auto generated by '$0'! Changes will be lost by the next run!";
    say $fh "package Parser::FIT::Profile;";
    print $fh 'our $PROFILE = ';

    $Data::Dumper::Sortkeys = 1;
    $Data::Dumper::Varname = "PROFILE";
    $Data::Dumper::Terse = 1;

    print $fh Dumper($profile);
}


sub parseProfileData {
    my $data = shift;

    my $currentMessageType = undef;
    my %profile;

    foreach my $row (@$data) {
        if(!defined $currentMessageType && !defined $row->{"Message Name"}) {
            next;
        }

        my $messageName = $row->{"Message Name"};

        if(defined $messageName) {
            $currentMessageType = {
                name => $messageName,
                fields => {}
            };

            $profile{$messageName} = $currentMessageType;

            # say "Found MessageType=" . $currentMessageType->{name};
        }

        if(!defined $row->{"Message Name"} && defined $row->{"Field Def #"} && defined $row->{"Field Name"} && defined $row->{"Field Type"}) {
            my $fieldId = $row->{"Field Def #"};
            my $fieldName = $row->{"Field Name"};
            my $fieldType = $row->{"Field Type"};
            my $scale = $row->{"Scale"};# eq '' ? 1 : $row->{"Scale"};
            my $offset = $row->{"Offset"};
            my $unit = cleanUpUnits($row->{"Units"});

            $currentMessageType->{fields}->{$fieldId} = {
                id => $fieldId,
                name => $fieldName,
                type => $fieldType,
                scale => $scale,
                offset => $offset,
                unit => $unit,
            };
        }
    }

    return \%profile;
}

sub cleanUpUnits {
    my $unitString = shift;

    if(!defined $unitString) {
        return $unitString;
    }

    if($unitString eq "percent") {
        return "%";
    }

    return $unitString;
}

