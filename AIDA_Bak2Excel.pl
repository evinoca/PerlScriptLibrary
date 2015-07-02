#!/usr/perl
#******************************************************************************************************************************************
#Describe: 批量修改文件名后缀 删除过小的文件 并且调用本地BlueShark将分类后的文件夹中的DLF文件转换为Excel文件
#argument：1. ARGV[0] casename:string
#                     用例名称-> 将以此命名DLF文件存放的根目录名称，如果没有参数输入，将会使用默认名称 DefaultTestCaseName+时间标志
#          2. ARGV[1] bool_isDecodewithBlueShark:false
#                     是否使用BlueShark对文件进行Decode的判决条件,在第二参数位输入false判断跳过Decode phrase
#************************************************************************************************
#2012.11.02 sunyuting 将BlueShark部分加入判断条件，默认为使用,第二参数为false时跳过decode phrase
#2012.09.17 sunyuting 1.修改逻辑顺序，将文件分类和删除分为两个foreach循环
#                     2.增加DLF文件数量统计
#2012.09.16 sunyuting 添加BlueShark调用部分
#2012.09.15 sunyuting 创建文件
#
#******************************************************************************************************************************************
use strict;
use File::stat; 
use File::Copy;
use Net::Telnet;
use Cwd;

#BlueShark的IP地址，端口号及超时时间
my $host = '135.251.82.242'; 
my $port = 6400;
my $timeout = 1800;
#默认输入参数
my $casename = "DefaultTestCaseName";
my $ifDecodeWithBlueShark = 0;

#AIDA would create some file frag in trace folder, set up a file-size filter to delelte all those smaller than treshold value
my $file_SizeFilter = 4000 ;

#获取本地时间
my ($min,$hour,$mday,$mon,$year) = (localtime(time))[1,2,3,4,5];
    $year += 1900;
#在所有单数的日期或者时间的字符串前面加0补齐
if  ($min < 10){ $min = "0".$min;}
if  ($hour < 10){$hour = "0".$hour;}
if  ($mday < 10){$mday = "0".$mday;}
if  ($mon < 10 ){$mon = "0".$mon;}
#生成时间戳
my $TimeStamp = $hour.'_'.$min.' '.$mon.'-'.$mday.'-'.$year;

#输入参数为用例名称，根据用例名称建立文件夹 判断当有2个输入参数 并且第二输入参数为false时，标志位$ifDecodeWithBlueShark置为1，表示跳过转换阶段
if (@ARGV == 2)
{
	print "2 input arguments detected\n";     
	if ($ARGV[1] =~ /false/)
	{
		print "Do not use BlueShark to decode files.\n";
    	$ifDecodeWithBlueShark = 1;
	}
	if ($ARGV[0] =~ /\w+/)
	{
		print "Case name defined as ".@ARGV[0]."\n";
		$casename = $ARGV[0];
	}
    
}
elsif((@ARGV == 1) and ($ARGV[0] =~ /\w+/))
{
	print "1 input argument detected\n";
	print "Case name defined as ".$ARGV[0]."\n";
	$casename = $ARGV[0];    	
}
else
{
	print "Runs in Default Configuration.\n";
	print "Case name is DefaultTestCaseName.\n";
	print "Use BlueShark to decode DLF files.\n";
}   

print "Test Case: ".$casename."\n";

#生成目录结构，目前可支持4UE
my $dir_main = $casename." ".$TimeStamp;
my $dir_ms1 = $dir_main."/Mobile_1"; 
my $dir_ms2 = $dir_main."/Mobile_2";
my $dir_ms3 = $dir_main."/Mobile_3";
my $dir_ms4 = $dir_main."/Mobile_4";
my $counter_ms1 = 0;
my $counter_ms2 = 0;
my $counter_ms3 = 0;
my $counter_ms4 = 0;

#生成根目录结构
mkdir $dir_main unless (-e $dir_main);

