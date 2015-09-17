#!/usr/perl
use utf8;
use strict;
use File::stat;
use File::Copy;
use File::Basename;
use Data::Dumper;
use Encode;

#获取系统路径并切换路径
my $work_path =  dirname(__FILE__);
chdir $work_path or die $!;

opendir(DIR, $work_path."//DailyReport") or die $!;
my @filename = readdir(DIR);
#print Dumper(@filename);
@filename= sort {$a cmp $b} @filename; 
#print Dumper(@filename);
my $archiveFolder = "Archived";

#my %teamOrg = ('AT',"Automation",'ST',"System_Test",'MT',"Mobile_Test");
my %teamOrg = ('AT',"Automation",'ST',"System_Test");

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
my $timestamp = $date->{dateF};#获取yyyymmdd这样的日期
my $timeRegexpString= $date->{date};
my %detail;
my %counter;

foreach my $t (keys %teamOrg)
{
	$counter{$t}{'updated'}=0;
	$counter{$t}{'profile'}=0;
	$counter{$t}{'ReportFile'}="QA_".$teamOrg{$t}."_DailyReport_$timestamp.txt";
	open($counter{$t}{'fileHandler'},">".$counter{$t}{'ReportFile'}) or die $!;
}
#print Dumper(%counter);
chdir $work_path."//DailyReport" or die "Can't find path DailyReport".$!;

#foreach my $file (glob "*.txt")
foreach my $file (@filename)
	{
		#print $file;
		if ($file=~m/(.*)_(.*).txt/)
		{		
			my $team = $1;
			my $teamMember = $2;
			next if not exists($teamOrg{$team});
			my $teamFullName = $teamOrg{$1};
			my $rwFlag= 0;
			my $submitFlag = 0;
			$counter{$team}{'profile'}++;
			syswrite($counter{$team}{'fileHandler'},$teamMember." @ ") or die "Can't write report file".$!;
			open FILE, $file or die $!;
			chomp (my @lines = (<FILE>));
			close(FILE);
			
			foreach my $line (@lines)
			{
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
					syswrite($counter{$team}{'fileHandler'},$line."\r\n") or die "Can't write report file".$!;
					$submitFlag=1;
			   }				
			}
			if ($submitFlag == 0)
			{
				$detail{"NotUpdate"}{$teamMember}{"status"}="Not Submit";
				$detail{"NotUpdate"}{$teamMember}{"team"}=$teamOrg{$team};
				syswrite($counter{$team}{'fileHandler'},"\r\n") or die "Can't write report file".$!;
			}
			else
			{
				$counter{$team}{'updated'}++;
				$detail{"Updated"}{$team}{$teamMember}{"status"}="Updated";	
				$detail{"Updated"}{$team}{$teamMember}{"team"}=$teamOrg{$team};
			}
			syswrite($counter{$team}{'fileHandler'},"\r\n") or die "Can't write report file".$!;
		}
		else
		{
		next;
			}
	}
#print Dumper(%detail);	
my ($dname, $dteam, $dstatus);
my $updatedHash = $detail{"Updated"};
my $notUpdateHash = $detail{"NotUpdate"};
my $updated_size=keys%$updatedHash;
my $notupdated_size = keys%$notUpdateHash;
#print Dumper($updatedHash);

foreach my $teamHash (sort {$b cmp $a} keys %$updatedHash){
	my $updateTeamHash =  $detail{"Updated"}{$teamHash};
	#print Dumper($updateTeamHash);
	foreach my $name (sort {$b cmp $a} keys %$updateTeamHash)
	{
		($dname, $dteam, $dstatus)= ($name,$detail{"Updated"}{$teamHash}{$name}{"team"},$detail{"Updated"}{$teamHash}{$name}{"status"});
		$^ = 'STDOUT_TOP';
		$~ = 'STDOUT';
		write or die "Error",$!;
	}
}
print "------------------------------------------------------------------\n"  if ($updated_size!=0 or $notupdated_size!=0);
foreach my $name (sort {$b cmp $a} keys %$notUpdateHash)
{
	($dname, $dteam, $dstatus)= ($name,$detail{"NotUpdate"}{$name}{"team"},$detail{"NotUpdate"}{$name}{"status"});
	$^ = 'STDOUT_TOP';
	$~ = 'STDOUT';
	write or die "Error",$!;
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
print "------------------------------------------------------------------\n";
foreach my $t (keys %teamOrg)
{
	close($counter{$t}{'fileHandler'});
	print $t,": ",$counter{$t}{"updated"},"/",$counter{$t}{"profile"},"\n";
}
print "------------------------------------------------------------------\n";


chdir $work_path or die $!;
mkdir $archiveFolder unless -e $archiveFolder;

opendir(DIR, $work_path) or die $!;
my @filename = readdir(DIR);
foreach my $file (@filename)
{
	if ($file=~m/^QA.*.txt/){
	#print $file."\n";
	my $source = $work_path ."\\".$file;
	my $dest = $work_path ."\\".$archiveFolder."\\".$file;
	move ($work_path ."/".$file,$dest)  unless $file =~m/$timestamp/;
	}	
}
system("pause");
