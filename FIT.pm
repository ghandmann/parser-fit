package FIT;

use strict;
use warnings;
use Carp qw/croak carp/;

our $VERSION = 0.01;

sub new {
	my $class = shift;
	my $ref = {
		_DEBUG => 1,
		header => {},
		body => {},
		globalMessages => [],
		localMessages => [],
		records => 0,
		fh => undef,
		buffer => "",
		headerLength => 0,
	};

	bless($ref, $class);

	return $ref;
}

sub parse {
	my $self = shift;
	my $file = shift;

	croak "No file given to parse()!" unless($file);

	$self->_debug("Parsing '$file'");

	croak "File '$file' doesn't exist!" if(!-f $file);

	$self->_debug("Opening file");
	open(my $input, "<", $file) or croak "Error opening '$file': $!";
	binmode($input);

	$self->{fh} = $input;
	my $header = $self->_read_header();
	$self->{header} = $self->_parse_header($header);
	my $dataBody = $self->_readBytes($self->{header}->{dataLength});
	$self->_debug("Data body has $dataBody bytes");
	exit;
	$self->_parse_data_records();
	#$self->_parse_crc();

	close($input);
}

sub _read_header {
	my $self = shift;

	my $headerLengthByte = $self->_readBytes(1);
	my $headerLength = unpack("c", $headerLengthByte);
	$self->{headerLength} = $headerLength;

	# The 1-Byte headerLength field is included in the total header length
	my $headerWithoutLengthByte = $headerLength - 1;

	my $header = $self->_readBytes($headerWithoutLengthByte);

	return $header;
}

sub _parse_header {
	my $self = shift;
	my $header = shift;

	my ($protocolVersion, $profile, $dataLength, $fileMagic, $crc);

	my $headerLength = length $header;

	if($headerLength == 13) {
		($protocolVersion, $profile, $dataLength, $fileMagic, $crc) = unpack("c s I! a4 s", $header);
	}
	elsif($headerLength == 11) {
		($protocolVersion, $profile, $dataLength, $fileMagic) = unpack("c s I! a4", $header);

		# Short header has no CRC value
		$crc = undef;
	}
	else {
		croak "Invalid headerLength=${headerLength}! Don't know how to handle this.";
	}

	croak "File either corrupted or not a real FIT file! (Missing magic '.FIT' string in header)" unless($fileMagic eq ".FIT");

	$self->_debug("ProtocolVersion: $protocolVersion");
	$self->_debug("Profile: $profile");
	$self->_debug("DataLength: $dataLength Bytes");
	$self->_debug("FileMagic: $fileMagic");
	$self->_debug("CRC: " . (defined($crc) ? $crc : "N/A"));

	my $headerInfo = {
		protocolVersion => $protocolVersion,
		profile => $profile,
		dataLength => $dataLength,
		crc => $crc,
		eof => $self->{headerLength} + $dataLength,
	};

	return $headerInfo;
}

sub _parse_record_header {
	my $self = shift;
	my $recordHeader = shift;

	return {
		# Bit 7 inidcates a normal header (=0) or "something else"
		isNormalHeader => (($recordHeader & (1<<7)) == 0),
		# Bit 6 indicates a definition msg
		isDefinitionMessage => (($recordHeader & (1<<6)) > 0),
		# Bit 5 indicates "developer data flag"
		isDeveloperData => (($recordHeader & (1<<5)) > 0),
		# Bit 4 is reserved
		# Bits 3-0 define the localMessageType
		localMessageType => $recordHeader & 0xF,
	};
}

sub _parse_data_records {
	my $self = shift;

	$self->_debug("Parsing Data Records");
	while($self->{totalBytes} < $self->{header}->{eof}) {
		$self->_readBytes(1);
		my ($recordHeaderByte) = unpack("c", $self->_buffer);
		my $headerType = $recordHeaderByte & 1<<7;

		$self->_debug("HeaderBytes in Binary: " . sprintf("%08b", $recordHeaderByte));

		if($headerType == 0) {
			$self->_debug("Found a normal RecordHeader");
			my $messageType = $recordHeaderByte & 1<<6;
			my $localMessageType = $recordHeaderByte & 7; # Bits 0, 1, 2

			$self->{current_local_message_type} = $localMessageType;

			if($messageType == 0) {
				$self->_debug("Found a Data Message");
				if(!defined $self->{localMessages}->[$localMessageType]) {
					die "localMessage-Data [$localMessageType] received before definition!";
				}

				$self->{records}++;

				$self->_debug("LocalMessage: $localMessageType - Size: " . $self->{localMessages}->[$localMessageType]->{size} . " Bytes");
				$self->_debug("skipping Record $self->{records} data section...");
				$self->_readBytes($self->{localMessages}->[$localMessageType]->{size});
			}
			else {
				$self->_debug("Found a Definition Message");
				$self->_debug("LocalMessage: $localMessageType");
				if(defined $self->{localMessages}->[$localMessageType]) {
					die "Redefinition of already defined LocalMessage: $localMessageType @ Byte " . $self->{totalBytes};
				}
				$self->_parse_definition_message();
				
			}
		}
		else {
			$self->_debug("Found a Compressed Timestamp Header");
			$self->{records}++;
			die "Please Implement CompressedTimestampHeaders int " . __PACKAGE__ . "!";
		}
	}
	$self->_debug("DataRecords finished! Found a total of " . $self->{records} . " Records");
}

sub _parse_definition_message {
	my $self = shift;
	my $data = shift;
	my $recordLength;

	#$self->_readBytes(5);
	my ($reserved, $arch, $globalMessage, $fields) = unpack("c c s c", $data);

	$self->_debug("DefinitionMessageHeader:");
	$self->_debug("Arch: $arch - GlobalMessage: $globalMessage - Fields: $fields");
	carp "BigEndian isn't supported so far!" if($arch == 1);

	foreach(1..$fields) {
		$self->_readBytes(3); # Every Field has 3 Bytes
		my ($fieldDefinition, $size, $baseType)  = unpack("c c c", $self->_buffer);
		my ($baseTypeEndian, $baseTypeNumber) = ($baseType & 128, $baseType & 15);
		$self->_debug("FieldDefinition: Nr: $fieldDefinition, Size: $size, baseTypeEndian: $baseTypeEndian - BaseNr: $baseTypeNumber");
		$recordLength += $size;
	}

	$self->{localMessages}->[$self->{current_local_message_type}] = { size => $recordLength };
	$self->_debug("Following Record length: $recordLength bytes");
}

sub _parse_crc {
	# TODO implement this one...some time :D
}

sub _debug {
	my $self = shift;
	if($self->{_DEBUG}) {
		print "[FIT.pm DEBUG] ", @_;
		print "\n";
	}
}

sub _readBytes {
	my $self = shift;
	my $num = shift;

	$self->{totalBytes} += $num;
	my $buffer;
	my $bytesRead = read($self->{fh}, $buffer, $num);
	# TODO error handling based on bytesRead
	return $buffer;
}

=head1 PUBLIC INTERFACE

=head1 INTERNAL METHODS

=head2 _buffer()

Returns the buffer-Data of the last call to L<_readBytes>.

If nothing has been read so far, will return undef.

=cut

=head2 _readBytes($num)

Reads $num Bytes from the current Filehandle and stores those internally in the Buffer.

To access the buffer see L<_buffer>

=cut


1;
