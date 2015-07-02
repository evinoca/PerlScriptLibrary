#!/usr/perl	
#******************************************************************************************************************************************
#This Script will rename all the .dfl.bak files output by AIDA to .dlf files and transfer them to a centain folder named with a input 
#String which is indicate the name of test case. And put them in to a specific name pattern as designed.
#Input Arrgument :
#A. <TestCase Name> <Pathlose> <Radio Link Parameters> <Number of Moible in use>
#	Return:
# 	Function: Collect Files 
#	All Done : Script finish without error
#	Error : Script Error
#B. clear
#	Function: Clear folders
#	Return:
#	All Done/Error
#C. BS <test case name>
#	Function: Call BlueShark to decode files
#	Return:
#	All Done/Error
#******************************************************************************************************************************************
use strict;
use File::stat; 
use File::Copy;
use Cwd;
use Net::Telnet;

#Declaration of variables
my $path_local_base = 'C:\\Automation_RPI_Test';
my $path_local_storage =  'S:\\';
my $path_remote_storage =  'T:\\';
my $casename = "DefaultTestCase";
my $path_sub_folder = '';
my $file_SizeFilter = 4000 ;
my $MobileNumber_add_Step = 4;

#BlueShark的IP地址，端口号及超时时间
my $host = '135.251.82.242'; 
my $port = 6400;
my $timeout = 1800;

my ($min,$hour,$mday,$mon,$year) = (localtime(time))[1,2,3,4,5];
    $year += 1900;
#在所有单数的日期或者时间的字符串前面加0补齐
if  ($min < 10){ $min = "0".$min;}
if  ($hour < 10){$hour = "0".$hour;}
if  ($mday < 10){$mday = "0".$mday;}
if  ($mon < 10 ){$mon = "0".$mon;}
#生成时间戳
my $TimeStamp = $year.$mon.$mday.'_'.$hour.'_'.$min;
#Log_MS1_PL113@33@20120614_16_43.xls
#Log_MS1_PL110@41@41@42@20120807_10_06.xls
my $pathlose = -1;
my $RxPowerMain=  -1;
my $RxPowerDiv = -1;
my $RxPowerComb =  -1;
my $TxPower3gpp = -1;
my $isRemoteInvolved = 0;
my $flexiblePart = '';
my $file_SizeFilter = 4000 ;
my @ArrayNumbers = ();

