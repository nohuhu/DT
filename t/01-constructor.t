use Test::More tests => 11;

use strict;
use warnings 'FATAL';

use_ok 'DT';

# Should understand unix time with no import
my $time_now = time;
my $dt = eval { DT->new($time_now) };
is $@, '', "new unix time no exception";
is $dt->epoch, $time_now, "epoch() value";

my $dt_iso = eval { DT->new('2018-02-07T21:22:09Z') };
is $@, '', "new iso timestamp no exception";
is $dt_iso->epoch, 1518038529, "iso timestamp value";

# TODO Better tests for when there's no DateTime::Format::Pg present
eval { DT->import(':pg') };
is $@, '', "import :pg no exception";

my $dt_pg = eval { DT->new('2018-02-07 21:22:09.58343-08') };
is $@, '', "new with timestamp_tz no exception";
is $dt_pg->epoch, 1518067329, "pg timestamp_tz value";

eval { DT->import(':no_iso') };
is $@, '', "import :no_iso no exception";

$dt_iso = eval { DT->new('2018-02-07T21:22:09Z') };
like $@, qr/^Expected a hash or hash reference/, "new :no_iso exception";

# Pg is not enabled by default
$dt_pg = eval { DT->new('2018-02-07 21:22:09.58343-08') };
like $@, qr/^Expected a hash or hash reference/, "new no :pg exception";

