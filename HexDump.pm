package HC::HexDump;
use warnings;
use strict;
#
# A generic hexdumper
#

sub hexdump(\$) {
    my ($buf,$size) = @_;
    my $r;

    if (!defined $$buf) {
        return undef;
    }
    if (!defined($size)) {
        $size = length $$buf;
    }

    my $offset=0;
    while ($offset<$size) {
        if (defined($r)) {
            # we have more than one line, so end the previous one first
            $r.="\n";
        }
        my $rowlen = 16;
        if ($offset+$rowlen > $size) {
            $rowlen = $size - $offset;
        }

        my @buf16= split //, substr($$buf,$offset,$rowlen);
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
            if (ord($i)>0x20 && ord($i)<0x7f) {
                $r.=sprintf('%s',$i);
            } else {
                $r.=sprintf(' ');
            }
        }
        $offset+=16;
    }
    return $r;
}

1;
