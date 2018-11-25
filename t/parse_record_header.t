use Test::More;
use FIT;

my $fit = FIT->new();


subtest "is normal record header" => sub {
    my $normalRecordHeader = $fit->_parse_record_header(127);
    ok($normalRecordHeader->{isNormalHeader}, "this is a normal record header");

    my $notNormalRecordHeader = $fit->_parse_record_header(255);
    ok(!$notNormalRecordHeader->{isNormalHeader}, "this is not a normal record header");
};

subtest "is definition message" => sub {
    # all bits 1
    ok($fit->_parse_record_header(255), "is a definition message");

    # only def msg bit 1
    ok($fit->_parse_record_header(64), "is a definition message");

    # all bits 0
    ok($fit->_parse_record_header(0), "not a definition message");

    # only bit 6 == 0
    ok($fit->_parse_record_header(191), "not a definition message");
};

subtest "is developer data flag message" => sub {
    # all bits 1
    ok($fit->_parse_record_header(255), "is a definition message");

    # only def msg bit 1
    ok($fit->_parse_record_header(32), "is a definition message");

    # all bits 0
    ok($fit->_parse_record_header(0), "not a definition message");

    # only bit 6 == 0
    ok($fit->_parse_record_header(223), "not a definition message");
};

subtest "localMessageType" => sub {
    # all bits 1
    is($fit->_parse_record_header(255)->{localMessageType}, 15, "Right localMessageType");

    # only first bit 1
    is($fit->_parse_record_header(1)->{localMessageType}, 1, "Right localMessageType");

    # all bits 0
    is($fit->_parse_record_header(0)->{localMessageType}, 0, "Right localMessageType");

    # bit 4 and 2
    is($fit->_parse_record_header(10)->{localMessageType}, 10, "Right localMessageType");
};


done_testing;