#-----------------------------------------------------------------
#
# BioPerl module MyBase::Bio::Root::Exception
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Steve Chervitz <sac@bioperl.org>
#
# You may distribute this module under the same terms as perl itself
#-----------------------------------------------------------------

=head1 NAME

MyBase::Bio::Root::Exception - Generic exception objects for Bioperl

=head1 SYNOPSIS

=head2 Throwing exceptions using L<Error.pm throw|Error::throw>:

    use MyBase::Bio::Root::Exception;
    use Error;

    # Set Error::Debug to include stack trace data in the error messages
    $Error::Debug = 1;

    $file = shift;
    open (IN, $file) ||
	    throw MyBase::Bio::Root::FileOpenException ( "Can't open file $file for reading", $!);

=head2 Throwing exceptions using L<Bioperl throw|MyBase::Bio::Root::Root/throw>:

     # Here we have an object that ISA MyBase::Bio::Root::Root, so it inherits throw().

     open (IN, $file) || 
                $object->throw(-class => 'MyBase::Bio::Root::FileOpenException',
                               -text => "Can't open file $file for reading",
                               -value => $!);

=head2 Catching and handling exceptions using L<Error.pm try|Error/try>:

    use MyBase::Bio::Root::Exception;
    use Error qw(:try);

    # Note that we need to import the 'try' tag from Error.pm

    # Set Error::Debug to include stack trace data in the error messages
    $Error::Debug = 1;

    $file = shift;
    try {
        open (IN, $file) ||
	    throw MyBase::Bio::Root::FileOpenException ( "Can't open file $file for reading", $!);
    }
    catch MyBase::Bio::Root::FileOpenException with {
        my $err = shift;
        print STDERR "Using default input file: $default_file\n";
        open (IN, $default_file) || die "Can't open $default_file";
    }
    otherwise {
        my $err = shift;
    	print STDERR "An unexpected exception occurred: \n$err";

	# By placing an the error object reference within double quotes,
	# you're invoking its stringify() method.
    }
   finally {
       # Any code that you want to execute regardless of whether or not
       # an exception occurred.
   };  
   # the ending semicolon is essential!


=head2 Defining a new Exception type as a subclass of MyBase::Bio::Root::Exception:

    @MyBase::Bio::TestException::ISA = qw( MyBase::Bio::Root::Exception );

=head1 DESCRIPTION

=head2 Exceptions defined in L<MyBase::Bio::Root::Exception>

These are generic exceptions for typical problem situations that could arise
in any module or script. 

=over 8

=item MyBase::Bio::Root::Exception()

=item MyBase::Bio::Root::NotImplemented()

=item MyBase::Bio::Root::IOException()

=item MyBase::Bio::Root::FileOpenException()

=item MyBase::Bio::Root::SystemException()

=item MyBase::Bio::Root::BadParameter()

=item MyBase::Bio::Root::OutOfRange()

=item MyBase::Bio::Root::NoSuchThing()

=back

Using defined exception classes like these is a good idea because it
indicates the basic nature of what went wrong in a convenient,
computable way.

If there is a type of exception that you want to throw
that is not covered by the classes listed above, it is easy to define
a new one that fits your needs. Just write a line like the following
in your module or script where you want to use it (or put it somewhere
that is accessible to your code):

    @NoCanDoException::ISA = qw( MyBase::Bio::Root::Exception );

All of the exceptions defined in this module inherit from a common
base class exception, MyBase::Bio::Root::Exception. This allows a user to
write a handler for all Bioperl-derived exceptions as follows:

           use MyBase::Bio::Whatever;
           use Error qw(:try);

           try {
                # some code that depends on Bioperl
           }
           catch MyBase::Bio::Root::Exception with {
               my $err = shift;
               print "A Bioperl exception occurred:\n$err\n";
           };

So if you do create your own exceptions, just be sure they inherit
from MyBase::Bio::Root::Exception directly, or indirectly by inheriting from a
MyBase::Bio::Root::Exception subclass.

The exceptions in MyBase::Bio::Root::Exception are extensions of Graham Barr's
L<Error> module available from CPAN.  Despite this dependency, the
L<MyBase::Bio::Root::Exception> module does not explicitly C<require Error>.
This permits MyBase::Bio::Root::Exception to be loaded even when
Error.pm is not available.

=head2 Throwing exceptions within Bioperl modules

Error.pm is not part of the Bioperl distibution, and may not be
present within  any given perl installation. So, when you want to 
throw an exception in a Bioperl module, the safe way to throw it
is to use L<MyBase::Bio::Root::Root/throw> which can use Error.pm 
when it's available. See documentation in MyBase::Bio::Root::Root for details.

=head1 SEE ALSO

See the C<examples/exceptions> directory of the Bioperl distribution for 
working demo code.

