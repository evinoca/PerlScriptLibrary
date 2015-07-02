use strict;

my $testInt = 0;
my $casename = "defaultName";
   if (@ARGV == 2)    #----如果参数个数不为1或者参数不是数字
    {
    	print "2 argv detected\n";     
    	if ($ARGV[1] =~ /false/)
    	{
    		print "2rd argv is false\n";
        	print "And is: ".$ARGV[0]."\n";
        	$testInt = 1;
    	}
    	if ($ARGV[0] =~ /\w+/)
    	{
    		$casename = $ARGV[0];
    	}
        
    }
    elsif((@ARGV == 1) and ($ARGV[0] =~ /\w+/))
    {
    	print "1 argv detected\n";
    	print "And is: ".$ARGV[0]."\n";
    	$casename = $ARGV[0];    	
    }
    else
    {
    	print "default\n";
    }   

print "case name is $casename\n";
if ($testInt != 1)
{
	print "Use this function\n";
}
else
{
	print "Dont need to use function\n";
}
