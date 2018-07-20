use Blogolicious;

use v5.10;
use open qw(:std :utf8);

use Mojo::URL;
use Data::Dumper;

my $blogo = Blogolicious->new;

while( <DATA> ) {
	chomp;
	my $url = Mojo::URL->new( $_ );
	my $entry = $blogo->fetch( $url );
	say '-' x 70;
	say "$url -> ", ref $entry;
	my $text = eval { $entry->code_blocks };

	say Dumper( $text );
	}

__END__
https://www.nu42.com/2016/06/msvc-printf-bug-affects-perl.html
