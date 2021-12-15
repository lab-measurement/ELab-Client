
use ELab::Client;
use Data::Dumper; 

my $elab = ELab::Client->new(
	host => 'https://elab.somewhere.org/',
	token => '12345',
);

my $e = $elab->get_experiment(1);

print Dumper($e);
print "####################################\n";
print $e->{title}, "\n";
