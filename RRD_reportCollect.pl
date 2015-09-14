#!/usr/perl	


use strict;
use File::stat; 
use File::Copy;
use Net::Telnet;
use File::Basename;

my $work_path =  dirname(__FILE__);

print $work_path."\n";
chdir $work_path;

sub getTime
{
   #time()函数返回从1970年1月1日起累计秒数
    my $time = shift || time();
    
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
    
    $mon ++;
    $sec  = ($sec<10)?"0$sec":$sec;#秒数[0,59]
    $min  = ($min<10)?"0$min":$min;#分数[0,59]
    $hour = ($hour<10)?"0$hour":$hour;#小时数[0,23]
    $mday = ($mday<10)?"0$mday":$mday;#这个月的第几天[1,31]
    my $monF  = ($mon<10)?"0$mon":$mon;#月数[0,11],要将$mon加1之后，才能符合实际情况。
    $year+=1900;#从1900年算起的年数
    
    #$wday从星期六算起，代表是在这周中的第几天[0-6]
    #$yday从一月一日算起，代表是在这年中的第几天[0,364]
  # $isdst只是一个flag
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
my $reportFileName= "QA_DailyReport_$timestaemp.txt";
print $reportFileName."\n";
print $timeRegexpString."\n";

open(REPORT,">".$reportFileName) or die $!;

foreach my $file (glob "*.txt")
	{
		#print $file;
		if ($file=~m/QA/)
		{			
		}
		elsif ($file=~m/(.*).txt/)
		{
			my $rwFlag= 0;
			print "Report: ".$1."\n";
			syswrite(REPORT,$1." @ ");		
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
					syswrite(REPORT,$line."\n");					
			   }

			}
		}
	}	
	
	close(REPORT);
	