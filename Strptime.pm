package HC::Strptime;
use strict;
use warnings;

use DateTime::Format::Strptime;

# A format that /always/ has a timezone - for disambiguating things
my $iso8601_strict_format = DateTime::Format::Strptime->new(
    pattern => "%FT%H:%M:%S%z",
);

sub format {
    return $iso8601_strict_format;
}

1;
