use Blogolicious;

use v5.10;
use open qw(:std :utf8);

use Mojo::URL;

my $blogo = Blogolicious->new;

while( <DATA> ) {
	chomp;
	my $url = Mojo::URL->new( $_ );
	my $entry = $blogo->fetch( $url );
	say '-' x 70;
	say "$url -> ", ref $entry;
	my $body = eval { $entry->interesting_content };
	if( $@ ) {
		say "Error: $@";
		}
	if( $body ) {
		$body =~ s/\s+/ /g;
		say substr $body, 0, 73;
		}
	}

__END__
http://www.learning-perl.com/
http://www.intermediateperl.com/
http://www.masteringperl.org/
http://www.effectiveperlprogramming.com/
http://perltricks.com/
https://blog.twoshortplanks.com/2015/02/28/the-role-of-critique/
http://blog.laufeyjarson.com/
https://p6weekly.wordpress.com/
http://perlmaven.com/refactoring-dancer2-using-before-hook
http://neilb.org/2016/02/13/it-takes-a-community.html
http://jjnapiorkowski.typepad.com/
http://perl.bearcircle.net/
http://reneeb-perlblog.blogspot.com/
https://blog.afoolishmanifesto.com/posts/python-taking-the-good-with-the-bad/
http://blogs.perl.org/
https://perlancar.wordpress.com/
https://www.nu42.com/2016/04/djia-crystal-ball.html
http://www.wumpus-cave.net/
http://techblog.babyl.ca/entry/taskwarrior
http://blog.plover.com/
http://blog.urth.org/
https://6guts.wordpress.com/
https://perl6advent.wordpress.com/
