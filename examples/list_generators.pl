use Blogolicious;

use v5.10;

use Mojo::URL;

my $blogo = Blogolicious->new;

while( <DATA> ) {
	chomp;
	my $url = Mojo::URL->new( $_ );
	$url->path( '/' );
	$url->query( '' );
	my $entry = $blogo->fetch( $url );
	say "$url -> ", $entry->type, ' -> ', $entry->server, ' -> ', ref $entry;
	}

__END__
http://cpanpr.tumblr.com/rss
https://rjbs.manxome.org/rubric/entries/tags/perl?format=rss
http://www.dagolden.com/index.php/feed/
http://www.learning-perl.com/feed/
http://www.intermediateperl.com/feed/
http://www.masteringperl.org/feed/
http://www.effectiveperlprogramming.com/feed/
http://perltricks.com/feed/rss
http://feeds.feedburner.com/szabgab?format=xml
http://blog.twoshortplanks.com/feed/
http://blog.laufeyjarson.com/feed/
https://andreeapirvulescu.wordpress.com/feed/
https://p6weekly.wordpress.com/feed/
http://perlmaven.com/atom
http://neilb.org/atom.xml
http://jjnapiorkowski.typepad.com/modern-perl/atom.xml
http://perl.bearcircle.net/feeds/posts/default
http://reneeb-perlblog.blogspot.com/atom.xml
https://blog.afoolishmanifesto.com/index.xml
http://blogs.perl.org/atom.xml
https://perlancar.wordpress.com/feed/
https://www.nu42.com/nu42.atom.xml
http://www.wumpus-cave.net/feed/
http://feeds.feedburner.com/PerlHacks
http://techblog.babyl.ca/feed/atom
http://blog.plover.com/prog/index.atom
http://blog.urth.org/feed/
https://6guts.wordpress.com/feed/
https://perl6advent.wordpress.com/feed/atom/
