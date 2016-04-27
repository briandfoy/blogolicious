package Blogolicious;

use v5.20;
use feature qw( signatures );
no warnings qw( experimental::signatures );

use subs qw();

use Carp qw(carp);

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

	# the interesting part of the blog
	# minus all the wrapper stuff
	my $html  = $entry->interesting_content;

	# the interesting part of the blog
	# minus all the wrapper stuff or HTML
	my $text  = $entry->interesting_content_text;

	# the code parts of the blog
	# minus all the wrapper stuff or HTML
	my $array_ref = $entry->code_blocks;


=head1 DESCRIPTION

Blogolicious aims to reverse engineer a web page representing a blog
entry so you have easy access to its interesting content and metadata
no matter the generator. I want to do this without bothering you with
the details about the blog type and so on.

=over 4

=item new

Returns a Blogolicious object. There's no configuration for this yet.

=cut

sub new ( $class ) {
	my $self = bless {}, $class;
	$self->init;
	$self;
	}

=item init

Setup everything, including the web user agents.

=cut

sub init ( $self ) {
	$self->_setup_mojo_ua;
	$self->_setup_curl_ua;
	}

=item mojo_ua

Returns the user agent for L<Mojo::UserAgent>.

=cut

sub _setup_mojo_ua ( $self ) {
	state $rc = require Mojo::UserAgent;
	$self->{mojo_ua} = Mojo::UserAgent->new;
	}
sub mojo_ua ( $self ) { $self->{mojo_ua} }

=item curl_ua

Returns the user agent for L<WWW::Curl::UserAgent>.

=cut

sub _setup_curl_ua ( $self ) {
	state $rc = require WWW::Curl::UserAgent;
	require HTTP::Request;
	$self->{curl_ua} = WWW::Curl::UserAgent->new(
		timeout         => 10000,
		connect_timeout =>  1000,
		);
	}
sub curl_ua ( $self ) { $self->{curl_ua} }

=item fetch( URL )

Fetch the URL and return a L<Blogolicious::Entry> object.

=cut

sub fetch ( $self, $url ) {
	$self->_fetch_with_mojo( $url ) ||
	$self->_fetch_with_curl( $url ) ||

	do {
		carp "Could not fetch $url";
		return;
		};
	}

sub _fetch_with_mojo ( $self, $url ) {
	my $tx =  $self->mojo_ua->get( $url );
	unless( $tx->success ) {
		my $err = $tx->error;
#		carp "$err->{code} response: $err->{message}" if $err->{code};
#		carp "Connection error: $err->{message}";
		return;
		}

	my $entry = $self->_process_mojo_response( $tx );
	$entry->set_original_url( $url );
	$entry;
	}

sub _process_mojo_response ( $self, $tx ) {
	state $rc = require Blogolicious::Entry;
	my $dom = $tx->res->dom;

	my $generator = $self->_parse_generator( $dom ) // '';
	my $server    = $tx->res->headers->header( 'Server' ) // '';

	my $entry = Blogolicious::Entry->new( {
		original_url => $tx->req->url,
		type    => $generator,
		server  => $server,
#		headers => $tx->res->headers,
		feed    => $self->_find_feed( $dom ),
		tx      => $tx,
		dom     => $tx->res->dom,
		fetched_with => 'Mojo::UserAgent',
		} );
	}

sub _fetch_with_curl ( $self, $url ) {
	my $request = HTTP::Request->new( GET => $url->to_string );

	my $error = 0;
	my $entry;
	$self->curl_ua->add_request(
		request    => $request,
		on_success => sub  { my ( $request, $response ) = @_;
			if( $response->is_success ) {
				$entry = $self->_process_curl_response( $request, $response );
				}
			else {
				carp "Could not fetch $url with CURL";
				$error = 1;
				}
			},
		on_failure => sub {my ( $request, $error_msg, $error_desc )=@_;
			say "on_failure: $request, $error_msg, $error_desc";
			$error = 1;
			},
		);

	$self->curl_ua->perform;

	return if $error;
	return $entry;
	}

sub _process_curl_response ( $self, $request, $response ) {
	state $rc = require Blogolicious::Entry;
	my $body = $response->decoded_content;
	my $dom = Mojo::DOM->new( $body );

	my $generator = $self->_parse_generator( $dom );
	my $server    = $response->header( 'Server' );

	my $entry = Blogolicious::Entry->new( {
		original_url => $request->uri,
		type    => $generator,
		server  => $server,
#		headers => $tx->res->headers,
		feed    => $self->_find_feed( $dom ),
		response=> $response,
		request => $request,
		dom     => $dom,
		fetched_with => 'WWW::Curl::UserAgent',
		} );
	}

sub _parse_generator ( $self, $dom ) {
	# <meta name="generator" content="WordPress 4.0" />
	# <meta name=generator content="bpo-sidecar, by the blogs.perl.org team">
	# <meta content='blogger' name='generator'/>
	# <meta name="generator" content="WordPress.com" />
	# <meta name="generator" content="http://www.typepad.com/" />
	my $generator = eval {
		$dom
		->find( 'meta[name="generator"]' )
		->map( 'attr' )
		->first
		->{content}
		} // '';
	}

# <link rel="pingback" href="//www.learning-perl.com/xmlrpc.php" />
# <link rel="alternate" type="application/rss+xml" title="Learning Perl &raquo; Comments Feed" href="//www.learning-perl.com/comments/feed/" />


sub _find_feed ( $self, $dom ) {
	my $link = eval {
		$dom
		->find( 'link[type="application/rss+xml"]' )
		->map( 'attr' )
		->first
		->{href}
		} // '';
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