foreach my $file (glob "*.bak")
{ #查找当前目录下所有以“a”为前缀的文件
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

print "\nFile rename and filter Completed.\n\n";

#文件按照文件名前缀分类
foreach my $file (glob "*.dlf")
{

	if ($file=~m/Mobile-RNC-1/)#如果文件名称中含有Mobile-RNC-1
	{
		print "Trace of Mobile_1 Found !"."\n";
		mkdir $dir_ms1 unless (-e $dir_ms1);#除非文件夹已存在，创建文件夹
		move ($file,$dir_ms1."/".$file)||warn "DLF file relocation failed, this file might have already been deleted..."."\n" ;#移动文件
		print $file."is moved into".$dir_ms1."\n";
		$counter_ms1+=1;
	}
	if ($file=~m/Mobile-RNC-2/)#如果文件名称中含有Mobile-RNC-2
	{
		print "Trace of Mobile_2 Found !"."\n";
		mkdir $dir_ms2 unless (-e $dir_ms2);#除非文件夹已存在，创建文件夹
		move ($file,$dir_ms2."/".$file)||warn "DLF file relocation failed, this file might have already been deleted..."."\n" ;#移动文件
		print $file."is moved into".$dir_ms2."\n";
		$counter_ms2+=1;
	}
	if ($file=~m/Mobile-RNC-3/)#如果文件名称中含有Mobile-RNC-3
	{
		print "Trace of Mobile_3 Found !"."\n";
		mkdir $dir_ms3 unless (-e $dir_ms3);#除非文件夹已存在，创建文件夹
		move ($file,$dir_ms3."/".$file)||warn "DLF file relocation failed, this file might have already been deleted..."."\n" ;#移动文件
		print $file."is moved into".$dir_ms3."\n";
		$counter_ms3+=1;
	}
	if ($file=~m/Mobile-RNC-4/)#如果文件名称中含有Mobile-RNC-4
	{
		print "Trace of Mobile_4 Found !"."\n";
		mkdir $dir_ms4 unless (-e $dir_ms4);#除非文件夹已存在，创建文件夹
		move ($file,$dir_ms4."/".$file)||warn "DLF file relocation failed, this file might have already been deleted..."."\n" ;#移动文件
		print $file."is moved into".$dir_ms4."\n";
		$counter_ms4+=1;
	}
}
print "******************************************************\n";
print "Mobile 1 trace file: ".$counter_ms1."\n" unless $counter_ms1 == 0;
print "Mobile 2 trace file: ".$counter_ms2."\n" unless $counter_ms2 == 0;
print "Mobile 3 trace file: ".$counter_ms3."\n" unless $counter_ms3 == 0;
print "Mobile 4 trace file: ".$counter_ms4."\n" unless $counter_ms4 == 0;
my $dlf_count = $counter_ms1+$counter_ms2+$counter_ms3+$counter_ms4 ;
print "\nAll $dlf_count BAK Files have been renamed to DLF file and sorted into ".$dir_main."\n\n";

if ($ifDecodeWithBlueShark != 1)#判决是否使用blueshark
{
	print "\nPreparing to call BlueShark to Decode files... \n";
	#call blueshark to decode dlf files
	#输出当前工作目录
	print "The Current Working Directory is ";
	print getcwd;
	print "\n";
	#获取Blueshark工作目录
	my $dir = getcwd;
	$dir = $dir."/".$dir_main;
	#生成Blueshark对象
	my $Blueshark = new Net::Telnet (Timeout => $timeout,Port => $port);            

	print "Opening BlueShark Host on $host : $port  ..."."\n";
	my @lines = $Blueshark->open("$host");
	if (@lines == 1)
	{
		print "Open Host Success"."\n";
	}
	else
	{
		print "Open Host Failed..."."\n";
	}

	print "Decoding DLF Files in directory : \n$dir\nPlease Wait...This might take for a while"."\n";
	#调用BlueShark对目标目录下的文件进行decode
	$Blueshark->print("DECODE_DIR $dir");
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
else
{
	print "BlueShark Phrase Passed...\n";
}

print "All Done!";