L<MyBase::Bio::Root::Root/throw> for information about throwing 
L<MyBase::Bio::Root::Exception>-based exceptions.

L<Error> (available from CPAN, author: GBARR)

Error.pm is helping to guide the design of exception handling in Perl 6. 
See these RFC's: 

     http://dev.perl.org/rfc/63.pod 

     http://dev.perl.org/rfc/88.pod


=head1 AUTHOR 

Steve Chervitz E<lt>sac@bioperl.orgE<gt>

=head1 COPYRIGHT

Copyright (c) 2001 Steve Chervitz. All Rights Reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 DISCLAIMER

This software is provided "as is" without warranty of any kind.

=head1 EXCEPTIONS

=cut

# Define some generic exceptions.'

package MyBase::Bio::Root::Exception;
use MyBase::Bio::Root::Version;

use strict;

my $debug = $Error::Debug;  # Prevents the "used only once" warning.
my $DEFAULT_VALUE = "__DUMMY__";  # Permits eval{} based handlers to work

=head2 L<MyBase::Bio::Root::Exception>

 Purpose : A generic base class for all BioPerl exceptions.
           By including a "catch MyBase::Bio::Root::Exception" block, you
           should be able to trap all BioPerl exceptions.
 Example : throw MyBase::Bio::Root::Exception("A generic exception", $!);

=cut

#---------------------------------------------------------
@MyBase::Bio::Root::Exception::ISA = qw( Error );
#---------------------------------------------------------

=head1 Methods defined by MyBase::Bio::Root::Exception

=head2 new

 Purpose : Guarantees that -value is set properly before
           calling Error::new().

 Arguments: key-value style arguments same as for Error::new()

     You can also specify plain arguments as ($message, $value)
     where $value is optional.

     -value, if defined, must be non-zero and not an empty string 
     in order for eval{}-based exception handlers to work. 
     These require that if($@) evaluates to true, which will not 
     be the case if the Error has no value (Error overloads 
     numeric operations to the Error::value() method).

     It is OK to create MyBase::Bio::Root::Exception objects without
     specifying -value. In this case, an invisible dummy value is used.

     If you happen to specify a -value of zero (0), it will
     be replaced by the string "The number zero (0)".

     If you happen to specify a -value of empty string (""), it will
     be replaced by the string "An empty string ("")".

=cut

sub new {
    my ($class, @args) = @_; 
    my ($value, %params);
    if( @args % 2 == 0 && $args[0] =~ /^-/) {
        %params = @args;
        $value = $params{'-value'};
    }
    else {
        $params{-text} = $args[0];
        $value = $args[1];
    }

    if( defined $value ) {
        $value = "The number zero (0)" if $value =~ /^\d+$/ && $value == 0;
        $value = "An empty string (\"\")" if $value eq "";
    }
    else {
	$value ||= $DEFAULT_VALUE;
    }
    $params{-value} = $value;

    my $self = $class->SUPER::new( %params );
    return $self;
}

=head2 pretty_format()

 Purpose : Get a nicely formatted string containing information about the 
           exception. Format is similar to that produced by 
           MyBase::Bio::Root::Root::throw(), with the addition of the name of
           the exception class in the EXCEPTION line and some other
           data available via the Error object.
 Example : print $error->pretty_format;

=cut

sub pretty_format {
    my $self = shift;
    my $msg = $self->text;
    my $stack = '';
    if( $Error::Debug ) {
      $stack = $self->_reformat_stacktrace();
    }
    my $value_string = $self->value ne $DEFAULT_VALUE ? "VALUE: ".$self->value."\n" : "";
    my $class = ref($self);

    my $title = "------------- EXCEPTION: $class -------------";
    my $footer = "\n" . '-' x CORE::length($title);
    my $out = "\n$title\n" .
       "MSG: $msg\n". $value_string. $stack. $footer . "\n";
    return $out;
}


# Reformatting of the stack performed by  _reformat_stacktrace:
#   1. Shift the file:line data in line i to line i+1.
#   2. change xxx::__ANON__() to "try{} block"
#   3. skip the "require" and "Error::subs::try" stack entries (boring)
# This means that the first line in the stack won't have any file:line data
# But this isn't a big issue since it's for a MyBase::Bio::Root::-based method 
# that doesn't vary from exception to exception.

