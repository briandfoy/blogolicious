package Blogolicious::Entry::WwwNu42Com;
use Mojo::Base qw(Blogolicious::Entry);

use v5.20;
use feature qw( signatures );
no warnings qw( experimental::signatures );

use subs qw();

use Carp qw(carp);

our $VERSION = '0.001_01';

=encoding utf8

=head1 NAME

Blogolicious::Entry::WwwNu42Com - Handle Sinan's blog entries

=head1 SYNOPSIS


=head1 DESCRIPTION

=over 4

=item interesting_content_selector

=cut

sub interesting_content_selector ( $self ) {
	'article'
	}

=item sha1_fingerprint

=item md5_fingerprint

SSL certificate fingerprints

=cut

sub sha1_fingerprint ( $self ) {
	state $key = "0AD38A30ABC0F0B605B45C727A90819E7FF9DAF4"
	};

sub md5_fingerprint ( $self ) {
	state $key = "D15A7B9730E2694DBE791936A12835C2"
	};

=back

=head1 TO DO


=head1 SEE ALSO


=head1 SOURCE AVAILABILITY

This source is in Github (although not yet, really):

	http://github.com/briandfoy/blogolicious/

=head1 AUTHOR

brian d foy, C<< <brian.d.foy@gmail.com> >>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2016-2018, brian d foy, All Rights Reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

1;
