use strict;
use warnings;
use Test::More;

use FindBin;

use Parser::FIT;

my $fit = Parser::FIT->new();

my $invalidCadenceFields = 0;
my $invalidSpeedFields = 0;

my $parser = Parser::FIT->new(on => {
    record => sub {
        my $r = shift;

        $invalidCadenceFields++ if $r->{cadence}->{isInvalid};
        $invalidSpeedFields++ if $r->{speed}->{isInvalid};
    }
});

# Special file from the FIT SDK containing records with invalid fields
my $fileWithInvalidFields = $FindBin::Bin . "/test-files/activity_lowbattery.fit";
$parser->parse($fileWithInvalidFields);

is($invalidCadenceFields, 13, "Expected 13 invalid cadence fields in '/test-files/activity_lowbattery.fit'") or
    diag("This test relies on a special FIT file containing invalid values (activity_lowbattery.fit contained invalid speed and cadence fields). If it fails, maybe the file has changed?");

is($invalidSpeedFields, 19, "Expected 19 invalid speed fields in '/test-files/activity_lowbattery.fit'") or 
    diag("This test relies on a special FIT file containing invalid values (activity_lowbattery.fit contained invalid speed and cadence fields). If it fails, maybe the file has changed?");

done_testing;