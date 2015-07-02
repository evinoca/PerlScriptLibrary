    #!/usr/bin/perl
    use strict;
    #use warnings;
    die "Usage : perl $0 <KEY.list> <key_word> <count.txt>\n"unless(@ARGV==3);
    open(IN,$ARGV[0])or die $!;
    my $key_word=$ARGV[1];
    open(OUT1,">$ARGV[2]") or die "could not open file!";
    open(OUT,">result_abstract.tmp.v2") or die "could not open file!";
    #perl **.pl  KEY.list  count.txt
    my %has;
    my @key;
    my %notkey;
    while(<IN>){
            chomp (my $tmp=$_);
       my ($key,$notkey,$a2)=split(/\s+/,$tmp);
             $key=[        DISCUZ_CODE_0        ] if($key=~/\w+.*\w+/);
            $notkey=[        DISCUZ_CODE_0        ] if($notkey=~/\w+.*\w+/);
            $has{$key}=$tmp;
            $notkey{$key}=$notkey;
            push @key,$key;
    }





    sub ask_user {
      print "$_[0] [$_[1]]: ";
      my $rc = <>;
      chomp $rc;
      if($rc eq "") { $rc = $_[1]; }
      return $rc;
    }

    # ---------------------------------------------------------------------------
    # Define library for the 'get' function used in the next section.
    # $utils contains route for the utilities.
    # $db, $query, and $report may be supplied by the user when prompted;
    # if not answered, default values, will be assigned as shown below.

    use LWP::Simple;

    my $utils = "http://www.ncbi.nlm.nih.gov/entrez/eutils";
    my $num;
    # ---------------------------------------------------------------------------
    # $esearch cont羒ns the PATH & parameters for the ESearch call
    # $esearch_result containts the result of the ESearch call
    # the results are displayed 羘d parsed into variables
    # $Count, $QueryKey, and $WebEnv for later use and then displayed.
    foreach my $key (@key){
    my        $db="Pubmed";
    my $report="abstract";
    my $query ="($key NOT $notkey{$key})AND $key_word";
    my $esearch = "$utils/esearch.fcgi?" .
                  "db=$db&retmax=1&usehistory=y&term=";
    $num++;
            #print "$key\t$num\n";
            print "$query\t$num\n";
    my $esearch_result = get($esearch . $query);

    $esearch_result =~
      m|<Count>(\d+)</Count>.*<QueryKey>(\d+)</QueryKey>.*<WebEnv>(\S+)</WebEnv>|s;

    my $Count    = $1;
    my $QueryKey = $2;
    my $WebEnv   = $3;
    $has{$key}=[        DISCUZ_CODE_0        ] if($has{$key}=~/\w+.*\w+/);
    print OUT1 "$has{$key}\tQuery \: $query \tpubmed_count\t$Count\n";
    # ---------------------------------------------------------------------------
    # this area defines a loop which will display $retmax citation results from
    # Efetch each time the the Enter Key is pressed, after a prompt.

    my $retstart;
    my $retmax=$Count;

    for($retstart = 0; $retstart < $retmax; $retstart += $retmax) {
      my $efetch = "$utils/efetch.fcgi?" .
                   "rettype=$report&retmode=text&retstart=$retstart&retmax=$retmax&" .
                   "db=$db&query_key=$QueryKey&WebEnv=$WebEnv";
           

      my $efetch_result = get($efetch);
      
      print OUT "---------\nQuery\: $key\t$Count\t$query\nEFETCH RESULT(".
             ($retstart + 1) . ".." . ($retstart + $retmax) . "): ".
            "[$efetch_result]\n-----PRESS ENTER!!!-------\n";
      ;
    }
    }
    close OUT;