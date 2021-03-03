use 5.006;
use strict;
use warnings;
use Module::Build;
Module::Build->VERSION('0.4004');

my $builder = Module::Build->new(
    module_name         => 'MyBase::Mysub',
    license             => 'artistic_2',
    dist_author         => q{Rui Chen <crotoc@gmail.com>},
    dist_version_from   => 'lib/MyBase/Mysub.pm',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => '0.4004',
    },
    test_requires => {
        'Test::More' => '0',
    },
    requires => {
        'DBI'              => '1.643',
        'Data::Dumper' => '2.1',
        'List::Uniq' => '0.23',
	    'Array::Utils' => '0.5',
	    "Env::Modify" => '0',
	    'Switch' => '0'

        #'Foo::Bar::Module' => '5.0401',
    },
    add_to_cleanup     => [ 'MyBase-Mysub-*' ],
);

$builder->create_build_script();
