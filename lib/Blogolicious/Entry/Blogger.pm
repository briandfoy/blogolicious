package Blogolicious::Entry::Blogger;
use Mojo::Base qw(Blogolicious::Entry);

use v5.20;
use feature qw( signatures );
no warnings qw( experimental::signatures );

use subs qw();

use Carp qw(carp);

our $VERSION = '0.001_01';

=encoding utf8

=head1 NAME

Blogolicious::Entry::Blogger - Handle Blogger blog entries

=head1 SYNOPSIS


=head1 DESCRIPTION

=over 4

=item interesting_content_selector

=cut

sub interesting_content_selector ( $self ) {
	'div.entry-content'
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

Copyright © 2016-2025, brian d foy, All Rights Reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

1;
