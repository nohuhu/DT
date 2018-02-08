use Test::More tests => 6;

use strict;
use warnings 'FATAL';

use DT qw(:pg);

my $time = 1518042015;
my $dt = DT->new($time);

my $unix_time = eval { $dt->unix_time };
is $@, '', "unix_time() no exception";
is $unix_time, $time, "unix_time() value";

my $timestamp_notz = eval { $dt->pg_timestamp_notz };
is $@, '', "pg_timestamp_notz() no exception";
is $timestamp_notz, '2018-02-07 22:20:15', "pg_timestamp_notz() value";

my $timestamp_tz = eval { $dt->pg_timestamp_tz };
is $@, '', "pg_timestamp_tz() no exception";
is $timestamp_tz, '2018-02-07 22:20:15+0000', "pg_timestamp_tz() value";

