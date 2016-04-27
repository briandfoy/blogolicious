use v5.22;
use Test::More 0.98;

my @classes = qw(
	Blogolicious
	Blogolicious::Entry
	);

push @classes, map {
	s|\Alib/||;
	s|\.pm\z||;
	s|/|::|gr;
	} glob "lib/Blogolicious/Entry/*.pm";

say "classes are:\n\t", join( "\n\t", @classes );

foreach my $class ( @classes ) {
	BAIL_OUT( "Bail out! $class did not compile\n" ) unless use_ok( $class );
	}

done_testing();
