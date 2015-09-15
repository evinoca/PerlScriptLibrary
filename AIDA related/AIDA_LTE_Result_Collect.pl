use strict;
use File::stat; 
use File::Copy;
use Cwd;


my $Source = "C:\\tools\\carla\\var\\ue\\trace";
my $Dest = "C:\\QXDM\\SWR";
my $decode = "C:\\Program Files\\Qualcomm\\QXDM\\Bin";
my $filter = 5000;


mkdir $Dest unless (-e $Dest);
chdir($Source) or die "Can't cd dir: $!\n" ;
foreach my $file (glob "*.bak")
{
	print "->   $file\n";
	if ($file=~m/(.*).dlf.bak/)
	{
		my $filesize = stat($file)->size;#检查文件大小
		if ($filesize < $filter)#文件大小过滤，
		{
			print $file."is smaller than ".$filter."\n";
			unlink $file;
			print $file." has Been Deleted..."."\n";
		}
		else
		{
			my $newname = $1.".dlf";
			print $1."\n";
			print $newname."\n";
			rename("$file","$newname");
			move($newname,$Dest) or die "Unable to move files!\n";	
			chdir($decode ) or die "Can't cd dir: $!\n" ;
			my $command = "DLFConverter.exe ".'"'."C:\\QXDM\\SWR\\".$newname.'"';
			print $command;
			system($command);
		}
		
	}
	else
	{
		print "No file to move!\n";
	}
}