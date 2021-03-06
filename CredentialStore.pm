package HC::CredentialStore;
use warnings;
use strict;
#
# Simple module to load a file with credentials and allow lookups
#
# The credential file is "key username password" with whitespace seperators
# and ignoring lines starting with hash.  Fields may contain hash chars as
# long as the line does not start with one.
#
# whitespace at the beginning and end of the line will be removed and fields
# cannot contain whitespace (Please dont use whitespace in your usernames and
# passwords!)
#
# If both the username and password field are empty then the most recently
# seen username and password are used.  This will die with an error at the
# start of the file
#

use IO::File;
use File::Glob;

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;

    my $filename = shift;
    $self->_findfile($filename);

    return $self;
}

# Consider a number of possible locations for the credfile and try loading
# each one
sub _findfile {
    my $self = shift;
    my $filename = shift;

    # first, try any explicit file from the commandline
    if (defined($filename) && -e $filename) {
        return $self->_readfile($filename);
    }

    # next, try environment variable
    if (defined($ENV{'CREDFILE'}) && -e $ENV{'CREDFILE'}) {
        return $self->_readfile($ENV{'CREDFILE'});
    }

    # finally, try a generica hardcoded location
    my $dotfile = File::Glob::bsd_glob('~/.credfile');
    if ( -e $dotfile ) {
        return $self->_readfile($dotfile);
    }

    # if nothing found, we simply end up with an empty dictionary
    return $self;
}

sub _readfile {
    my ($self,$filename) = @_;

    my $fh = IO::File->new($filename,"r");
    return undef if (!defined($fh));

    my ($prev_username,$prev_password);

    while (<$fh>) {
        chomp;
        s/^\s+//;       # delete whitespace at the start of the line
        s/^#.*//;       # delete any line starting with a comment char
        next if (!$_);  # skip if the line is empty

        my ($key,$username,$password) = split(/\s+/);

        if (!defined($username)) {
            # If we have no username, then we must have no password

            # use the previous ones
            $username=$prev_username;
            $password=$prev_password;
        }

        if (!defined($username) || !defined($password)) {
            # catch the case where we dont have any previous values
            die("Need username and password");
        }

        $self->{db}{$key}{username}=$username;
        $self->{db}{$key}{password}=$password;
        $prev_username=$username;
        $prev_password=$password;
    }
    return $self;
}

sub lookup_username {
    my ($self,$key) = @_;
    return $self->{db}{$key}{username};
}

sub lookup_password {
    my ($self,$key) = @_;
    return $self->{db}{$key}{password};
}

sub lookup {
    my ($self,$key) = @_;
    return ($self->lookup_username($key),$self->lookup_password($key));
}

1;
