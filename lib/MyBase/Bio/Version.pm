#
# BioPerl module for MyBase::Bio::Root::Version
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Aaron Mackey <amackey@virginia.edu>
#
# Copyright Aaron Mackey
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

MyBase::Bio::Root::Version - provide global, distribution-level versioning

=head1 SYNOPSIS

  package MyBase::Bio::Tools::NiftyFeature;
  require MyBase::Bio::Root::RootI;


  # later, in client code:
  package main;
  use MyBase::Bio::Tools::NiftyFeature 3.14;


  ## alternative usage: NiftyFeature defines own $VERSION:
  package MyBase::Bio::Tools::NiftyFeature;
  my $VERSION = 9.8;

  # later in client code:
  package main;

  # ensure we're using an up-to-date BioPerl distribution
  use MyBase::Bio::Perl 3.14;

  # NiftyFeature has its own versioning scheme:
  use MyBase::Bio::Tools::NiftyFeature 9.8;

=head1 DESCRIPTION

This module provides a mechanism by which all other BioPerl modules
can share the same $VERSION, without manually synchronizing each file.

MyBase::Bio::Root::RootI itself uses this module, so any module that directly
(or indirectly) uses MyBase::Bio::Root::RootI will get a global $VERSION
variable set if it's not already.


=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

=head2 Support 

Please direct usage questions or support issues to the mailing list:

I<bioperl-l@bioperl.org>

rather than to the module maintainer directly. Many experienced and 
reponsive experts will be able look at the problem and quickly 
address it. Please include a thorough description of the problem 
with code and data examples if at all possible.

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution.  Bug reports can be submitted via the
web:

  https://redmine.open-bio.org/projects/bioperl/

=head1 AUTHOR - Aaron Mackey

Email amackey@virginia.edu

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...


package MyBase::Bio::Root::Version;
use strict;

our $VERSION = '1.006923'; # pre-1.7
$VERSION = eval $VERSION;

sub import {
    # try to handle multiple levels of inheritance:
    my $i = 0;
    my $pkg = caller($i);
    no strict 'refs';
    while ($pkg) {
	if ($pkg =~ m/^MyBase::Bio::/o &&
	    not defined ${$pkg . "::VERSION"}) {
	    ${$pkg . "::VERSION"} = $VERSION;
	}
        $pkg = caller(++$i);
    }
}

1;
__END__
