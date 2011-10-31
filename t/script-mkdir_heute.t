use strict;
use File::Spec;
use Probe::Perl;
use Test::More;
use Symbol 'gensym';
use IPC::Open3;

plan tests => 5;

my $perl = Probe::Perl->find_perl_interpreter;
my $script = File::Spec->catfile(qw/. mkdir_heute/); 

my $in  = gensym;
my $out = gensym;
my $err = gensym;

eval {
	local $SIG{ALRM} = sub { die "not completed\n" };
	alarm(30);   

	my $pid = open3($in, $out, $err, $script);
	print $in "q\n";
	is(<$out>,'.',"end with (q)uit");
	waitpid($pid, 0);

	$pid = open3($in, $out, $err, $script);
	close $in;
	is(<$out>,'.',"EOF in Input");
	waitpid($pid, 0);

	$pid = open3($in, $out, $err, $script, '-b', 't/base');
	print $in "+ something\n";
	my $dir = <$out>;
	waitpid($pid, 0);
	like($dir,qr(^t/base/),"directory below basedir");
	ok(-d $dir,'new directory created');
};
unlike($@, qr/^not completed$/, "All tests completed in time");

