my $string = "sdf&#1;0<>";
$string=~s/&#1;0//;



my $string2 = "abcdf";
if ($string2=~/a/)
{
	print "YES\n";

}
print $string;