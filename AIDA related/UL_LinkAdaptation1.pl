use Win32::OLE;
use Win32::OLE::Variant; 
use Win32::OLE::Const 'Microsoft Excel';
use File::Basename;
use File::Path qw(mkpath);


#command example
#perl test_maxThroughput_result_analysis.pl "C:/traces_for_sherpa_analysis/_2011-02-11_13-52-36/csv_15min/csv" "C:/logFIle.xls"


if ($ARGV[0] eq "")
{
	die("Error: you must specify a directory as the first argument");
}

if ($ARGV[1] eq "")
{
	die("Error: you must specify a analysis file (full path to an xls that will to be created)");
}


# Start Excel and make it visible
$xlApp = Win32::OLE->new('Excel.Application');
$xlApp->{Visible} = 1;
$xlApp->{DisplayAlerts} = "False";

$xlApp->{SheetsInNewWorkBook} = 1;

$csvFile; # = "C:/traces_for_sherpa_analysis/_2011-02-11_13-52-36/csv/csvFile_bearer.csv";



my $count;
my $averageBler;
my $debugLevel = 0;
my $sheetName;
my $timeColumn = "C";
my $rntiColumn = "E";
my $ulColumn = "G";

my $mcsColumn = "G";
my $blerColumn = "H";
my $numberOfPrbColumn = "J";
my $sinrColumn = "M";
my $pathlossColumn = "AD";


my $averageTimeColumn = "A";
my $averageRntiColumn = "B";
my $averageSherpaUlColumn = "C";
my $averageSherpaMCSColumn = "D";
my $averageSherpaBlerColumn = "E";
my $averageSinrColumn = "F";
my $averagePathlossColumn = "G";
my $averagemeanNRPRBColumn= "H";






my $averageSheetName = "Averages";



my $csvDir = $ARGV[0];
$csvDir =~ s/\\/\//g;

$averageFile = $ARGV[1]; # = "C:/average.xls";
$averageFile =~ s/\//\\/g;


my $xlAverageBook;
my $array;
my $averageArray;

my $csvTimeValues;
my $csvUlValues;
my $csvRntiValues;
my $csvMcsValues;
my $csvBlerValues;


my $i;
my $aI;
my $dlAverage;
my @csvFiles;
my $currentLine;
my $currentLine1;



