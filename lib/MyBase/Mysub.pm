package MyBase::Mysub;
use strict;
#use threads;
use warnings;
use base qw(MyBase::Bio::Root::Root);
use Data::Dumper;
our @EXPORT_OK=qw(new);
use DBI;
use List::Uniq ':all';
use Array::Utils ':all';

=head1 NAME

MyBase::Mysub - The great new MyBase::Mysub!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use test;

    my $foo = test->new();
        ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut


sub new{
    my $class = shift;
    #print $class;
    my $self = $class->SUPER::new();
    bless $self, $class;
    return $self;
}

sub test_file_exist{
    my $self = shift;
    my @file = @_;
    my $flag;
    foreach (@file){
	if (-e $_){ print "TEST: $_ existed\n"; $flag=1;}
	else {print "TEST: $_ not existed\n";return 0;}
    }
    return $flag;
}

sub cmd_go{
   my ($self,$cmd,$fh) =@_;
   
   print "CMD: $cmd\n";
   system("$cmd");
}


sub sendmail()
{
    my ($class,$command_line,$email) = @_;
    
    
    if ($email)
    {
	my $from="vmpsched\@vmpsched.vampire";
	my $to="$email";
	my $subject="An error";

	my $sendmailpath="/usr/sbin/sendmail";

	my $message = "An error has occurred processing your job, see below.\n$command_line\n\nfrom cgg lab\n";

	open (SENDMAIL, "| $sendmailpath -t") or die "Cannot open $sendmailpath: $!";

	print SENDMAIL "Subject: $subject\n";
	print SENDMAIL "From: $from\n";
	print SENDMAIL "To: $to\n\n";

	print SENDMAIL "$message";

	close (SENDMAIL);
    }
}

sub setMethod{
    my ($self,%args)=@_;
    my @keys=keys %args;
    ##print Dumper %args;
    $self->_set_from_args(\%args,
     			  -methods => \@keys,
     			  -create => 1
     	); 
}


sub getStrByKeys
{
    my ($self,$keys) = @_;
    my @str;
    map {exists $self->{"_$_"}?push @str,$self->{"_$_"}:push @str,"";}  @$keys;
    return join ";",@str;
}

sub getStrByKeysSep
{
    my ($self,$keys,$sep) = @_;
    $sep=";",if !$sep;
    my @str;
    map {exists $self->{"_$_"}?push @str,$self->{"_$_"}:push @str,"";}  @$keys;
    #print Dumper(scalar(@str));
    return join $sep,@str;
}


sub getArrayByKeys
{
    my ($self,$keys) = @_;
    my @str;
    map {exists $self->{"_$_"}?push @str,$self->{"_$_"}:push @str,"";} @$keys;
    return \@str;
}

sub getTabByKeys
{
    my ($self,$keys) = @_;
    my @str;
    map {push @str,$self->{"_$_"}} @$keys;
    return join "\t",@str;


}

sub counting{
    my ($self,$file) = @_;
    print "\nSUBSTEP: Counting\n";
    if($self->test_file_exist($file)){
	my $cmd="wc -l $file";
	$self->cmd_go($cmd);
    }
    else{ $self->throw("No such file;")}
    print "done\n\n";
} 

sub get{
    my ($self,$str)=@_;
    return $self->{"_$str"};
}


sub opt_print{
    my ($self,$hash,$fh,$fmt_hash)= @_;
    $fh=*STDOUT,if !$fh;
    if(!$fmt_hash){
	$fmt_hash->{a} = 10 if !defined $fmt_hash->{a};
	$fmt_hash->{b} = 15 if !defined $fmt_hash->{b};
	$fmt_hash->{c} = 5  if !defined $fmt_hash->{c};
	$fmt_hash->{d} = 40 if !defined $fmt_hash->{d};
    }
    foreach my $key (sort keys %$hash) {
	if(ref $hash->{$key} eq 'ARRAY'){$hash->{$key}=join ",",@{$hash->{$key}}}
	print $fh " " x $fmt_hash->{a};
	if(!defined $hash->{$key}){$hash->{$key}=""}
	printf $fh "%-$fmt_hash->{b}s %s %-$fmt_hash->{d}s\n", "-$key", " " x $fmt_hash->{c},$hash->{$key};
    }

}

sub sqlite_query_snpid{
    my ($self,$tablecol,$where,$dbh,$table)=@_;

    my $t=$self->sql_table($dbh);
    if(!$table || !grep(/\b$table\b/,@$t)){
	$self->throw("specify a -table from following:\n".join ("\n",@$t)."\n");
    }

    my $allcol=$self->sql_tablecol($dbh,$table);

    #print Dumper($tablecol);
    if($$tablecol[0] ne '*'){
	my @intersect= intersect(@$tablecol,@$allcol);
	if(@intersect < @$tablecol){
	    $self->throw("specify colnames from following:\n".join ("\n",@$allcol)."\n")
	}
    }
    

    my $colstr=join ",",@$tablecol;
    my $stmt = qq(SELECT $colstr FROM $table where $where);
    #print STDERR Dumper($stmt);
    my $sth = $dbh->prepare( $stmt );
    my $rv = $sth->execute() or die $DBI::errstr;
    if($rv < 0){
	print $DBI::errstr;
    }
    return $sth->fetchall_arrayref();
    
}

