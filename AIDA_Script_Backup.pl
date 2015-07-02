use strict;
use File::Copy;



my $ET_script_location = "C:\\EasyTest\\2012-08-14_08-22-29\\workspace\\tc";
my $backup_path = "C:\\EasyTest\\2012-08-14_08-22-29\\workspace\\tc\\backup\\AIDA_RPI_TEST_DEV";
my $fileName = "AIDA_WCDMA_RPI_dev_0_1.tc";

mkdir  $backup_path unless (-e $backup_path);
my ($min,$hour,$mday,$mon,$year) = (localtime(time))[1,2,3,4,5];
    $year += 1900;
#在所有单数的日期或者时间的字符串前面加0补齐
if  ($min < 10){ $min = "0".$min;}
if  ($hour < 10){$hour = "0".$hour;}
if  ($mday < 10){$mday = "0".$mday;}
if  ($mon < 10 ){$mon = "0".$mon;}
#生成时间戳
my $TimeStamp = $year.$mon.$mday.'_'.$hour.'_'.$min;

chdir $ET_script_location;
print "DIR change to\n$backup_path\n";
print $fileName."BACKUP_".$TimeStamp."\n";
copy ($fileName,$backup_path."\\".$fileName.".BACKUP_".$TimeStamp);
print "All done.\n";
