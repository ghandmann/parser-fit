use strict;
use warnings;
use Test::More;

use FindBin;

use Parser::FIT;

my $fit = Parser::FIT->new();

# INFO
# This is a very naive test against a known example file from the FIT SDK

$fit->parse($FindBin::Bin . "/test-files/Activity.fit");

is($fit->{result}->{session}->[0]->{total_calories}, 1305, "expected total_calories");
is(scalar @{$fit->{result}->{record}}, 9143, "expected number of record messages");

my @expectedMessageTypes = qw/record file_id event session lap device_info activity/;
is(scalar keys %{$fit->{result}}, scalar @expectedMessageTypes, "found expected number of message types");

foreach my $expectedMessageType (@expectedMessageTypes) {
    ok(exists $fit->{result}->{$expectedMessageType}, "result contains message type '$expectedMessageType'");
}

done_testing;