use strict;
use warnings;
use Time::Local; 
use POSIX qw(strftime);

my$person;  
my%family_name;  
 
$family_name{"fred"}="flintstone";  
$family_name{"barney"}="rubble";  
 
foreach $person(qw<barney fred>)
{  
	print"I've heard of $person $family_name{$person}.\n";  
}  
 
my %some_hash=("foo", 35, "bar",12.4, 25, "hello" ,"wilma", 1.72e30, "betty", "bye\n");  
 
my @array_array=%some_hash;  
print"@array_array\n";  
my $iarray=@array_array;
print $iarray,"\n";

my%last_name=(  
"fred"=>"flintstion",  
"dino"=>undef,  
"barney"=>"rubble",  
"betty"=>"rubble",  
);  

my@k=keys%last_name;  
my@v=values%last_name;  
my$count=keys%last_name;#scalar-producing,key/valuepairs  
 
print"the key are @k.\n";  
print"the value are @v.\n";  
print"the count are $count.\n";
$|=1;
my ($Timer1,$Timer3);

$Timer1 = strftime("%Y%m%d%H%M%S", gmtime(time));
$Timer3 = strftime("%Y%m%d%H%M%S", localtime(time));

print $Timer1,"\n",$Timer3;

