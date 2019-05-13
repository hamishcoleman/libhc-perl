package HC::Base64Sortable;
use warnings;
use strict;
#
# Base64 with a different charset - one that makes encoded fragments easily
# sort into the sort-order of the original un-encoded data
#

# convert the names into a more asciibetical sort order
# dont use chars forbidden to DOS: ":"
# dont use chars I want to use for separators: ",."
# start with 0-9 for simplicity
# dont use shell metachars: ";<>?[]"
# available:  [0-9]=@[A-Z]^_[a-z]~
# the Caret gets quoted by the shell, so dont use that

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(encode_base64sortable);

use MIME::Base64 qw(encode_base64url);

sub encode_base64sortable {
    my $e = encode_base64url(shift, "");
    $e =~ y/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789\-_/0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~/;
    return $e;
}


1;
