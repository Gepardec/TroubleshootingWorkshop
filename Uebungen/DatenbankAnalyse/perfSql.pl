#!/usr/bin/perl -w

#####################################################################
#
# Auswerten von SQL-Log bezueglich Performance
#
# Erstellungs Autor: Erhard Siegl, Herbert Wirnsberger, Adrian Farmadin
# Erstellungs Datum: Oktober 2016
#
#####################################################################


$main::DebugLevel = 0;
my $QuerySize = 200;
my $OptQueries = 0;
my $QueryReplace = 0;

use strict;
use warnings;
use Getopt::Std;

sub printDebug;

my $Usage = <<EOF;

Funktion:
    Auswerten von SQL-Log bezueglich Performance.

usage: perfSql.pl [-q] [-h] [-d n] logfiles

Parameter:
	logfiles: Namen der abzuarbeitenden Logfiles.

Optionen:
	-q: Selektiert Queries
	-s size: Wenn bei -q Queries länger als "size" sind, wird der Teil vor dem FROM entfernt.
		Default: $QuerySize
	-r: Ersetzt ? in den Queries mit den Werten. Es wird automatisch -q aktiviert.
	-h: Aufrufsyntax anzeigen
	-d debuglevel: Debuglevel angeben.

EOF

my $Format;

my %Monate = (
	"Jan" => "01",
	"Feb" => "02",
	"Mar" => "03",
	"Apr" => "04",
	"May" => "05",
	"Jun" => "06",
	"Jul" => "07",
	"Aug" => "08",
	"Sep" => "09",
	"Oct" => "10",
	"Nov" => "11",
	"Dec" => "12"
	);
	
########################## process the options  #########################
my %Opt;
getopts( "qs:rd:h", \%Opt) or die $Usage;

if ( $Opt{d} ){ $main::DebugLevel 	= $Opt{d} }
if ( $Opt{h} ){ print $Usage; exit( 0) }
if ( $Opt{q} ){ $OptQueries = 1 }
if ( $Opt{s} ){ $QuerySize = $Opt{s} }
if ( $Opt{r} ){ $QueryReplace = 1; $OptQueries = 1}

#####################################################################

my $Queries = {};
my $Spy = {};

if ( $OptQueries ){
	while (my $line = <> ){
		doQueries($Queries, $line);
	}
	exit(0);
}

while (my $line = <> ){
	if ($line =~ /jboss.jdbc.spy/){
		doQueries($Spy, $line);		
	}
}
exit(0);
	
###################################################################
##                           doQueries
###################################################################
sub doQueries{
	my (  $Queries, $line ) = @_;

	#17.08.2017 11:05:01,927 +0200 DEBUG [jboss.jdbc.spy] (hs0541 http-/0.0.0.0:8080-1) 14200243 LPCANGA2,333 Lpdanga2 java:/datasources/lgkkDatasource [ResultSet] wasNull()
	#15:17:18,222 DEBUG [jboss.jdbc.spy] (http-localhost/127.0.0.1:8080-257) UseCase[QBG2TM,QBG2TM] java:jboss/datasources/vulkanDS [Connection] prepareStatement(select wahrenachf
	#09:05:28,124 DEBUG [jboss.jdbc.spy] (http-localhost/127.0.0.1:8080-6) UseCase[QBG2TM,QBG2TM] java:jboss/datasources/vulkanDS [PreparedStatement] setLong(1, 40)
	#09:05:28,124 DEBUG [jboss.jdbc.spy] (http-localhost/127.0.0.1:8080-6) UseCase[QBG2TM,QBG2TM] java:jboss/datasources/vulkanDS [PreparedStatement] setBigDecimal(2, 362.87)


#	my $GenFormat = '(..):(..):(..),(...)(.*)? DEBUG \[jboss.jdbc.spy\] \((.*?)\)(.*)';
	my $GenFormat = '(..):(..):(..),(...)(.*)?DEBUG.*\[jboss.jdbc.spy\] \((.*?)\)(.*)';
	return unless $line =~ /jboss.jdbc.spy/;
	printDebug 3, $line;
	my ($hh, $mm, $ss, $ms, $code, $Thread, $Content) = $line =~ /$GenFormat/
		or warn "Can't parse general line: $line\n";
	my $query =  $Queries->{$Thread};

	if ( ! $query ){
		$query = {};
		$Queries->{$Thread} = $query;
	}
	if ( $OptQueries ){
		handleQuery($query, $Content, $hh, $mm, $ss, $ms);
	}
	else{
		handleSpy($query, $Content, $hh, $mm, $ss, $ms);
	}
}

