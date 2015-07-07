package HC::Common;
use diagnostics;
use warnings;
use strict;
#

BEGIN {
    #require Exporter;
    #@ISA
    #@EXPORT
    #@EXPORT_OK
    our $VERSION = '0.01';
}

use Getopt::Long 2.33 qw(:config gnu_getopt no_auto_abbrev);
use Pod::Usage;

=head1 NAME                                                                     

HC::Common - Basic things that Hamish always uses

=head1 SYNOPSIS

  use HC::Common;
  my $options = x zy
  my $options_default = ab c
  do_options(x a b y);

=head1 DESCRIPTION

Basic helper routines.  Currently, commandline processing and data dump
default settings

=over 4

=cut

sub options2string {
    my @option_list = grep {$_} @_;
    foreach(sort @option_list) {
        # TODO
        # - separate short, long and aliases
        # - remove the type tags?
        $_="--".$_;
    }
    return join(", ",@option_list);
}

=item B<do_options>

  do_options($optionhash,$option_list);

handles commandline options

=cut

sub do_options {
    my $option = shift || die "no option!";
    my @option_list = grep {$_} @_;
    GetOptions($option,@option_list,'man','help|?') or pod2usage(2);
    if ($option->{help} && @option_list) {
        print("List of options:\n");
        print("\t");
        print options2string(@_);
        print("\n");
    }
    pod2usage(-exitstatus => 0, -verbose => 2) if $option->{man};

    if ($option->{quiet}) {
        delete $option->{verbose};
    }
}

=item B<hexdump>

  hexdump($buffer);

returns a string with the buffer converted to hex

=cut

sub hexdump(\$) {
    my ($buf) = @_;
    my $r;

    if (!defined $$buf) {
        return undef;
    }

    my $offset=0;
    while ($offset<length $$buf) {
        if (defined($r)) {
            # we have more than one line, so end the previous one first
            $r.="\n";
        }
        my @buf16= split //, substr($$buf,$offset,16);
        $r.=sprintf('%03x: ',$offset);
        for my $i (0..15) {
            if (defined $buf16[$i]) {
                $r.=sprintf('%02x ',ord($buf16[$i]));
            } else {
                $r.=sprintf('   ');
            }
        }
        $r.= "| ";
        for my $i (@buf16) {
            if (defined $i && ord($i)>0x20 && ord($i)<0x7f) {
                $r.=sprintf('%s',$i);
            } else {
                $r.=sprintf(' ');
            }
        }
        $offset+=16;
    }
    return $r;
}

=back

=cut

1;

