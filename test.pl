#!/usr/bin/perl

use strict;
use warnings;
use 5.10.1;
use FIT;

my $fit = FIT->new();
say $fit;
$fit->parse("./examples/968.fit");
# $fit->parse("/tmp/2021-06-23-09-38-06.fit");
#$fit->parse("/tmp/2021-06-23-18-04-36.fit");
exit;

my $fitFile = $ARGV[0];

my $buffer;
open(my $fh, "<", $fitFile) or die $!;
binmode($fh);
read($fh, $buffer, 1);

my $headerLength = unpack("c", $buffer);
say "HeaderLength: $headerLength";
my $rawHeader = read($fh, $buffer, $headerLength-1);
my ($protocolVersion, $profileLSB, $profileMSB, $dataLength, $fileMagic, $crcLSB, $crcMSB) = unpack("c c c I a4 c c", $buffer);

say "ProtocolVersion: $protocolVersion";
say "profile: $profileMSB $profileLSB";
say "DataLength: $dataLength";
say "FileMagic: $fileMagic";
say "CRC: $crcLSB $crcMSB";

my $msgCount = 0;
my $recordJump = 0;
while(read($fh, $buffer, 1)) {
	my $recordHeader = unpack("c", $buffer);
	say "FirstRecordHeader: $recordHeader";
	my $isNormalHeader = $recordHeader & 1<<7;
	my $messageType = $recordHeader & 1<<6;
	say "normal Header: $isNormalHeader";
	say "message type: $messageType";
	read($fh, $buffer, 5);

	my ($reserved, $architecture, $msgNumber, $fields) = unpack("c c s c", $buffer);
	say "Architecture: $architecture";
	say "global Msg#: $msgNumber";
	say "Fields: $fields";
	$recordJump = $fields*3;
	read($fh, $buffer, $recordJump);

	if($msgCount++ > 10) {
		last;
	}
}





close($fh);
