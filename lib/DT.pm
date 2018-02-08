package DT;

use DateTime::Format::Pg;

use strict;
use warnings 'FATAL';
no warnings 'uninitialized';

use Carp qw();
use Scalar::Util qw(looks_like_number);

use parent 'DateTime::Moonpig';

our $VERSION = '0.1.0';

my ($HAVE_PG, $HAVE_ISO);

sub import {
    my ($class, @args) = @_;

    $HAVE_PG = $HAVE_ISO = undef;

    if ( grep /^:?pg$/, @args ) {
        eval { require DateTime::Format::Pg };
        Carp::croak($@) if $@;

        $HAVE_PG = 1;
    }

    if ( not grep /^:?no_iso(?:8601)?$/, @args ) {
        eval { require DateTime::Format::ISO8601 };
        Carp::croak($@) if $@;

        $HAVE_ISO = 1;
    }
}

sub new {
    my $class = shift;

    my $dt;

    if ( @_ == 1 ) {
        # Most probably Unix time, will croak if not
        if ( looks_like_number $_[0] ) {
            $dt = $class->SUPER::new(@_);
        }
        elsif ( not ref $_[0] ) {
            # May be ISO8601(ish) format used by PostgreSQL
            $dt = eval { DateTime::Format::Pg->parse_datetime($_[0]) }
                if $HAVE_PG;

            # May be a real ISO8601 format date/time
            $dt = eval { DateTime::Format::ISO8601->parse_datetime($_[0]) }
                if $HAVE_ISO and not $dt;
        }
    }

    # This will croak
    $dt = DateTime->new(@_) unless $dt;

    # Rebless into DT so our methods work
    return bless $dt, $class;
}

sub unix_time {
    my ($dt) = @_;

    return $dt->epoch;
}

sub pg_timestamp_notz {
    my ($dt) = @_;

    return DateTime::Format::Pg->format_timestamp_without_time_zone($dt);
}

sub pg_timestamp_tz {
    my ($dt) = @_;
    
    return DateTime::Format::Pg->format_timestamptz($dt);
}

1;

__END__
=pod

=begin readme text

DT
==

=end readme

=for readme stop

=head1 NAME

DT - DateTime wrapper that tries hard to DWYM

=head1 SYNOPSIS

    use DT qw(:pg);

    my $dt_now = DT->new(time); # Just works
    my $dt_fh = DT->new('2018-02-06T15:45:00-0500'); # Just works

    my ($pg_time_str) = $pg_dbh->selectrow_array("SELECT now();")
    my $dt_pg = DT->new($pg_time_str); # Also just works

    my $timestamp_notz = $dt_pg->pg_timestamp_notz;
    my $timestamp_tz = $dt->pg->pg_timestamp_tz;

=head1 DESCRIPTION

=for readme continue

DT is a very simple and thin wrapper over DateTime::Moonpig, which
in turn is a wrapper over DateTime. DateTime::Moonpig brings immutability
and saner operator overloading at the cost of cartoonish name but also
lacks date/time parsing capabilities that are badly needed all the time.

There is a myriad of helpful modules on CPAN but all that typing!

=for readme stop

Compare:

    use DateTime;
    my $dt = DateTime->from_epoch(epoch => time);

    use DateTime::Format::Pg;
    my $dt = DateTime::Format::Pg->parse_datetime($timestamp_from_postgres);

    use DateTime::Format::ISO8601;
    my $dt = DateTime::Format::ISO8601->parse_datetime($iso_datetime);

With:

    use DT ':pg';
    my $dt_unix = DT->new(time);
    my $dt_pg = DT->new($timestamp_from_postgres);
    my $dt_iso = DT->new($iso_datetime);

DT constructor will try to Do What You Mean, and if it cannot it will
fall back to default DateTime constructor. Simple.

=head1 METHODS

DT also adds a few useful methods:

=over 4

=item C<unix_time>

A synonym for C<epoch>. No special magic, just easier to remember.

=item C<pg_timestamp_notz>

Format $dt object into a string suitable for PostgreSQL
C<TIMESTAMP WITHOUT TIME ZONE> type column.

=item C<pg_timestamp_tz>

Format $dt object into a string suitable for PostgreSQL
C<TIMESTAMP WITH TIME ZONE> type column.

=back

=for readme continue

=head1 INSTALLATION

To install this module type the following:

    perl Makefile.PL
    make && make test && make install

=for readme stop

=for readme continue

=head1 DEPENDENCIES

L<DateTime::Moonpig> is the parent class for C<DT>. L<DateTime::Format::ISO8601>
is required for parsing ISO8601 date/time formats.

PostgreSQL related methods are optional and depend on L<DateTime::Format::Pg>
being installed.

=for readme stop

=head1 REPORTING BUGS

No doubt there are some. Please post an issue on GitHub (see below)
if you find something. Pull requests are also welcome.

GitHub repository: https://github.com/nohuhu/DT

=for readme continue

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2018 by Alex Tokarev E<lt>nohuhu@cpan.orgE<gt>.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<"perlartistic">.

=for readme stop

=cut

