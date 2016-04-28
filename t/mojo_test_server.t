use v5.20;
use feature qw(signatures);
no warnings qw(experimental::signatures);

use Test::More;
use Test::Mojo;

require 't/mojo_test_server';

my $t = Test::Mojo->new;

$t->get_ok( '/' )->status_is( 200 );

my @tests = qw(
	 Blogolicious::Entry::Wordpress
	 Blogolicious::Entry::Blogger
	 Blogolicious::Entry::Typepad
	 Blogolicious::Entry::WwwNu42Com
	 );

sub check_for_content ( $class ) {
	subtest $class => sub {
		use_ok( $class );
		can_ok( $class, 'interesting_content_selector' );

		my $selector = $class->interesting_content_selector;
		ok( $selector );
		$t
			->get_ok( '/wordpress' )
			->status_is( 200 )
			->element_exists( $selector );
		};
	}

done_testing();
