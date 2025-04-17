use strict;
use warnings;
use Test::More;

use Parser::FIT;

my $parser = Parser::FIT->new();

my $recordCount = 0;
$parser->on(record => sub {
    my $msg = shift;
    ok(exists $msg->{timestamp}, "has timestamp key");

    my $fitEpocheOffset = 631065600;
    my $expectedTimestamp = 1234567890 + $fitEpocheOffset;

    is($msg->{timestamp}->{value}, $expectedTimestamp, "expected timestamp value");
    $recordCount++;
});

my @fitFileHeader = map { hex } qw/0E 10 98 00 17 00 00 00 2E 46 49 54 00 00/;

# Definition Message with GlobalMessageId=22, 1 Field, 3*0x01 as FieldDefinition
my @unknownGlobalMessageDefinitionMsg = (
    0b01000000, # Data definition header for LocalMesg=0
    0, 0, # Reserved & Arch=LittleEndian
    22, 0, # GlobalMsgId=22 (unknown global message id)
    1, # FieldCount = 1
    1, 1, 1 # First Field: FieldNr=1, FieldSize=1byte, FieldBaseType=sint8
    );

my @unknownGlobalMessageRecordMsg = (
    0, # Normal data header for LocalMsg=0
    42 # Some random byte for FieldNr=1 of LocalMsg=0
);

my @recordDefinitionMsg = (
    0b01000001, # Data definition header for LocalMesg=1
    0, 0, # Reserved & Arch=LittleEndian
    20, 0, # GlobalMsgId=20
    1, # FieldCount=1
    253, 4, 12 # First Field: FieldNr=253, FieldSize=4bytes, FieldBaseType=uint32z
    );

my @recordData = (
    0x01, # Normal data header for LocalMesg=1
    0x49, 0x96, 0x02, 0xD2 # 4 Bytes for uint32z timestamp=1234567890
    );


my $data = pack("C*", (@fitFileHeader, @unknownGlobalMessageDefinitionMsg, @unknownGlobalMessageRecordMsg, @recordDefinitionMsg, @recordData));

$parser->parse_data($data);

is($recordCount, 1, "record callback called only once");


done_testing;