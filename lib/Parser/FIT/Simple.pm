package Parser::FIT::Simple;

use strict;
use warnings;

use Parser::FIT;

sub new {
    my $class = shift;

    my $self = {};

    bless($self, $class);

    return $self;
}

sub parse {
    my $self = shift;
    my $file = shift;

    my $result = {};

    my $parser = Parser::FIT->new(on => {
        _any => sub {
            my ($msgType, $msg) = (shift, shift);
            if(!exists $result->{$msgType}) {
                $result->{$msgType} = [];
            }

            push(@{$result->{$msgType}}, $msg);
        }
    });

    $parser->parse($file);

    return $result;
}

1;