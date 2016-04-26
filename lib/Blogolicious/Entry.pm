package Blogolicious::Entry;

use v5.20;
use feature qw( signatures );
no warnings qw( experimental::signatures );

use subs qw();

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

Returns a Blogolicious::Entry object.

=cut

sub new ( $class, $hash = {} ) {
	my $self = bless $hash, $class;
	$self->init;
	$self;
	}

=item init

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
		}
	elsif( my $subclass = $self->host_to_subclass ) {
		return $subclass
		}
	else {
		return;
		}

	}

=item type

Return the type of blogging engine.

=cut

sub type ( $self ) { $self->{type} }

=item server

Return the server name. Note that many servers fake or don't
return a server string.

=cut

sub server ( $self ) { $self->{server} }

=item headers

Return the response headers object

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

Return the host of URL

=cut

sub host ( $self ) { lc $self->original_url->host }

=item host

Return the subclass version of the host

=cut

sub host_to_subclass ( $self ) {
	my $host = $self->host; say "===Host is $host";
	return __PACKAGE__ . '::Tumblr' if $host =~ m/\.tumblr\.com\z/i;
	$host =~ s/\b(\w)/\U$1/g;
	$host =~ s/\.//g;
	join '::', __PACKAGE__, $host;
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