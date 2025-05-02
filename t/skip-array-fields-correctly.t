use strict;
use warnings;
use Test::More;

use Parser::FIT;

my $parser = Parser::FIT->new();

my $sessionCount = 0;
$parser->on(session => sub {
    my $msg = shift;
    is($msg->{timestamp}->{value}, 1745947432);
    is($msg->{total_cycles}->{value}, 10391);
    is($msg->{swc_long}->{value}, 9.03169487603009);
    is($msg->{enhanced_avg_speed}->{value}, 5.926);
    is($msg->{avg_heart_rate}->{value}, 140);
    is($msg->{total_anaerobic_training_effect}->{value}, 0.4);
    is($msg->{total_calories}->{value}, 1422);
    $sessionCount++;
});

# This record contains multiple array values (e.G. avg_left_power_phase) which are unpacked into multiple entries
# which need to be skipped correctly in order to get the correct data for the next field.
my $recordHeaderBytes = pack("H*", "430000120063fd04860204860304850404850704860804860904860a04861d04851e04851f04852004852604852704853004866e20077004867404027504027604027704027804847904847c04867d0486a80485b50488bb0488cb0486fe02840b02840d02841402841502841602841702841902841a02842202842302842402842502842d02846a02846b02846c02847102848b0284970284a90284aa0284b10284b20284b30284b40284b70284c40284cc02840001000101000501000601001001021101021201021301021801021b01021c01003901013a01015101005c01025d01025e01026501026601026701026801026901026d01026f01027201017301017a02027b02028901028a0202960101b80100b90102bc0100c00102c10102ca0102cd0102ce0102cf0102db0102");
my $recordDataBytes = pack("H*", "0328bf734228bf7342151d4e227d2b6c0602a77e0002a77e00c10e4b00972800006cff5022dd9a8e06560d43227d2b6c0658234e2217346c06ffffffff52454e4e52414400000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff26170000cd37000074fa8500ffffffffffffffffffffffff00008e05ffffffffffff6e026c0200000100ffffffffffffffffffff0000ffff5901ffff6f00ffff150dcc1064006e05ee021d07ffffca00ffff080102078ca85b7027ff001115003500ffffffffffffffff7f7fffffffff0409000e00ff02ffffffffffff00");

my $dataLength = length($recordHeaderBytes) + length($recordDataBytes);
my @dataLengthBytes = unpack("(A2)*", unpack("H*", pack("L", $dataLength)));

my @fitFileHeader = map { hex } qw/0E 10 98 00/, @dataLengthBytes, qw/2E 46 49 54 00 00/;
my $header = pack("C*", @fitFileHeader);

my $preComputedCrc = pack("H*", "A316");

my $fitFile = $header . $recordHeaderBytes . $recordDataBytes. $preComputedCrc;

$parser->parse_data($fitFile);

is($sessionCount, 1, "session callback called exactly once");

done_testing;