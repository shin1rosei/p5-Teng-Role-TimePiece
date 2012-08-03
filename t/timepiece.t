use strict;
use Test::More;
use Time::Piece;
{
    package t::Teng;

    use parent 'Teng';
    use Any::Moose;
    with 'Teng::Role::TimePiece';

    no warnings qw(once);
    $Teng::Role::TimePiece::STRPTIME_FORMAT = '%Y-%m-%dT%H:%M:%S';

    package t::Teng::Schema;
    use Teng::Schema::Declare;

    table {
        name 'foo';
        pk 'id';
        columns qw(id played_at);
    };
}

my $m = new_ok 't::Teng', [ connect_info => [ 'dbi:SQLite:', '', '' ] ];

$_->Teng::do(
    'CREATE TABLE foo ( id INT AUTO_INCREMENT PRIMARY KEY, played_at DATETIME )')
    for $m;

my $time = localtime;
$m->insert(foo => { id => 1, played_at => $time});

my $r = $m->single('foo');

ok $r;
is ref $r->played_at, 'Time::Piece';

done_testing;
