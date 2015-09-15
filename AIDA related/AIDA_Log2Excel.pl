    #!/usr/bin/perl
    
    use strict;
    use warnings;
	use Win32::OLE qw(in with);
	use Win32::OLE::Const 'Microsoft Excel';
	$Win32::OLE::Warn = 3; 

    use utf8;
    use Win32::OLE qw(CP_UTF8);
    Win32::OLE->Option(CP => CP_UTF8);

	#Define 
	my $row_counter_ping=5;
    my $row_counter_ftp=5;

	my $columns_counter=3;
    my $filename="AIDA_TestCase_Log.txt";
	my $Excel = Win32::OLE->GetActiveObject('Excel.Application')
	    || Win32::OLE->new('Excel.Application', 'Quit');  
    $Excel->{Visible} = 0;

	#Open Sheet    
    my $Book = $Excel->Workbooks->Add();
	my $Sheet = $Book->WorkSheets(1);
    $Sheet -> Activate;
    $Sheet->{Name} = "AIDA_RPI_Single_UE";

    #Get TimeStamp
    my ($min,$hour,$mday,$mon,$year) = (localtime(time))[1,2,3,4,5];
        $year += 1900;

    #Place 0 before single character
    if  ($min < 10){ $min = "0".$min;}
    if  ($hour < 10){$hour = "0".$hour;}
    if  ($mday < 10){$mday = "0".$mday;}
    if  ($mon < 10 ){$mon = "0".$mon;}

    my $str = $hour.'_'.$min.'_'.$mon.'_'.$mday.'_'.$year;
    
    my $saveLogName = "AIDA_RPI_TEST_".$str.".xlsx";

    print "Test Result has been Saved as :",$saveLogName," in Default Path." ;
    #Save WorkSheet
    $Book->SaveAs($saveLogName);    

    #Set Chart Title
    $Sheet->Range("B3:G3")->Font->{Name} = "Arial";
    $Sheet->Range("B3:G3")->Font->{Bold} = "True";
    $Sheet->Range("B3:G3")->Font->{Size} = "9";
    $Sheet->Range("B3:G3")->Font->{Color} = "1";

    $Sheet->Range("I3:N3")->Font->{Name} = "Arial";
    $Sheet->Range("I3:N3")->Font->{Bold} = "True";
    $Sheet->Range("I3:N3")->Font->{Size} = "9";
    $Sheet->Range("I3:N3")->Font->{Color} = "1";
     
    $Sheet->Cells(3,2)->{Value}="AIDA_RPI_Automated_Test_SingleUE_Result_Ping_".$str; 
    $Sheet->Range("B3:G3") -> Merge;
    $Sheet->Cells(3,9)->{Value}="AIDA_RPI_Automated_Test_SingleUE_Result_THP_".$str; 
    $Sheet->Range("I3:N3") -> Merge;


    #Title for Ping Result
    $Sheet->Cells(4,7)->{Value}="Maximun"; 
    $Sheet->Cells(4,6)->{Value}="Minimun"; 
    $Sheet->Cells(4,5)->{Value}="Average"; 
    $Sheet->Cells(4,4)->{Value}="Packet"; 
    #Title for THP Result
    $Sheet->Cells(4,11)->{Value}="MaxRate"; 
    $Sheet->Cells(4,12)->{Value}="MinRate"; 
    $Sheet->Cells(4,13)->{Value}="Average"; 
    $Sheet->Cells(4,14)->{Value}="DataTransfered"; 


    #read buffer and regexp on everyline
    open (Buffer,$filename) or die "$!";
    while (<Buffer>) 
    {
            if ($_=~m/caseName:\s(\S+)\s+Ping Maximun Time: (\S+) ms     Ping Minimun Time: (\S+)     AVERAGE: (\S+) ms\s+\S+\s+\S+\s+\S+\s+\S+\s+PacketSize:\s+(\S+)/)
 			{
                   # print "UE Type: ".5"  "."Ping Maximun Time: ".$2." "."Ping Minimun Time: ".$3." AVERAGE: ".$4."\n";
                    #print $_;    
                    $Sheet->Cells($row_counter_ping,2)->{Value}="Case Name:"; 
                    $Sheet->Cells($row_counter_ping,3)->{Value}=$1;                     
                    $Sheet->Cells($row_counter_ping,5)->{Value}=$2."ms";                     
                    $Sheet->Cells($row_counter_ping,6)->{Value}=$3."ms";                     
                    $Sheet->Cells($row_counter_ping,7)->{Value}=$4."ms";                     
                    $Sheet->Cells($row_counter_ping,4)->{Value}=$5; 
                    $row_counter_ping++;                                
            }
            
            if ($_=~m/caseName:(\S+)\s+MaxRate:(\S+)\s+\S+\s+MinRate:(\S+)\s+\S+\s+AverageRate:\s+(\S+)\s+\S+\s+(\w+)DataSize:(\S+)\s+\S+/)
            {
            	 #print "UE Type: ".$1."  "."Ping Maximun Time: ".$2." "."Ping Minimun Time: ".$3." AVERAGE: ".$4."\n";
                    #print $_;    
                    $Sheet->Cells($row_counter_ftp,9)->{Value}="Case Name:"; 
                    $Sheet->Cells($row_counter_ftp,10)->{Value}=$1;                     
                    $Sheet->Cells($row_counter_ftp,11)->{Value}=$2."kbps";                     
                    $Sheet->Cells($row_counter_ftp,12)->{Value}=$3."kbps";                     
                    $Sheet->Cells($row_counter_ftp,13)->{Value}=$4."kbps"; 
                    $Sheet->Cells($row_counter_ftp,14)->{Value}=$6." MB"; 
                    $row_counter_ftp++;    
            }


    }
    #row counter is one more than fact, because counter++ runs for an extra time
    $row_counter_ping-=1;
    $row_counter_ftp-=1;
    #set Sheet format
    $Sheet->Range('A4','R'.$row_counter_ping)->Font->{Name} = "Arial";
    $Sheet->Range('A4','R'.$row_counter_ping)->Font->{FontStyle} = "Regular";
    $Sheet->Range('A4','R'.$row_counter_ping)->Font->{Size} = "9";
    $Sheet->Range('A4','R'.$row_counter_ping)->Columns->AutoFit();

    #Add Border for both ping result and ftp result chat
    $Sheet -> Range('B3','G'.$row_counter_ping) -> Borders(xlEdgeBottom)       -> {LineStyle}  = xlDouble;
    $Sheet -> Range('B3','G'.$row_counter_ping) -> Borders(xlEdgeBottom)       -> {Weight}     = xlThick;
    $Sheet -> Range('B3','G'.$row_counter_ping) -> Borders(xlEdgeBottom)       -> {ColorIndex} = 1;
    $Sheet -> Range('B3','G'.$row_counter_ping) -> Borders(xlEdgeLeft)         -> {LineStyle}  = xlContinuous;
    $Sheet -> Range('B3','G'.$row_counter_ping) -> Borders(xlEdgeLeft)         -> {Weight}     = xlThin;
    $Sheet -> Range('B3','G'.$row_counter_ping) -> Borders(xlEdgeTop)          -> {LineStyle}  = xlContinuous;
    $Sheet -> Range('B3','G'.$row_counter_ping) -> Borders(xlEdgeTop)          -> {Weight}     = xlThin;
    $Sheet -> Range('B3','G'.$row_counter_ping) -> Borders(xlEdgeBottom)       -> {LineStyle}  = xlContinuous;
    $Sheet -> Range('B3','G'.$row_counter_ping) -> Borders(xlEdgeBottom)       -> {Weight}     = xlThin;
    $Sheet -> Range('B3','G'.$row_counter_ping) -> Borders(xlEdgeRight)        -> {LineStyle}  = xlContinuous;
    $Sheet -> Range('B3','G'.$row_counter_ping) -> Borders(xlEdgeRight)        -> {Weight}     = xlThin;
    $Sheet -> Range('B3','G'.$row_counter_ping) -> Borders(xlInsideVertical)   -> {LineStyle}  = xlContinuous;
    $Sheet -> Range('B3','G'.$row_counter_ping) -> Borders(xlInsideVertical)   -> {Weight}     = xlThin;
    $Sheet -> Range('B3','G'.$row_counter_ping) -> Borders(xlInsideHorizontal) -> {LineStyle}  = xlContinuous;
    $Sheet -> Range('B3','G'.$row_counter_ping) -> Borders(xlInsideHorizontal) -> {Weight}     = xlThin;

    $Sheet -> Range('I3','N'.$row_counter_ftp) -> Borders(xlEdgeBottom)       -> {LineStyle}  = xlDouble;
    $Sheet -> Range('I3','N'.$row_counter_ftp) -> Borders(xlEdgeBottom)       -> {Weight}     = xlThick;
    $Sheet -> Range('I3','N'.$row_counter_ftp) -> Borders(xlEdgeBottom)       -> {ColorIndex} = 1;
    $Sheet -> Range('I3','N'.$row_counter_ftp) -> Borders(xlEdgeLeft)         -> {LineStyle}  = xlContinuous;
    $Sheet -> Range('I3','N'.$row_counter_ftp) -> Borders(xlEdgeLeft)         -> {Weight}     = xlThin;
    $Sheet -> Range('I3','N'.$row_counter_ftp) -> Borders(xlEdgeTop)          -> {LineStyle}  = xlContinuous;
    $Sheet -> Range('I3','N'.$row_counter_ftp) -> Borders(xlEdgeTop)          -> {Weight}     = xlThin;
    $Sheet -> Range('I3','N'.$row_counter_ftp) -> Borders(xlEdgeBottom)       -> {LineStyle}  = xlContinuous;
    $Sheet -> Range('I3','N'.$row_counter_ftp) -> Borders(xlEdgeBottom)       -> {Weight}     = xlThin;
    $Sheet -> Range('I3','N'.$row_counter_ftp) -> Borders(xlEdgeRight)        -> {LineStyle}  = xlContinuous;
    $Sheet -> Range('I3','N'.$row_counter_ftp) -> Borders(xlEdgeRight)        -> {Weight}     = xlThin;
    $Sheet -> Range('I3','N'.$row_counter_ftp) -> Borders(xlInsideVertical)   -> {LineStyle}  = xlContinuous;
    $Sheet -> Range('I3','N'.$row_counter_ftp) -> Borders(xlInsideVertical)   -> {Weight}     = xlThin;
    $Sheet -> Range('I3','N'.$row_counter_ftp) -> Borders(xlInsideHorizontal) -> {LineStyle}  = xlContinuous;
    $Sheet -> Range('I3','N'.$row_counter_ftp) -> Borders(xlInsideHorizontal) -> {Weight}     = xlThin;
 

    
	# Save and Close
#    $Excel->{DisplayAlert} = 0;
    $Book->Save();
    $Book->Close();
    $Excel->Quit();
    
    
