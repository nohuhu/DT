use Test::More;

use DT;
eval "use DateTime::Format::Pg";

if ( $@ ) {
    plan skip_all => "DateTime::Format::Pg is required";
    exit 0;
}

plan tests => 3;

eval { DT->import(':pg') };
is $@, '', "import :pg no exception";

my $dt_pg = eval { DT->new('2018-02-07 21:22:09.58343-08') };
is $@, '', "new with timestamp_tz no exception";
is $dt_pg->epoch, 1518067329, "pg timestamp_tz value";