# sub function of moving files
sub CreateFolder	
{
	mkdir $path_local_base unless (-e $path_local_base);
	$path_sub_folder = $path_local_base."\\".$casename ;
	mkdir $path_sub_folder unless (-e $path_sub_folder);
	print "DLF files will be moved to : ".$path_sub_folder."\n";
}
sub DLF_Collect
{
	if ($isRemoteInvolved == 1)
	{
		Collect_local();
		Collect_remote();		
	}
	elsif($isRemoteInvolved == 0)
	{
		Collect_local();
	}
	else
	{
		print "Error::  $isRemoteInvolved  Arguments Error!\n";
	}
}
sub RenameFile
{
	foreach my $file (glob "*.bak")
	{ 
		print "BAK file found, named ",$file,"\n";

		my $filesize = stat($file)->size;#检查文件大小
		
		if($file=~s/\.bak$//g)#匹配所有以.bak为后缀的文件
		{ 
			rename("$file.bak","$file"); 
		}

		print "The Size of This File is ",$filesize,"\n";

		if ($filesize < $file_SizeFilter)#文件大小过滤，
		{
			print $file."is smaller than ".$file_SizeFilter."\n";
			unlink $file;
			print $file." has Been Deleted..."."\n";
		}
	}

}

sub MoveToPath
{
	foreach my $file (glob "*.dlf")
	{
		if ($file=~m/Mobile-RNC-(\d+)/)
		{
			print "Trace of Mobile $1 Found !"."\n";
			my $name ="Log_MS$1_".$flexiblePart.".dlf";
			rename("$file","$name");
			move($name,$path_sub_folder) or die "Unable to move files!\n";			
		}
	}	

}

sub Collect_local
{
	print "Start to Read File at Local AIDA output folder :".$path_local_storage."\n";
	chdir($path_local_storage) or die "Can't cd dir: $!\n" ;
	RenameFile();
	MoveToPath();
}
	

sub Collect_remote
{
	print "Start to Read File at Remote AIDA output folder :".$path_remote_storage."\n";
	chdir($path_remote_storage) or die "Can't cd dir: $!\n" ;
	foreach my $file (glob "*.bak")
	{
		print "->   $file\n";
		if ($file=~m/Mobile-RNC-(\d)(.*)/)
		{
			print "1: $1 2: $2 \n";
			my $new_number = $1;
			$new_number+=$MobileNumber_add_Step;
			my $newname = "Mobile-RNC-".$new_number.$2;
			print "New Name : $newname\n";
			rename("$file","$newname");
		}
	}
	RenameFile();
	MoveToPath();
}

sub BlueShark
{
	print "Prepare to Call BlueShark to decode folder in path \n->".$path_sub_folder."\n";
	#call blueshark to decode dlf files
	#输出当前工作目录
	
	my $Blueshark = new Net::Telnet (Timeout => $timeout,Port => $port);            

	print "Opening BlueShark Host @ $host : $port  ..."."\n";
	my @lines = $Blueshark->open("$host");
	if (@lines == 1)
	{
		print "Open Host Success"."\n";
	}
	else
	{
		print "Open Host Failed..."."\n";
	}

	print "Decoding DLF Files in directory : \n$path_sub_folder\nPlease Wait...This might take for a while"."\n";
	#调用BlueShark对目标目录下的文件进行decode
	$Blueshark->print("DECODE_DIR $path_sub_folder");
	$Blueshark -> waitfor ('Match'=>"/OK/");
	#断开BlueShark服务
	print "Disconnect from BlueShark Server"."\n";
	@lines = $Blueshark->print("QUIT");
	if (@lines == 1)
	{
		print "Disconnect Success..."."\n";
	}
	else
	{
		print "Disconnect Failed..."."\n";
	}

	print "Decoding Completed...\n";

	$Blueshark->close;
}

sub clear
{
	print "Prepare to Clear trash in $path_local_storage and $path_remote_storage\n";
	chdir($path_local_storage) or die "Can't cd dir: $!\n" ;
	foreach my $file (glob "*.bak")
	{
		unlink $file;
		print $file." has Been Deleted..."."\n";
	}
	foreach my $file (glob "*.dlf")
	{
		unlink $file;
		print $file." has Been Deleted..."."\n";
	}
	chdir($path_remote_storage) or die "Can't cd dir: $!\n" ;
	foreach my $file (glob "*.bak")
	{
		unlink $file;
		print $file." has Been Deleted..."."\n";
	}
	foreach my $file (glob "*.dlf")
	{
		unlink $file;
		print $file." has Been Deleted..."."\n";
	}
	print "All Done!"."\n";
	print "Both in $path_local_storage and $path_remote_storage are empty now\n";
}

sub warning
{
	print 'Error:: Arguments Error! Input Arrgument Must be in Certain Format'."\n";
	print "*********************************************************************"."\n";
	print "Opitions:\n";
	print "A. To collect *.dlf.bak files in specific Path defined in script line 25 \n   and 26, and rename \n";
	print "   into .dlf, then format those file name as following input Parameters:\n";
	print " <TestCase Name> <Pathlose> <Radio Link Parameters> <Number of Moible in use>"."\n";
	print "   Eg. perl AIDA_Result_Collect.pl Casename 110 12;12;12 4\n";
	print "*********************************************************************"."\n";
	print "   Note: "."\n";
	print "   <Radio Link Parameters>  depends on Traffic Scenarios: "."\n";
	print "   Up load Scenarios -> "."\n"; 
	print "   <<RxPowerMain>;<RxPowerDiv>;<RxPowerComb>> Eg: 12;12;13"."\n";
	print "   Down load Scenarios -> "."\n"; 
	print "   <<TxPower3gpp>> Eg : 7"."\n";
	print "*********************************************************************"."\n";
	print "B. To Clear the defined storage folder.\n";
	print "   Eg. perl AIDA_Result_Collect.pl clear\n";
	print "*********************************************************************"."\n";
	print "C. To Call BlueShark to decode folder named after <TestCase Name>\n";
	print "   Eg. perl AIDA_Result_Collect.pl BS Casename\n";
	print "   Blueshark's work parameters are defined in line 32-34\n";
	print "*********************************************************************"."\n";
	print "Please make sure the path configuration in script line 25-26 is correct\n before use.\n";
}

#Main()
if (@ARGV == 4 or (@ARGV == 5 and $ARGV[4] =~/BS/))
{
	print "4 Input Arguments Detected\n"; 
	print "*********************************************************************"."\n";
	#参数1检查，case名称
	if ($ARGV[0] =~ /\w+/)
	{
		print "Test Case's Name Defined as ".@ARGV[0]."\n";
		$casename = $ARGV[0];
	} 
	else
	{
		print "Error:: Test Case's Name Arguments Error!\n";
	}
	#参数2检查 路损
	if($ARGV[1] =~ m/(\d+)/)
	{
		$pathlose = $1;
		print "Radio Link Pathlose = ".$pathlose."\n";
	}
	else
	{
		print "Error:: Arguments Error!\n";
		warning();
	}
	 #参数3检查 链路参数   
	if ($ARGV[2] =~ m/(\d+).*\;(\d+).*\;(\d+).*/)
	{
		print "Collect DLF files for UL Scenarios\n";
		$RxPowerMain =  $1;
		$RxPowerDiv =  $2;
		$RxPowerComb = $3;
		print "RxPowerMain = ".$RxPowerMain."\n";
		print "RxPowerDiv = ".$RxPowerDiv."\n";
		print "RxPowerComb = ".$RxPowerComb."\n"; 
		$flexiblePart = "PL".$pathlose."@".$RxPowerMain."@".$RxPowerDiv."@".$RxPowerComb."@".$TimeStamp;
	}
	elsif($ARGV[2] =~ m/(\d+)/)
	{
		print "Collect DLF files for DL Scenarios\n";
		$TxPower3gpp = $1;
		print "TxPower3gpp = ".$TxPower3gpp."\n";
		$flexiblePart = "PL".$pathlose."@".$TxPower3gpp."@".$TimeStamp;  
	}
	else
	{
		print "Error::  Radio Link Arguments Error!\n";
		warning();
	}

	#参数4检查 UE数量类型
	if($ARGV[3]=~/(\d+)/) 
	{
		if ($1 == 1 or $1 ==2 )
		{
			$isRemoteInvolved = 0;
			print "Collect DLF files on local host only\n";
			
		}
		elsif($1 == 4 or $1 == 8)
		{
			$isRemoteInvolved = 1;
			print "Collect DLF files on both local and remote host \n";
			if ($1 == 4)
			{
				$MobileNumber_add_Step = 2;
			}
			elsif($1 == 8)
			{
				$MobileNumber_add_Step = 4;
			}
			
		}
		else
		{
			print "Error:: Mobile Number Argument Error!\n";
			warning();
		}
	}
	else
	{
		print "Error:: Arguments Error!\n";
	}  
	print "*********************************************************************"."\n";
	print "Flexible Part of File Name is : ".$flexiblePart."\n";
	print "*********************************************************************"."\n";
	CreateFolder();
	DLF_Collect();

	if ($ARGV[4] =~/BS/)
	{
		BlueShark();
	}

	print "All Done!"."\n";
}
elsif (@ARGV == 1)
{
	if ($ARGV[0]=~/clear/)
	{
		clear();
	} 
	else
	{
		warning();
	}
}
elsif (@ARGV == 2)
{
	if($ARGV[0]=~/BS/)
	{
		if ($ARGV[1]=~ /\w+/)
		{
			print "Test Case's Name Defined as ".@ARGV[1]."\n";
			$casename = $ARGV[1];
			$path_sub_folder = $path_local_base."\\".$casename ;
			BlueShark();
			print "All Done!\n";
		}
		else
		{
			warning();
		}
		
	}
	if($ARGV[0]=~/BSDIR/)
	{
		if ($ARGV[1]=~ /\w+/)
		{
			print "Target Dir is ".@ARGV[1]."\n";
			$path_sub_folder = @ARGV[1] ;
			BlueShark();
			print "All Done!\n";
		}
		else
		{
			warning();
		}
		
	}
	else
	{
		warning();
	}
}
else
{
	warning();
}