package MyBase::Usual;
use strict;
use warnings;
require Exporter;
use Data::Dumper;
#our @ISA = qw(Exporter_OK);
#our @EXPORT=qw(new rand_pick);

our @EXPORT_OK=qw(new);


sub new{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub testexist{
    my $class = shift;
    my $file =$_[0];
    
    if(-e $file){
	print "$file...existed\n";
    }
    else{
	warn "$file...not existed\n";
    }
}

sub extract{
    my $class = shift;
    my $query = $_[0];
    my $db = $_[1];
    my $result;
    my $format=$_[2];
    
    my $group;
    my $chr;
    my $pos;
    my $freq;
    if($format eq "map"){
        ($group,$chr,$pos,$freq) = split/[\t:]/, $query;
    }
    elsif($format eq "group"){
        ($chr,$pos,$group) = split/[\t]/, $query;
    }
    else{
	die "Wrong format;"
    }
    #print $chr,$pos,$freq;
    my $string = "$chr:$pos-$pos";
    #print "$string\n";
    $result = `tabix $db $string`;
    #print $result;
    if($result=~/\n.*\n/ && $result=~/($chr\t$pos.*?\n)/){
        $result = $1;
    }
    return $result;
}

sub grouphash{
    #Input group or map file, return group-wise Hashes
    my $class = shift;
    my @q = @{$_[0]};
    my $format = $_[1];
    my $col = $_[2];
    my %a;
    my %b;
    #print @q;

    foreach my $query(@q){
        my $group;
        my $chr;
        my $pos;
        my $freq;
        
	if($query!~/#/){
	    if($format eq "map"){
		($group,$chr,$pos,$freq) = split/[\t:]/, $query;
		$a{"$chr\t$group"}++;
		#print "$query\t".$a{"$chr\t$group"},"\n";
		if($a{"$chr\t$group"}>=1){
		    push @{$b{"$chr\t$group"}},$query."\n";
		}
	    }
	    elsif($format eq "group"){
		($chr,$pos,$group) = split/\t/, $query;
		$a{"$chr\t$group"}++;
		#print "$query\t".$a{"$chr\t$group"},"\n";
		if($a{"$chr\t$group"}>=1){
		    push @{$b{"$chr\t$group"}},$query."\n";
		}
	    }
	    elsif($format eq "bycol"){
		my @temp = split/\t/,$query;
		$group = $temp[$col-1];
		$a{"$group"}++;
		#print "$query\t".$a{"$chr\t$group"},"\n";
		if($a{"$group"}>=1){
		    push @{$b{"$group"}},$query."\n";
		}
	    }
	    else{
		die "Please input right format";
	    }
	    
	}
    }
    return %b;
}

sub strToarray{
    my $class = shift;
    my $str = shift;
    my @array = ();
    @array=split/,/,$str;
    return @array;
}

sub uniqsummary
{
    my $class = shift;
    my $str = $_[0];
    my @array;
    chomp(@array=split/\t/,$str);

    #print @array;
    my %hash;
    my @out;
    my $result;

     foreach(@array){
         if($_){
             $hash{$_}++;
         }
     }
     foreach (sort keys %hash){
         push @out,"$_,$hash{$_}";
     }
    
    return (\%hash,\@out);
}

sub redundant2eachrow
{
    my $class=shift;
    my $delim=$_[0];
    my $col=$_[1];
    my $fh=$_[2];
    
    while(my $line=<$fh>){
	chomp $line;
	my @line = split/\t/,$line;
	my @field = split/$delim/,$line[$col-1];
	foreach (@field)
	{
	    if($_){
		print "$line\t$_\n"
	    }
	}
    }
}



sub printopts
{
    my $class=shift;
    my $opt=$_[0];
    my $description = $_[1];
    my $format='%-30s%-20s';
    
    print "\t";
    printf $format,$opt,$description;
    print "\n";
}

sub printopts2
{
    my $class=shift;
    my $opt=$_[0];
    for (sort keys %$opt)
    {
	my $description = $opt->{$_};
	my $format='%-30s%-20s';
	if(!$$description)
	{
	    $$description='';
	}
	
	print "\t";
	printf $format,$_,$$description;
	print "\n";
    }
}


sub printhash
{
    my $class=shift;
    my %hash=%{$_[0]};
    my $format;
    if(! $_[1]){
	$format=1;
    }else{
	$format=$_[1];
    }
    my $fh;
    if(! $_[2]){
	$fh=\*STDOUT;
    }
    else{
	$fh=$_[2];
    }    
    
    if($format==1){
	foreach my $key(sort keys %hash){
	    if(!$hash{$key}){$hash{$key}="";}
	    printf $fh "$key\t$hash{$key}\n";
	}
    }
    elsif($format==2){
	foreach my $key(sort keys %hash){
	    if(!$hash{$key}){$hash{$key}="";}
	    print $fh "$hash{$key}";
	}
	print "\t";
    }
    elsif($format==3){
	my $str;
	foreach my $key(sort keys %hash){
	    if(length($hash{$key})==0){$hash{$key}="";}
	    $str.="$hash{$key}";
	}
	#print $str;
	printf $fh '%-20s',$str;
	print $fh "\t";
    }
}

sub printarray
{
    my $class=shift;
    my @array=@{$_[0]};
    my $format;
    if(! $_[1]){
	$format=1;
    }else{
	$format=$_[1];
    }
    my $fh;
    if(! $_[2]){
	$fh=\*STDOUT;
    }
    else{
	$fh=$_[2];
    }
    if($format==1){
	foreach my $key(@array){
	    printf $fh '%-20s',$key;
	    print $fh "\t";
	}
    }
    elsif($format==2){
	my $str;
	foreach my $key(@array){
	    $str.="$key";
	}
	#print $str;
	printf $fh '%-20s',$str;  
	print $fh "\t";
    }
}

sub hash2str  ##hast2str by orderd keys and only values
{
    my $class=shift;
    my $hash=$_[0];
    my $key_order=$_[1];
    my $delimeter=$_[2];
    my $type=$_[3];
    my $str;
    my @str;
    
    
    $key_order=[keys %$hash],if (! $key_order);
    $delimeter = ",", if (! $delimeter);
    foreach (@$key_order){
	if(! exists $hash->{$_}){
	    $hash->{$_}='';
	}
	else{
	    if($type==2){
		push @str,"$_"."="."$hash->{$_}";
	    }
	    if($type==1){
		push @str,$hash->{$_};
	    }

	}
	
    }
    $str=join $delimeter,@str;
    return $str;
}


sub scale2array
{
    my ($class,$str) = @_;
    my @array;
    my ($s,$e) = split/-/,$str;
	if($e){
	    @array=$s..$e;
	}
	else
	{
	    print STDERR "need max length";
	}
    
    return @array;
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




1;