sub _reformat_stacktrace {
    my $self = shift;
    my $msg = $self->text;
    my $stack = $self->stacktrace();
    $stack =~ s/\Q$msg//;
    my @stack = split( /\n/, $stack);
    my @new_stack = ();
    my ($method, $file, $linenum, $prev_file, $prev_linenum);
    my $stack_count = 0;
    foreach my $i( 0..$#stack ) {
        # print "STACK-ORIG: $stack[$i]\n";
        if( ($stack[$i] =~ /^\s*([^(]+)\s*\(.*\) called at (\S+) line (\d+)/) ||
             ($stack[$i] =~ /^\s*(require 0) called at (\S+) line (\d+)/)) {
            ($method, $file, $linenum) = ($1, $2, $3);
            $stack_count++;
        }
        else{
            next;
        }
        if( $stack_count == 1 ) {
            push @new_stack, "STACK: $method";
            ($prev_file, $prev_linenum) = ($file, $linenum);
            next;
        }

        if( $method =~ /__ANON__/ ) {
            $method = "try{} block";
        }
        if( ($method =~ /^require/ and $file =~ /Error\.pm/ ) ||
            ($method =~ /^Error::subs::try/ ) )   {
            last;
        }
        push @new_stack, "STACK: $method $prev_file:$prev_linenum";
        ($prev_file, $prev_linenum) = ($file, $linenum);
    }
    push @new_stack, "STACK: $prev_file:$prev_linenum";

    return join "\n", @new_stack;
}

=head2 stringify()

 Purpose : Overrides Error::stringify() to call pretty_format(). 
           This is called automatically when an exception object 
           is placed between double quotes.
 Example : catch MyBase::Bio::Root::Exception with {
              my $error = shift;
              print "$error";
           }

See Also: L<pretty_format()|pretty_format>

=cut

sub stringify {
    my ($self, @args) = @_;
    return $self->pretty_format( @args );
}

=head1 Subclasses of MyBase::Bio::Root::Exception 

=head2 L<MyBase::Bio::Root::NotImplemented>

 Purpose : Indicates that a method has not been implemented.
 Example : throw MyBase::Bio::Root::NotImplemented( 
               -text   => "Method \"foo\" not implemented in module FooBar.",
               -value  => "foo" );

=cut

#---------------------------------------------------------
@MyBase::Bio::Root::NotImplemented::ISA = qw( MyBase::Bio::Root::Exception );
#---------------------------------------------------------

=head2 L<MyBase::Bio::Root::IOException>

 Purpose : Indicates that some input/output-related trouble has occurred.
 Example : throw MyBase::Bio::Root::IOException( 
               -text   => "Can't save data to file $file.",
	       -value  => $! );

=cut

#---------------------------------------------------------
@MyBase::Bio::Root::IOException::ISA = qw( MyBase::Bio::Root::Exception );
#---------------------------------------------------------


=head2 L<MyBase::Bio::Root::FileOpenException>

 Purpose : Indicates that a file could not be opened.
 Example : throw MyBase::Bio::Root::FileOpenException( 
               -text   => "Can't open file $file for reading.",
	       -value  => $! );

=cut

#---------------------------------------------------------
@MyBase::Bio::Root::FileOpenException::ISA = qw( MyBase::Bio::Root::IOException );
#---------------------------------------------------------


=head2 L<MyBase::Bio::Root::SystemException>

 Purpose : Indicates that a system call failed.
 Example : unlink($file) or throw MyBase::Bio::Root::SystemException( 
               -text   => "Can't unlink file $file.",
	       -value  => $! );

=cut

#---------------------------------------------------------
@MyBase::Bio::Root::SystemException::ISA = qw( MyBase::Bio::Root::Exception );
#---------------------------------------------------------


=head2 L<MyBase::Bio::Root::BadParameter>

 Purpose : Indicates that one or more parameters supplied to a method 
           are invalid, unspecified, or conflicting.
 Example : throw MyBase::Bio::Root::BadParameter( 
               -text   => "Required parameter \"-foo\" was not specified",
               -value  => "-foo" );

=cut

#---------------------------------------------------------
@MyBase::Bio::Root::BadParameter::ISA = qw( MyBase::Bio::Root::Exception );
#---------------------------------------------------------


=head2 L<MyBase::Bio::Root::OutOfRange>

 Purpose : Indicates that a specified (start,end) range or 
           an index to an array is outside the permitted range.
 Example : throw MyBase::Bio::Root::OutOfRange( 
               -text   => "Start coordinate ($start) cannot be less than zero.",
               -value  => $start  );

=cut

#---------------------------------------------------------
@MyBase::Bio::Root::OutOfRange::ISA = qw( MyBase::Bio::Root::Exception );
#---------------------------------------------------------


=head2 L<MyBase::Bio::Root::NoSuchThing>

 Purpose : Indicates that a requested thing cannot be located 
           and therefore could possibly be bogus.
 Example : throw MyBase::Bio::Root::NoSuchThing( 
               -text   => "Accession M000001 could not be found.",
               -value  => "M000001"  );

=cut

#---------------------------------------------------------
@MyBase::Bio::Root::NoSuchThing::ISA = qw( MyBase::Bio::Root::Exception );
#---------------------------------------------------------


1;

