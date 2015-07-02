#!/usr/bin/perl -w
use strict;
use File::Find;
use Win32::OLE;
use Win32::OLE::Const 'Microsoft Excel';
use File::Copy;
use Cwd;
use strict;
use warnings;
no warnings qw(once);
use Win32;
use Win32::Process;
use Net::FTP;

our $Duration = $ARGV[0];


#=======================================================================================
# Options
#=======================================================================================
my $CurrentLogDir = getcwd;            #put log folders in current directory

#=======================================================================================
# get already active Excel application or open new
#=======================================================================================
my $Excel = Win32::OLE->GetActiveObject('Excel.Application')
|| Win32::OLE->new('Excel.Application', 'Quit');
#=======================================================================================
# open Excel file
#=======================================================================================
my $Book = $Excel->Workbooks->Open("$CurrentLogDir/CS_Result.xlsx");
my $Result = $Book->Worksheets('Result');
my $RowIndex = 1;

sub getTime
{
    my $time = shift || time();
    
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
    
    $mon ++;
    $sec  = ($sec<10)?"0$sec":$sec;
    $min  = ($min<10)?"0$min":$min;
    $hour = ($hour<10)?"0$hour":$hour;
    $mday = ($mday<10)?"0$mday":$mday;
    $mon  = ($mon<10)?"0$mon":$mon;
    $year += 1900;
  
    my $weekday = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat')[$wday];
    return { 'second' => $sec,
             'minute' => $min,
             'hour'   => $hour,
             'day'    => $mday,
             'month'  => $mon,
             'year'   => $year,
             'weekNo' => $wday,
             'wday'   => $weekday,
             'yday'   => $yday,
             'date'   => "$year$mon$mday",
			 'Ttime'  => "$hour$min$sec"
          };
}
my $date = &getTime();
my $ymd = $date->{date};
my $hms = $date->{Ttime};
my $year=$date->{year};
my $month=$date->{month};
my $day=$date->{day};

mkdir( "C:/Dropbox", 0777 ); 
mkdir( "C:/Dropbox/Liuzheng", 0777 ); 
mkdir( "C:/Dropbox/Liuzheng/$month-$day", 0777 ); 
mkdir( "C:/Dropbox/Liuzheng/$month-$day/$ymd-$hms", 0777 ); 
mkdir( "C:/Dropbox/Liuzheng/$month-$day/$ymd-$hms/Fail", 0777 ); 
mkdir( "C:/Dropbox/Liuzheng/$month-$day/$ymd-$hms/Success", 0777 );
copy ("$CurrentLogDir/CS_Result.xlsx","C:/Dropbox/Liuzheng/$month-$day/$ymd-$hms");
#print "Successfully copy to C:/Dropbox/Liuzheng/$month-$day/$ymd-$hms\n";

while($RowIndex <= $Duration)
{
	my $str1 = $Result->Cells($RowIndex+1,1)->{'Value'};
	my $str2 = substr($str1,18,length($str1)-18);
	
	$Result->Cells($RowIndex+1,1)->{'Value'} =  substr($str2,0,length($str2)-4);
	$Result->Cells($RowIndex+1,1)->{'Formula'} =  substr($str2,0,length($str2)-4);
	
	my $str3 = $Result->Cells($RowIndex+1,1)->{'Value'};
	if($Result->Cells($RowIndex+1,2)->{'Formula'} =~ /Fail/)
	{
		rename("$CurrentLogDir/$str3","$CurrentLogDir/Fail_$str3");
		move ("$CurrentLogDir/Fail_$str3","C:/Dropbox/Liuzheng/$month-$day/$ymd-$hms/Fail");
		#print "Successfully move $str3 to C:/Dropbox/Liuzheng/$month-$day/$ymd-$hms/Fail\n";
	}
	elsif($Result->Cells($RowIndex+1,2)->{'Formula'} =~ /Success/)
	{
		move ("$CurrentLogDir/$str3","C:/Dropbox/Liuzheng/$month-$day/$ymd-$hms/Success");
		#print "Successfully move $str3 to C:/Dropbox/Liuzheng/$month-$day/$ymd-$hms/Success\n";
	}
	$RowIndex++;
}
unlink glob "C:/Users/zhengliu/Desktop/test/CS_Call_*.txt";
#print "TXT file delete complete\n",

$Book->Save();
$Book->Close;
copy ("$CurrentLogDir/CS_Result.xlsx","C:/Dropbox/Liuzheng/$month-$day/$ymd-$hms/Fail");
#print "Successfully copy to C:/Dropbox/Liuzheng/$month-$day/$ymd-$hms/Fail\n";
