package Blogolicious::Entry;

use v5.20;
use feature qw( signatures );
no warnings qw( experimental::signatures );

use subs qw();

use Carp qw(croak carp);

our $VERSION = '0.001_01';

=encoding utf8

=head1 NAME

Blogolicious::Entry - all the info about a blog entry

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

This class represents everything Blogolicious knows about a blog
entry.

=over 4

=item new

Create a Blogolicious::Entry object.

	dom           - a Mojo::DOM object representing the response content
	original_url  - the original URL we fetched
	type          - the content generator, if one was found
	server        - the web server string declared by the response
	fetched_with  - the web user agent that fetched the URL

=cut

sub new ( $class, $hash = {} ) {
	my $self = bless $hash, $class;
	$self->init;
	$self;
	}

=item init

Called from C<init>. It determines a possible subclass based on
either the content generator or the hostname. This re-blesses the
object if there's a better subclass.

=cut

sub init ( $self ) {
	my $subclass = $self->_choose_subclass;
	return unless $subclass;

	my $rc = eval "require $subclass; 1";
	unless( $rc ) {
		warn "Could not load $subclass\n";
		return;
		}

	bless $self, $subclass;
	}

sub _choose_subclass ( $self ) {
	if( my $type = $self->type ) {
		   if( $type =~ m/WordPress/i   ) { __PACKAGE__ . '::WordPress'    }
		elsif( $type =~ m/blogger/i     ) { __PACKAGE__ . '::Blogger'      }
		elsif( $type =~ m/bpo-sidecar/i ) { __PACKAGE__ . '::BlogsPerlOrg' }
		elsif( $type =~ m/\btypepad\b/i ) { __PACKAGE__ . '::Typepad' }
		else { carp "Found generator type [$type] but I don't know how to dispatch it\n" }
		}
	elsif( my $subclass = $self->host_to_subclass ) {
		return $subclass
		}
	else {
		return;
		}
	}

=item type

Return the type of blogging engine, such as WordPress or Typepad.

=cut

sub type ( $self ) { $self->{type} }

=item server

Return the web server name. Note that many servers fake or don't
return a server string.

=cut

sub server ( $self ) { $self->{server} }

=item headers

Return the response headers object.

=cut

sub headers ( $self ) { $self->{headers} }

=item original_url

Return the original URL.

=cut

sub original_url ( $self ) { $self->{original_url} }

=item set_original_url

Set the original URL.

=cut

sub set_original_url ( $self, $url ) { $self->{original_url} = $url }

=item host

Return the host of URL. It's lowercased.

=cut

sub host ( $self ) { lc $self->original_url->host }

=item dom

Return the DOM of the found content.

=cut

sub dom ( $self ) { $self->{dom} }


=item host_to_subclass

Return the subclass version of the host

=cut

sub host_to_subclass ( $self ) {
	my $host = $self->host;
	return __PACKAGE__ . '::Tumblr' if $host =~ m/\.tumblr\.com\z/i;
	$host =~ s/\b(\w)/\U$1/g;
	$host =~ s/\.//g;
	join '::', __PACKAGE__, $host;
	}

=item interesting_content_selector

=cut

sub interesting_content_selector ( $self ) {
	croak "Implement interesting_content_selector in a subclass\n";
	}

=item interesting_content

Return the blog entry part of the page, including all of the HTML.

=cut

sub interesting_content ( $self ) {
	return $self->{interesting_content} if $self->{interesting_content};
	my $selector = $self->interesting_content_selector;
# <div class="entry">
	$self->{interesting_content} = eval { $self
		->dom
		->at( $selector )
		->content
		};

	unless( defined $self->{interesting_content} ) {
		carp "Did not extract content with selector [$selector]: $@\n";
		return;
		}

	return $self->{interesting_content};
	}

=item interesting_content_text

Return the blog entry part of the page, without the HTML.

=cut

sub interesting_content_text ( $self ) {
	return $self->{interesting_content_text} if $self->{interesting_content_text};
	state $hr = do {
		require HTML::Restrict;
		HTML::Restrict->new;
		};
	state $rc = require HTML::Entities;

	$self->{interesting_content_text} = $hr->process( $self->interesting_content );
	HTML::Entities::decode_entities( $self->{interesting_content_text} );
	return $self->{interesting_content_text};
	}

=item code_block_selector

Return the CSS Selector to use to extract code blocks.

=cut

sub code_block_selector { 'pre > code' }

=item code_blocks

Return the text in the code blocks as an anonymous array.

=cut

sub code_blocks ( $self ) {
	return $self->{code_blocks} if $self->{code_blocks};

	my $selector = $self->code_block_selector;
# <div class="entry">
	$self->{code_blocks} = [ eval { $self
		->dom
		->find( $selector )
		->map( 'text' )
		->each;
		} ];
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

Copyright © 2016-2021, brian d foy, All Rights Reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

1;
