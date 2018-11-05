use strict;
use warnings;
use Test::More;
use Test::Quattor;
use NCM::Component::metaconfig;
use CAF::Object;
use Readonly;
use CAF::ServiceActions;

use Config::Tiny;

Readonly my $STR => "An arbitrary string";


=pod

=head1 DESCRIPTION

Test that a config file can be generated by this component, using
Config::Tiny to render simple configuration files.

The expected format is either

    key=value

or

    [section]
    key=value

Where sections are nlists in the component's schema.

=head1 TESTS

=cut


my $cmp = NCM::Component::metaconfig->new('metaconfig');
my $sa = CAF::ServiceActions->new(log => $cmp);

my $cfg = {
       owner => 'root',
       group => 'root',
       mode => 0644,
       contents => {
           a => 1,
           b => 2,
           section => { s => 1 }
       },
       module => "tiny",
      };

$cmp->handle_service("/foo/bar", $cfg, undef, $sa);

my $fh = get_file("/foo/bar");
isa_ok($fh, "CAF::FileWriter", "Correct class");

=pod

=head2 Simple method execution.

We expect just C<key=value> lines

=cut

like("$fh", qr{a=1\nb=2\n},
   "Values are rendered properly");


=head2 Files with sections

They should appear when there are nlists (hashes) inside the
structure.

=cut

like("$fh", qr{\[section\]\ns=1\n},
   "Sections in the file are rendered properly");

done_testing();
