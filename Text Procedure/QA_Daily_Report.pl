#!/usr/perl

use utf8;
use strict;
use File::stat;
use File::Copy;
use Net::Telnet;
use File::Basename;

#获取系统路径并切换路径
my $work_path =  dirname(__FILE__);
#print $work_path."\n";

chdir $work_path or die $!;

sub getTime
{
   #time()函数返回从1970年1月1日起累计秒数
    my $time = shift || time();

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst,$monF) = localtime($time);

    $mon ++;
    $sec  = ($sec<10)?"0$sec":$sec;#秒数[0,59]
    $min  = ($min<10)?"0$min":$min;#分数[0,59]
    $hour = ($hour<10)?"0$hour":$hour;#小时数[0,23]
    $mday = ($mday<10)?"0$mday":$mday;#这个月的第几天[1,31]
    $monF  = ($mon<10)?"0$mon":$mon;#月数[0,11],要将$mon加1之后，才能符合实际情况。
    $year+=1900;

    my $weekday = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat')[$wday];
    return { 'second' => $sec,
             'minute' => $min,
             'hour'   => $hour,
             'day'    => $mday,
             'month'  => $mon,
			 'month_F'  => $monF,
             'year'   => $year,
             'weekNo' => $wday,
             'wday'   => $weekday,
             'yday'   => $yday,
             'date'   => "$year/$mon/$mday",
			 'dateF'   => "$year$monF$mday"
          };
}

#main
my $date = &getTime();#获取当前系统时间的Hash
my $timestaemp = $date->{dateF};#获取yyyymmdd这样的日期
my $timeRegexpString= $date->{date};
my $reportFileName_ST= "QA_System_Test_DailyReport_$timestaemp.txt";
my $reportFileName_AT= "QA_Automation_DailyReport_$timestaemp.txt";


open(REPORT_ST,">".$reportFileName_ST) or die $!;
open(REPORT_AT,">".$reportFileName_AT) or die $!;

my %detail;

my $st = 0;
my $at=0;
my $st_profile = 0;
my $at_profile = 0;

chdir $work_path."//DailyReport" or die "Can't find path DailyReport".$!;
foreach my $file (glob "*.txt")
	{
		#print $file;
		if ($file=~m/QA/)
		{
		}
		elsif ($file=~m/ST_(.*).txt/)
		{
			my $rwFlag= 0;
			my $submitFlag = 0;
			$st_profile++;
			$detail{$1}{"team"}="System Test";
			syswrite(REPORT_ST,$1." @ ") or die "Can't write report file".$!;
			open FILE, $file or die $!;
			chomp (my @lines = (<FILE>));
			close(FILE);
			my $i = 1;
			foreach my $line (@lines)
			{
			   #print $line."\n";
			   if ($line=~m/$timeRegexpString/)
			   {
					$rwFlag= 1;
			   }
			   elsif($line=~m/\d{4}\/\d?\/\d?/)
			   {
					$rwFlag= 0;
			   }
			   if ($rwFlag== 1)
			   {
					syswrite(REPORT_ST,$line."\r\n") or die "Can't write report file".$!;
					$submitFlag=1;
			   }
				
			}
			syswrite(REPORT_ST,"\r\n") or die "Can't write report file".$!;
			if ($submitFlag == 0){
				$detail{$1}{"status"}="Not Submit";
			}
			else{
				$st++;
				$detail{$1}{"status"}="Updated";			
			}
		}
		elsif ($file=~m/AT_(.*).txt/)
		{
			my $rwFlag= 0;
			my $submitFlag =0;
			$at_profile++;
			$detail{$1}{"team"}="Automation Test";
			syswrite(REPORT_AT,$1." @ ") or die "Can't write report file".$!;
			open FILE, $file or die $!;
			chomp (my @lines = (<FILE>));
			close(FILE);
			my $i = 1;
			foreach my $line (@lines)
			{
			   #print $line."\n";
			   if ($line=~m/$timeRegexpString/)
			   {
					$rwFlag= 1;
			   }
			   elsif($line=~m/\d{4}\/\d?\/\d?/)
			   {
					$rwFlag= 0;
			   }
			   if ($rwFlag== 1)
			   {
					syswrite(REPORT_AT,$line."\r\n") or die "Can't write report file".$!;
			   }
			  

			}
			if ($submitFlag == 0){
				$detail{$1}{"status"}="Not Submit";
			}
			else{
				$at++;
				$detail{$1}{"status"}="Updated";
			}
		}
	}
	
my ($dname, $dteam, $dstatus);	
foreach my $name (keys %detail)
 {
	($dname, $dteam, $dstatus)= ($name,$detail{$name}{"team"},$detail{$name}{"status"});
	$^ = 'STDOUT_TOP';
	$~ = 'STDOUT';
	 write;
}

format STDOUT_TOP =
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$timeRegexpString	  
		Daily Report Status 
------------------------------------------------------------------		
Name           Team             Report Status
------------------------------------------------------------------
.
 
format STDOUT =
@<<<<<<<<<<<<<@<<<<<<<<<<<<<<<<<<@<<<<<<<<<<<<<<<<<<
$dname,                        $dteam,                                   $dstatus
.

close(REPORT_ST) or die $!;
close(REPORT_AT)or die $!;
print "------------------------------------------------------------------\n";
print "ST: ".$st."/".$st_profile."\n";
print "AT: ".$at."/".$at_profile."\n";
print "Done\n";
sleep (3)or die $!;
