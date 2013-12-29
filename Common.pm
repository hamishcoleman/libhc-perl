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

sub show_options {
    my @option_list = grep {$_} @_;
    foreach(sort @option_list) {
        # TODO - separate short, long and aliases
        $_="--".$_;
    }
    print join(", ",@option_list);
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
        show_options(@_);
        print("\n");
    }
    pod2usage(-exitstatus => 0, -verbose => 2) if $option->{man};

    if ($option->{quiet}) {
        delete $option->{verbose};
    }
}


=back

=cut

1;

