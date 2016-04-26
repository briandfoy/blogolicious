package Blogolicious;

use v5.20;
use feature qw( signatures );
no warnings qw( experimental::signatures );

use subs qw();

our $VERSION = '0.001_01';

=encoding utf8

=head1 NAME

Blogolicious - Figure out stuff about a blog

=head1 SYNOPSIS

	use Blogolicious;

	my $blogo = Blogolicious->new;

	my $entry = $blogo->fetch( $url );

	# Wordpress, Blogger, whatever
	my $type  = $entry->type;

	# main_content - the interesting part of the blog
	# minus all the wrapper stuff
	my $type  = $entry->main_content;

=head1 DESCRIPTION

Blogolicious aims to reverse engineer a web page representing a
blog entry so you have easy access to its interesting content and
metadata. I want to do this without bothering you with the details
about the blog type and so on.

=over 4

=item new

Returns a Blogolicious object. Use this to control how it works

=cut

sub new ( $class ) {
	my $self = bless {}, $class;
	$self->init;
	$self;
	}

=item init

Setup everything

=cut

sub init ( $self ) {
	$self->_setup_ua;
	}

sub _setup_ua ( $self ) {
	require Mojo::UserAgent;
	$self->{ua} = Mojo::UserAgent->new;
	}

=item ua

Returns the user agent object

=cut

sub ua ( $self ) { $self->{ua} }

=item fetch( URL )

Fetch the URL and return a L<Blogolicious::Entry> object.

=cut

sub fetch ( $self, $url ) {
	my $tx =  $self->ua->get( $url );
	my $entry = $self->_process_response( $tx );
	$entry->set_original_url( $url );
	$entry;
	}

sub _process_response ( $self, $tx ) {
	my $dom = $tx->res->dom;

	my $generator = $self->_parse_generator( $dom );
	my $server    = $self->_parse_server( $tx->res );

	my $entry = Blogolicious::Entry->new( {
		type    => $generator,
		server  => $server,
		headers => $tx->res->headers,
		original_url => $tx->req->url,
		} );
	}

sub _parse_generator ( $self, $dom ) {
	state $rc = require Blogolicious::Entry;
	# <meta name="generator" content="WordPress 4.0" />
	# <meta name=generator content="bpo-sidecar, by the blogs.perl.org team">
	# <meta content='blogger' name='generator'/>
	# <meta name="generator" content="WordPress.com" />
	my $generator = eval {
		$dom
		->find( 'meta[name="generator"]' )
		->map( 'attr' )
		->first
		->{content}
		} // '';
	}

sub _parse_server ( $self, $res ) {
	my $server = $res->headers->header( 'Server' );
	}

=back

=head1 TO DO


=head1 SEE ALSO


=head1 SOURCE AVAILABILITY

This source is in Github (although not yet, really):

	http://github.com/briandfoy/blogolicious/

=head1 AUTHOR

brian d foy, C<< <brian.d.foy@gmail.com> >>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2016, brian d foy, All Rights Reserved.

You may redistribute this under the same terms as Perl itself.

=cut

1;
