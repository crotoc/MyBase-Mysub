#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'MyBase::Mysub' ) || print "Bail out!\n";
}

diag( "Testing MyBase::Mysub $MyBase::Mysub::VERSION, Perl $], $^X" );