sub sqlite_query{
    my ($self,$tablecol,$where,$dbh,$table)=@_;

    my $t=$self->sql_table($dbh);
    if(!$table || !grep(/\b$table\b/,@$t)){
	$self->throw("specify a -table from following:\n".join ("\n",@$t)."\n");
    }

    my $allcol=$self->sql_tablecol($dbh,$table);

    #print Dumper($tablecol);
    if($$tablecol[0] ne '*'){
	my @intersect= intersect(@$tablecol,@$allcol);
	if(@intersect < @$tablecol){
	    $self->throw("specify colnames from following:\n".join ("\n",@$allcol)."\n")
	}
    }
    

    my $colstr=join ",",@$tablecol;
    my $stmt = qq(SELECT $colstr FROM $table where $where);
    #print Dumper($stmt);
    my $sth = $dbh->prepare( $stmt );
    my $rv = $sth->execute() or die $DBI::errstr;
    if($rv < 0){
	print $DBI::errstr;
    }
    #print Dumper $sth->fetchall_arrayref();
    return $sth->fetchall_arrayref();
    
}

sub sql_table{
    my ($self,$dbh)=@_;
    my @table = $dbh->tables;
    @table=uniq(@table);
    my @t;
    map {if(/\"main\"\.\"(.*?)\"/ && !/sqlite_/){push @t,$1;}} @table;
    return(\@t);
}

sub sql_tablecol{
    my ($self,$dbh,$table)=@_;
    my $hash;
    my $stmt=qq(PRAGMA table_info($table));
    my $sth = $dbh->prepare($stmt );
    my $rv = $sth->execute() or die $DBI::errstr;
    my @allcol;
    while(my @row=$sth->fetchrow_array ){
	push @allcol,$row[1];
    }
    return \@allcol;
}

sub sql_tablecollist{
    my ($self,$dbh)=@_;
    my $t=$self->sql_table($dbh);
    my $hash;
    foreach my $table(@$t){
	my $cols=$self->sql_tablecol($dbh,$table);
	$hash->{$table} = $cols;
    }
    
    return $hash;
}

sub colstr2array
{
    my ($class,$str) = @_;
    my @array;
    if($str!~/,|-/){
	push @array,$str
    }
    elsif($str=~/-/ && $str!~/,/){
	@array = $class->scale2array($str);
    }
    elsif($str=~/,/ && $str!~/-/){
	@array = split/,/,$str;
    }
    else
    {
	my @tmp = split/,/,$str;
	for(@tmp){
	    if(/-/){
		push @array,$class->scale2array($_);
	    }
	    else
	    {
		push @array,$_;
	    }
	}	
    }
    return @array;
}

sub prompt{
    my ($self,$mode)=@_;
    if($mode eq "yesorno"){
	while(my $prompt=<STDIN>){
	    chomp($prompt);
	    if(!$prompt){return 1;}
	    elsif($prompt=~/y/ && $prompt!~/n/){
		return 1;
	    }
	    else{return 0;}
	}
    }
    elsif($mode eq "reply"){
	while(my $prompt=<STDIN>){
	    chomp($prompt);
	    if(!$prompt){next;}
	    else{return $prompt;}
	}
    }
    else{
	exit("wrong mode for subroutine promp\n");
    }

}

sub prompt_option{
    my ($self,$x) = @_;
    my $min = min($#$x,15);
    map {print STDERR $_+1,"\t",$$x[$_],"\n"} 0..$min;
    print STDERR "输入:\t";
    while( my $i = &prompt("reply")){
	if(looks_like_number($i) && $i <=@$x){
	    my ($key,$value) = split/\s*\t\s*/,$$x[$i-1];
	    print STDERR "你选中的是:\t$key\n";
	    return $key;
	}
	elsif(!looks_like_number($i)){
	    print STDERR "new entry\n";
	    return $i;
	}
	elsif($i > @$x){
	    print STDERR "input number too big\n";
	    next;
	}
    }
}



sub getStrByKeysHash
{
    my ($self,$keys) = @_;
    print Dumper $keys;
    my @str;
    map {exists $self->{"$_"}?push @str,$self->{"$_"}:push @str,"";}  @$keys;
    return join ";",@str;
}

sub getStrByKeysSepHash
{
    my ($self,$keys,$sep) = @_;
    $sep=";",if !$sep;
    my @str;
    map {exists $self->{"$_"}?push @str,$self->{"$_"}:push @str,"";}  @$keys;
    #print Dumper(scalar(@str));
    return join $sep,@str;
}


sub getArrayByKeysHash
{
    my ($self,$keys) = @_;
    my @str;
    map {exists $self->{"$_"}?push @str,$self->{"$_"}:push @str,"";} @$keys;
    return \@str;
}

sub getTabByKeysHash
{
    my ($self,$keys) = @_;
    my @str;
    map {push @str,$self->{"$_"}} @$keys;
    return join "\t",@str;
}

sub decode64
{
    my ($self,$str)=@_;
    $str=~s#.*://##g;
    if(length($str)%4!=0){
	$str .= "=" x (4-length($str)%4);
    }
    $str=~s/-/+/g;
    $str=~s/_/\//;
    return `echo $str | base64 -d`
}

=head1 AUTHOR

Rui Chen, C<< <crotoc at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-test at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=test>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc test


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=test>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/test>

=item * Search CPAN

L<https://metacpan.org/release/test>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2021 by Rui Chen.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)


=cut



1;