###################################################################
##                           handleQuery
###################################################################
sub handleQuery{
	my $this = shift;
	my ( $Content, $hh, $mm, $ss, $ms) = @_;
	
	my $PrepFormat = 'prepareStatement\((.*)\)';
	my $ExecuteFormat = '\[Connection\] close';
	my $ExecuteBatchFormat = '\[Statement\] executeBatch';
	my $ResultFormat = '\[ResultSet\]';
	my $SetFormat = '\[PreparedStatement\] set.*\((\d+), (.*)\)';
	my $AddBatchFormat = '\[PreparedStatement\] addBatch\(\)';
	
	if ($Content =~ /$PrepFormat/){
		my ( $Query ) = $Content =~ /$PrepFormat/;
		if ( length( $Query ) > $QuerySize && $Query =~ /^select/i ){
			$Query =~ s/^select\s+.*? from /select ... from /i;
		}
		$this->{"inPrepare"} = 1;
		$this->{"Query"} = $Query;
		$this->{"QueryOriginal"} = $Query;
		$this->{"StartTime"} = computeTime($hh, $mm, $ss, $ms);
		$this->{"LineNumber"} = $.;
		return;
	}
	
	if($QueryReplace && $this->{"inPrepare"} && $Content =~ /$SetFormat/ ){
		my ($Position, $Value) = $Content =~ /$SetFormat/;
		
		my $SetTimestampFormat = '\[PreparedStatement\] setTimestamp*\((\d+), (.*), ';
		if($Content =~ /$SetTimestampFormat/){
			($Position, $Value) = $Content =~ /$SetTimestampFormat/;
		}

		$Value="'$Value'";

		my $NullFormat = '\[PreparedStatement\] setNull\(.*\)';

		if($Content =~ /$NullFormat/){
			$Value='null';
		}
		
		$this->{"Replacements"}->{$Position} = $Value
	}
	
	if($QueryReplace && $Content =~ $AddBatchFormat){
		$this->{"StartTime"} = computeTime($hh, $mm, $ss, $ms);
		
		for my $key (sort { $a <=> $b } keys %{$this->{"Replacements"}}){
			my $value = $this->{"Replacements"}->{$key};
        	$this->{"Query"} =~ s/\?/$value/;
		}
		
		printTime($this->{"Query"}, $this->{"LineNumber"}, $this->{"StartTime"}, $hh, $mm, $ss, $ms);
		$this->{"Query"} = $this->{"QueryOriginal"};
	}
	
	if ( $Content =~ /\[Connection\] close/ ){
	
		if ( $QueryReplace ){
			for my $key ( sort { $a <=> $b } keys %{$this->{'Replacements'}} ) {
				my $value = $this->{"Replacements"}->{$key};
        		$this->{"Query"} =~ s/\?/$value/;
    		}
    	}
    			
		printTime($this->{"Query"}, $this->{"LineNumber"}, $this->{"StartTime"}, $hh, $mm, $ss, $ms);
		$this->{"inPrepare"} = 0;
		
		return;
	}		
}

###################################################################
##                           handleSpy
###################################################################
sub handleSpy{
	my $this = shift;
	my ( $Content, $hh, $mm, $ss, $ms) = @_;
		
	# 11:52:17,301 DEBUG [jboss.jdbc.spy] (EJB default - 8) java:jboss/datasources/vulkanDS [PreparedStatement] executeQuery()
	# 11:52:17,302 DEBUG [jboss.jdbc.spy] (EJB default - 8) java:jboss/datasources/vulkanDS [ResultSet] next()
	my $Format = 'java:.*\[.*]\s*(\w*)';
			
	printDebug 4, "Content: $Content";
	my ( $Command ) = $Content =~ /$Format/;

	printDebug 3, "hh=$hh, mm=$mm, ss=$ss, Command=$Command\n"; 
		
	if ( $Content =~ /\[Connection\] prepareStatement/ ){
		$this->{StartTime} = computeTime($hh, $mm, $ss, $ms);
		return;
	}
	if ( $Command =~ /execute/ ){
		$this->{Command} = $Command;
		return;
	}
	if ( $Content =~ /\[Connection\] close/ ){
		printTime($this->{Command}, $., $this->{"StartTime"}, $hh, $mm, $ss, $ms);
		return;
	}
}

###################################################################
##                           printTime
###################################################################
sub printTime{
	my ($Command, $LineNumber, $StartTime, $hh, $mm, $ss, $ms) = @_;
	
	if (!defined $StartTime){
		warn "Keine Startzeit. Wahrscheinlich ein close() ohne prepareStatement(..)";
		return;
	}

	my $Time = computeTime($hh, $mm, $ss, $ms) - $StartTime;
	#my ( $hs ) = $ms =~ /(..)/;
	my $FullTime="$hh$mm$ss$ms";
	my $Day = "00";
		
	print "$Command\t$Time\t$FullTime\t$LineNumber\t$Day\n";
}

###################################################################
##                           computeTime
###################################################################
sub computeTime{
	my ($hh, $mm, $ss, $ms) = @_;
	return (($hh * 60 + $mm ) * 60 + $ss) * 1000 + $ms;
}

###################################################################
##                           getDay
###################################################################
sub getDay{
	my ($Mon, $DD) = @_;
	
	printDebug 5, "Monate{Mon}= $Monate{$Mon}\n";
	return "0000_" . $Monate{$Mon} . "_$DD";
}


###################################################################
##                           getTDay
###################################################################
sub getTDay{
	my ($Date) = @_;

	my @Datum = localtime($Date);
	
	return sprintf( "%04d_%02d_%02d", 
		$Datum[5] + 1900, $Datum[4] + 1, $Datum[3]);
}

###################################################################

###################################################################
##                           getTFullTime
###################################################################
sub getTFullTime{
	my ($Date) = @_;

	my @Datum = localtime($Date);
	
	return sprintf( "%02d%02d%02d00", @Datum[2,1,0]);
}

###################################################################
##                           printDebug                          ##
###################################################################
sub printDebug{
	my ($Level, $Msg) = @_;

	if ( $main::DebugLevel >= $Level ){
		print STDERR $Msg;
	}
}