if(substr ($csvDir,-1,1) ne "/")
{
	@csvFiles = <$csvDir/*harq_UL.csv>;
	push(@csvFiles,<$csvDir/*mcs_UL.csv>);
}else
{
	@csvFiles,<$csvDir*harq_UL.csv>;
	push(@csvFiles,<$csvDir*mcs_UL.csv>);
}



if ($#csvFiles != -1)
{
	if (-e "$averageFile")
	{
			if ($debugLevel != 0) {print "opening file: $averageFile.\n";}
		$xlAverageBook = $xlApp->Workbooks->Open($averageFile);
			
		
	}else
	{
	if (!(-d dirname($averageFile)))
		{
		if ($debugLevel != 0) {print "creating directory: " . dirname($averageFile) . ".\n";}
			mkpath(dirname($averageFile)) or die "create reports directory failed - " . $!;
		}
		if ($debugLevel != 0) {print "adding new workbook\n";};
		$xlAverageBook = $xlApp->Workbooks->Add();#new workbook(file new din excel)
			
		#$xlAverageBook->Worksheets->Add( {after =>$xlAverageBook->Worksheets($xlAverageBook->Worksheets->{count})} );	
	         # $xlAverageBook->Worksheets->Add();
		$xlAverageBook->Activesheet-> {Name} = $averageSheetName;
		
		}
	$currentLine = 1;
	$currentLine1 = 2;
	my $averageArray2 = $xlAverageBook->Worksheets($averageSheetName)->Range("A1:A65536")->{'Value'};
	foreachAverage2: foreach my $average_Array (@$averageArray2)
			{
			foreach my $averageScalar (@$average_Array)
				{
				if ($averageScalar eq "")
					{
									
					if($currentLine == 1)
						{
						$xlAverageBook->Worksheets($averageSheetName)->Range($averageTimeColumn . "1")->{'Value'} = "Time";
						$xlAverageBook->Worksheets($averageSheetName)->Range($averageSherpaUlColumn . "1")->{'Value'} = "Sherpa UL Throughput";
						$xlAverageBook->Worksheets($averageSheetName)->Range($averagemeanNRPRBColumn . "1")->{'Value'} = "Average NR of PRB";
						$xlAverageBook->Worksheets($averageSheetName)->Range($averageRntiColumn . "1")->{'Value'} = "RNTI";
						$xlAverageBook->Worksheets($averageSheetName)->Range($averageSherpaMCSColumn . "1")->{'Value'} = "Sherpa MCS";
						$xlAverageBook->Worksheets($averageSheetName)->Range($averageSherpaBlerColumn . "1")->{'Value'} = "Average Sherpa Bler";
						$xlAverageBook->Worksheets($averageSheetName)->Range($averageSinrColumn  . "1")->{'Value'} = "SINR";
						$xlAverageBook->Worksheets($averageSheetName)->Range($averagePathlossColumn  . "1")->{'Value'} = "Pathloss";

											
						$xlAverageBook->Worksheets($averageSheetName)->Range($averageTimeColumn . "1")->{'HorizontalAlignment'} = xlCenter;
						$xlAverageBook->Worksheets($averageSheetName)->Range($averageSherpaUlColumn . "1")->{'HorizontalAlignment'} = xlCenter;
						$xlAverageBook->Worksheets($averageSheetName)->Range($averagemeanNRPRBColumn . "1")->{'HorizontalAlignment'} = xlCenter;
						$xlAverageBook->Worksheets($averageSheetName)->Range($averageRntiColumn . "1")->{'HorizontalAlignment'} = xlCenter;
						$xlAverageBook->Worksheets($averageSheetName)->Range($averageSherpaMCSColumn . "1")->{'HorizontalAlignment'} = xlCenter;
					      	$xlAverageBook->Worksheets($averageSheetName)->Range($averageSherpaBlerColumn . "1")->{'HorizontalAlignment'} = xlCenter;
						$xlAverageBook->Worksheets($averageSheetName)->Range($averageSinrColumn  . "1")->{'HorizontalAlignment'} = xlCenter;

						#$xlAverageBook->Worksheets($averageSheetName)->Range($averageTimeColumn . "1:" . $averageSherpaBlerColumn . "1")->{Columns}->Autofit;
						#$xlAverageBook->Worksheets($averageSheetName)->Columns($averageRntiColumn . ":" . $averageRntiColumn)->EntireColumn->AutoFit;

						
								
						}
						last foreachAverage2;
						
					}
								
				}	
			}
			$currentLine++;

			foreach $csvFile (@csvFiles)
			{	
				
			 if ($csvFile=~ m/harq\_UL/)
			        		                
				{	
				if ($debugLevel != 0) {print ("evaluating harq file \n");}
				$i = 2;
				$aI = 1;
				$csvFile =~ s/\//\\/g;		
				
				
				if ($debugLevel != 0) {print "opening csv file: $csvFile.\n";}
				$csvBook = $xlApp->Workbooks->Open($csvFile) or die "could not open csv file - $csvFile. " . $!;;
				#print "harq  $csvFile";
				if ($debugLevel != 0) {print "selecting range from workbook: " . $csvBook->{Name} . ".\n";}
				$array = $csvBook->ActiveSheet->Range($dlColumn . "2:" . $dlColumn . "65536")->{'Value'};
				$xlAverageBook->Worksheets->Add( {after =>$xlAverageBook->Worksheets($xlAverageBook->Worksheets->{count})} );
				$sheetName = $csvBook->ActiveSheet->Range($timeColumn . "2")->{Value};
				$sheetName =~ s/\//\./g;
				$sheetName =~ s/\:/\-/g;
				if($sheetName eq "")
					{
					$sheetName = "No Values Sheet" . $xlAverageBook->Worksheets->{count};
					}
				$xlAverageBook->ActiveSheet->{Name} = $sheetName;
				
				$xlAverageBook->ActiveSheet->Columns($averageTimeColumn .":" . $averageTimeColumn)->{'Value'} = $csvBook->ActiveSheet->Columns($timeColumn .":" . $timeColumn)->{'Value'};
				$xlAverageBook->Worksheets($sheetName)->Columns($averageTimeColumn .":" . $averageTimeColumn)->{'NumberFormat'} = "dd/mm/yyyy hh:mm:ss";
				$xlAverageBook->ActiveSheet->Columns($averageSherpaUlColumn .":" . $averageSherpaUlColumn)->{'Value'} = $csvBook->ActiveSheet->Columns($ulColumn .":" . $ulColumn)->{'Value'};
				
				$xlAverageBook->ActiveSheet->Columns($averageRntiColumn .":" . $averageRntiColumn)->{'Value'} = $csvBook->ActiveSheet->Columns($rntiColumn .":" . $rntiColumn)->{'Value'};
				
				$xlAverageBook->ActiveSheet->Range($averageSherpaBlerColumn . "1")->{'Value'} = "Average Sherpa Bler";
				



				$xlAverageBook->ActiveSheet->Columns($averageSherpaBlerColumn .":" . $averageSherpaBlerColumn)->{'Value'} = $csvBook->ActiveSheet->Columns($blerColumn .":" . $blerColumn)->{'Value'};
				$xlAverageBook->ActiveSheet->Columns($averageSinrColumn .":" . $averageSinrColumn)->{'Value'} = $csvBook->ActiveSheet->Columns($sinrColumn .":" . $sinrColumn)->{'Value'};
				$xlAverageBook->ActiveSheet->Columns($averagePathlossColumn .":" . $averagePathlossColumn)->{'Value'} = $csvBook->ActiveSheet->Columns($pathlossColumn .":" . $pathlossColumn)->{'Value'};
				$xlAverageBook->ActiveSheet->Columns($averagemeanNRPRBColumn .":" . $averagemeanNRPRBColumn)->{'Value'} = $csvBook->ActiveSheet->Columns($numberOfPrbColumn .":" . $numberOfPrbColumn)->{'Value'};

					
				$xlAverageBook->ActiveSheet->Range($averageTimeColumn . "1")->{'HorizontalAlignment'} = xlCenter;
				$xlAverageBook->ActiveSheet->Range($averageSherpaUlColumn . "1")->{'HorizontalAlignment'} = xlCenter;
				#$xlAverageBook->ActiveSheet->Range($averageUlColumn . "1")->{'HorizontalAlignment'} = xlCenter;
				$xlAverageBook->ActiveSheet->Range($averageRntiColumn . "1")->{'HorizontalAlignment'} = xlCenter;
					

				my @array1;
				my @array0;			

				$pArray = $csvBook->ActiveSheet->Range($pathlossColumn . "2:" . $pathlossColumn . "65536")->{'Value'};
				foreachCSV: foreach my $ref_array (@$pArray)
					{
					foreach my $scalar (@$ref_array)
						{
						if ($scalar eq "")
							{
							last foreachCSV;
							}
						else
						{
						push(@array1, $scalar);
						}
				
						$i++;
						}
					}

				$count = $i;

				$xlAverageBook->ActiveSheet->Columns($averageTimeColumn . ":" . $averagemeanNRPRBColumn)->EntireColumn->AutoFit;

				if ($debugLevel != 0) {print "setting the averages in the final sheet \n";}

				$xlAverageBook->Worksheets($averageSheetName)->Range($averageTimeColumn . $currentLine)->{'Value'} = $xlAverageBook->Worksheets($sheetName)->Range($averageTimeColumn ."2")->{'Value'};		 
				$xlAverageBook->Worksheets($averageSheetName)->Columns($averageTimeColumn .":" . $averageTimeColumn)->{'NumberFormat'} = "dd/mm/yyyy hh:mm:ss";
	
				$xlAverageBook->Worksheets($averageSheetName)->Range($averageSherpaUlColumn . $currentLine)->{'Formula'} = "=AVERAGE('" . $xlAverageBook->Worksheets($sheetName)->{Name} . "'!" . $averageSherpaUlColumn ."2:" . $averageSherpaUlColumn . $count . ")"; 
				$xlAverageBook->Worksheets($averageSheetName)->Range($averageSherpaUlColumn . $currentLine)->{'NumberFormat'} = "0.00";
					
				$xlAverageBook->Worksheets($averageSheetName)->Range($averageSherpaBlerColumn . $currentLine)->{'Formula'} = "=AVERAGE('" . $xlAverageBook->Worksheets($sheetName)->{Name} . "'!" . $averageSherpaBlerColumn ."2:" . $averageSherpaBlerColumn . $count . ")";
				$xlAverageBook->Worksheets($averageSheetName)->Range($averageSherpaBlerColumn . $currentLine)->{'NumberFormat'} = "0.00";

                                $xlAverageBook->Worksheets($averageSheetName)->Range($averagemeanNRPRBColumn . $currentLine)->{'Formula'} = "=AVERAGE('" . $xlAverageBook->Worksheets($sheetName)->{Name} . "'!" . $averagemeanNRPRBColumn ."2:" . $averagemeanNRPRBColumn . $count . ")";			
                                $xlAverageBook->Worksheets($averageSheetName)->Range($averagemeanNRPRBColumn . $currentLine)->{'NumberFormat'} = "0.00";

				$xlAverageBook->Worksheets($averageSheetName)->Range($averageSinrColumn . $currentLine)->{'Formula'} = "=AVERAGE('" . $xlAverageBook->Worksheets($sheetName)->{Name} . "'!" . $averageSinrColumn ."2:" . $averageSinrColumn . $count . ")";
				$xlAverageBook->Worksheets($averageSheetName)->Range($averageSinrColumn . $currentLine)->{'NumberFormat'} = "0.00";

				$xlAverageBook->Worksheets($averageSheetName)->Range($averagePathlossColumn . $currentLine)->{'Formula'} = "=AVERAGE('" . $xlAverageBook->Worksheets($sheetName)->{Name} . "'!" . $averagePathlossColumn ."2:" . $averagePathlossColumn . $count . ")";
				$xlAverageBook->Worksheets($averageSheetName)->Range($averagePathlossColumn . $currentLine)->{'NumberFormat'} = "0.00";

					
				$xlAverageBook->Worksheets($averageSheetName)->Range($averageRntiColumn . $currentLine)->{'Value'} = $xlAverageBook->Worksheets($sheetName)->Range($averageRntiColumn ."2")->{'Value'};
				
				$xlAverageBook->Worksheets($averageSheetName)->Columns($averageTimeColumn . ":" . $averagemeanNRPRBColumn)->EntireColumn->AutoFit;			
				
				
			#	}

			#elsif ($csvFile=~ m/mcs/)
		
			#	{ 
                                $csvFile =~ s/harq/mcs/g;
				if ($debugLevel != 0) {print ("evaluating mcs file \n");}
				$i = 2;
				$csvFile =~ s/\//\\/g;	
					
				if ($debugLevel != 0) {print "opening csv file: $csvFile.\n";}
				$csvBook = $xlApp->Workbooks->Open($csvFile) or die "could not open csv file - $csvFile. " . $!;;
				#print "mcs $csvFile";
				if ($debugLevel != 0) {print "selecting range from workbook: " . $csvBook->{Name} . ".\n";}
				#$array = $csvBook->ActiveSheet->Range($dlColumn . "2:" . $dlColumn . "65536")->{'Value'};
				#xlAverageBook->Worksheets->Add( {after =>$xlAverageBook->Worksheets($xlAverageBook->Worksheets->{count})} );
				#$sheetName = $csvBook->ActiveSheet->Range($timeColumn . "2")->{Value};
				#$sheetName =~ s/\//\./g;
				#$sheetName =~ s/\:/\-/g;
				#print "mcs__$sheetName";
				#if($sheetName eq "")
				#	{
				#	$sheetName = "No Values Sheet" . $xlAverageBook->Worksheets->{count};
				#	}
				#$xlAverageBook->ActiveSheet->{Name} = $sheetName;
		
				$xlAverageBook->Worksheets($sheetName)->Columns($averageSherpaMCSColumn .":" . $averageSherpaMCSColumn)->{'Value'} = $csvBook->ActiveSheet->Columns($mcsColumn .":" . $mcsColumn)->{'Value'};
				$xlAverageBook->Worksheets($sheetName)->Range($averageSherpaMCSColumn . "1")->{'Value'} = "MCS";
				$xlAverageBook->Worksheets($sheetName)->Range($averageSherpaMCSColumn . "1")->{'HorizontalAlignment'} = xlCenter;
				$xlAverageBook->Worksheets($averageSheetName)->Range($averageSherpaMCSColumn . $currentLine)->{'Formula'} = "=AVERAGE('" . $xlAverageBook->Worksheets($sheetName)->{Name} . "'!" . $averageSherpaMCSColumn ."2:" . $averageSherpaMCSColumn . $count . ")"; 
				$xlAverageBook->Worksheets($averageSheetName)->Range($averageSherpaMCSColumn . $currentLine)->{'NumberFormat'} = "0.00";
		
		                $currentLine++;
				}
 			#else
			#{
			#die "CSV Files are not good!!!";
			#}

		}



		# XY Charts
			my @chartTitles = ("Throughput", "MCS & NR of PRBs", "BLER");
			my @chartNames = ("Chart 1", "Chart 2", "Chart 3");
			my @chartYNames = ("kb", "", "%");

			my $pathlossColumnNumber = 7;
			my @series1XColumns = ($pathlossColumnNumber, $pathlossColumnNumber, $pathlossColumnNumber);
			my @series1YColumns = ("3", "4", "5");

			my @series2XColumns = ("not_used", $pathlossColumnNumber, "not_used");
			my @series2YColumns = ("not_used", "8", "not_used");


			my $Chart;

				#delete the charts if they already exist
			if ($xlAverageBook->Worksheets($averageSheetName)->ChartObjects->{count} != 0)
			{
				$xlAverageBook->Worksheets($averageSheetName)->ChartObjects->Delete or die;
			}


			#create the charts
		for (my $chartNumber = 0; $chartNumber <= $#chartTitles; $chartNumber++)
		{

			my @Pos = (200+50*$chartNumber, 100+50*$chartNumber, 690, 400);#left, top, width, height
			$Chart = $xlAverageBook->Worksheets($averageSheetName)->ChartObjects->Add(@Pos)->Chart;
			$Chart->{ChartType} = xlXYScatterLines;
			$Chart->{Name} = $chartNames[$chartNumber];

			$Chart->SeriesCollection->NewSeries;

				#exception: chart number 2 has 2 series
			if ($chartNumber == 1)
			{
				$Chart->SeriesCollection->NewSeries;
				$Chart->SeriesCollection(2)->{Name} = "='" . $averageSheetName . "'!R1C" . $series2YColumns[$chartNumber];
			}

			$Chart->SeriesCollection(1)->{Name} = "='" . $averageSheetName . "'!R1C" . $series1YColumns[$chartNumber];

			$Chart->{HasTitle} = 1;
			$Chart->ChartTitle->{Text} = $chartTitles[$chartNumber];
			$Chart->Axes(xlCategory, xlPrimary)->{HasTitle} = 1;
			$Chart->Axes(xlCategory, xlPrimary)->AxisTitle->{'Text'} = "Pathloss";

			$Chart->Axes(xlValue, xlPrimary)->{HasTitle} = 1;
			$Chart->Axes(xlValue, xlPrimary)->AxisTitle->{'Text'} = $chartYNames[$chartNumber];


			$Chart->SeriesCollection(1)->{'XValues'} = "='" . $averageSheetName . "'!R2C" . $series1XColumns[$chartNumber] . ":R" . $currentLine . "C" . $series1XColumns[$chartNumber];
			$Chart->SeriesCollection(1)->{'Values'} = "='" . $averageSheetName . "'!R2C" . $series1YColumns[$chartNumber] . ":R" . $currentLine . "C" . $series1YColumns[$chartNumber];


			#exception: chart number 2 has 2 series
			if ($chartNumber == 1)
			{
				$Chart->SeriesCollection(2)->{'XValues'} = "='" . $averageSheetName . "'!R2C" . $series2XColumns[$chartNumber] . ":R" . $currentLine . "C" . $series2XColumns[$chartNumber];
				$Chart->SeriesCollection(2)->{'Values'} = "='" . $averageSheetName . "'!R2C" . $series2YColumns[$chartNumber] . ":R" . $currentLine . "C" . $series2YColumns[$chartNumber];
			}
		}
	$xlAverageBook->SaveAs($averageFile) or die "save reports xls failed - " . $!;
	$xlAverageBook->Close;
}else
{
	die "no CSV Files to evaluate!!!";
}

$xlApp->Quit;
$xlAverageBook = 0;
$csvBook = 0;
$xlApp = 0;
print ("All done.");