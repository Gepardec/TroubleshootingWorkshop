#!/usr/bin/perl -w

# Copyright (C) OÖGKK, Linz 2003
#####################################################################
#
# Auswerten von lgkk-Log bezueglich Performance
#
# Erstellungs Autor: Erhard Siegl
# Erstellungs Datum: Dezember 2003
#
# Aenderungshistorie
#
# $Log:   O:/LgkkPvcsDb/archives/System/tools/perfAusw.pl-arc  $
# 
#    Rev 1.5   Jun 01 2011 15:26:52   ckovast
# popeicli -l 1 Format
# 
#    Rev 1.4   12 Oct 2007 14:04:00   sieger
# JavaAdapter Format, Tuxedo Format.
# 
#    Rev 1.3   14 Jul 2004 17:46:28   sieger
# Auch von stdin lesen.
# Format fuer Partner-Logfiles mittels Option -a.
#
#####################################################################


$main::DebugLevel = 0;

use strict;
use Getopt::Std;

sub printDebug;

my $Usage = <<EOF;

Funktion:
    Auswerten von lgkk-Log bezueglich Performance.

usage: perfAusw.pl [-h] [-d n] [-m] [-acjklps] logfiles

Parameter:
	logfiles: Namen der abzuarbeitenden Logfiles.

Optionen:
	-a: Altes Logfileformat ohne Zeit in Hundertstel Sekunden (z.B: Partner)
	-c: Apache Access-Log Format
	-j: Logfiles des Java-Connectors wie z.B. nach ZPV verwendet.
	-k: Logfiles des democlient.py (unvollstaendig)
	-l: Logfiles von LGKK-TA3 mittels EJBLoggingInterceptor erstellt.
	-s: Logfiles von JBoss mit Kategorie jboss.jdbc.spy aktiv.
	-p: Logfiles die mit 'popeicli -l 1' erstellt wurden 
	-t: Logfileformat der Option -r von Tuxedo.
	-m: Verwende Millisekunden statt hs. Nur fuer -l
	-h: Aufrufsyntax anzeigen
	-d debuglevel: Debuglevel angeben.

EOF

my $AltesFormat = 0;
my $JavaAdapterFormat = 0;
my $TuxedoFormat = 0;
my $LgkkTa3Format = 0;
my $DbSpyFormat = 0;
my $DemoCliFormat = 0;
my $AccessLogFormat = 0;
my $Format;
my $StartTag;
my $optP =0;
my $useMilli =0;

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
getopts( "acjklmtpsd:h", \%Opt) or die $Usage;

if ( $Opt{a} ){ $AltesFormat	 	= 1 }
if ( $Opt{c} ){ $AccessLogFormat	= 1 }
if ( $Opt{j} ){ $JavaAdapterFormat	= 1 }
if ( $Opt{k} ){ $DemoCliFormat = 1 }
if ( $Opt{p} ){ $optP = 1; $JavaAdapterFormat	= 1 }
if ( $Opt{l} ){ $LgkkTa3Format = 1 }
if ( $Opt{s} ){ $DbSpyFormat = 1 }
if ( $Opt{t} ){ $TuxedoFormat		= 1 }
if ( $Opt{m} ){ $useMilli		= 1 }
if ( $Opt{d} ){ $main::DebugLevel 	= $Opt{d} }
if ( $Opt{h} ){ print $Usage; exit( 0) }

#####################################################################

die "-m nur gemeinsam mit -l oder -s moeglich" if ( $useMilli && ! ($LgkkTa3Format || $DbSpyFormat));
if ( $JavaAdapterFormat ){
	doJavaAdapter();
	exit(0);
}
if ( $DemoCliFormat ){
	doDemoCliFormat();
	exit(0);
}

if ( $LgkkTa3Format){
	doLgkkTa3Format();
	exit(0);
}

if ( $DbSpyFormat){
	doDbSpyFormat();
	exit(0);
}

if ( $AccessLogFormat ){
	doAccessLogFormat();
	exit(0);
}

if ( $TuxedoFormat ){
	doTuxedo();
	exit(0);
}

my %Times;

if ( $AltesFormat ){
	$Format = ".{13}(.{8})(.{8}).{2}(.{8})(.{6})(.{20})";
	$StartTag = "SP-Start";
}
else{
	$Format = ".{13}(.{8})(.{8}).{2}(.{8})(.{8}).(.{20})";
	$StartTag = "SectionProcess";
}

while ( <> ){
		next if /^$/;

		my ( $Service, $User, $Day, $FullTime, $Label ) = /$Format/;

		$FullTime .= "00" if $AltesFormat;

#		printDebug 3, "$Service, $User, $Day, $FullTime, $Label\n";

		if ( ! $Label ){
			printDebug 1, "Label not Defined: Line $.\n";
			next;
		}

		if ( $Label =~ /$StartTag/ ){
			printDebug 3, "Start $FullTime\n";
			$Times{ $Service} = $FullTime;
		}
		# Datum yyyymmdd in yyyy_mm_dd umwandeln
		$Day =~ s/(.{4})(.{2})(.{2})/$1_$2_$3/;

#		if ( $Label =~ /SP-Exit|SP-Abort/i ){ 
		if ( $Label =~ /SP-Exit/ ){
			printDebug 3, "End $FullTime\n";
			my $Diff = timeDiff( $Times{ $Service}, $FullTime);
			print "$Service\t$Diff\t$FullTime\t$User\t$Day\n";
		}
}


###################################################################
##                           timeDiff
###################################################################
sub timeDiff{
	my ($Start, $End ) = @_;

	my ( $StartStd, $StartMin, $StartSec, $StartHund ) =
		$Start =~ /(..)(..)(..)(..)/;

	my ( $EndStd, $EndMin, $EndSec, $EndHund ) =
		$End =~ /(..)(..)(..)(..)/;

	return ((($EndStd - $StartStd)*60 + ($EndMin - $StartMin))*60 +
			($EndSec - $StartSec))*100 + ( $EndHund - $StartHund);

}

###################################################################
##                           doLgkkTa3Format
###################################################################
sub doLgkkTa3Format{

	printDebug 1, "Analysiere LGKK TA3 Logfile\n"; 
	# 10:52:13,664 INFO  [at.sozvers.stp.lgkk.logging.ejb.EJBLoggingInterceptor] (http-/0.0.0.0:8080-1) 14200292 LZAMAIPR,333 intercepted Lzamaipr.binaryExecuteService (Time:14ms)
	my $Format = '(..):(..):(..),(..).*LoggingInterceptor.*?\)\s*(\w*).*intercepted\s+(\w+).*Time:(\d+)ms';
	while ( <> ){
			next unless /LoggingInterceptor.*intercepted/;
		#chomp;
		printDebug 4, "Line: $_";
		my ( $hh, $mm, $ss, $hs, $User, $Service, $Time ) = /$Format/;
		$User ||= $Service;

		if ( ! $useMilli ){
			$Time = int($Time / 10);
		}
		printDebug 3, "hh=$hh, mm=$mm, ss=$ss, User=$User, "
			. " Service=$Service, Time=$Time\n"; 
			
		my $FullTime="$hh$mm${ss}${hs}";
		my $Day = "00";
		
		print "$Service\t$Time\t$FullTime\t$User\t$Day\n";
	
	}
}

###################################################################
##                           doAccessLogFormat
###################################################################
sub doAccessLogFormat{

	printDebug 1, "Analysiere Apache AccessLog\n"; 
	# Time Taken: 370 370956305 217.149.167.135 - - [27/Sep/2017:08:39:04 +0200] "POST /lagis-s/systemtest/img?type=IMAGE HTTP/1.1" 200 10 "https://shop.ooevv.at/" "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko" "..." "-"
	my $Format = 'Time Taken:\s+\d+\s+(\d+)\s+([\d\.]+).*?\[(.*):(..):(..):(..).*?\] \"(.*?)\" (\d+)';
	while ( <> ){
			next unless /Time Taken:/;
		#chomp;
		printDebug 4, "Line: $_";
		my ( $Time, $User, $Day, $hh, $mm, $ss, $Service, $Rtc ) = /$Format/
 			or die "Cant parse $_\n";
		# next unless $Rtc == 200;
		# next if $Time == 0;
		my $hs = "00";
		my ( $Path ) = $Service =~ /(.*)\?/;
		$Service = $Path || $Service;

		$Time = int($Time / 1000);
		printDebug 3, "hh=$hh, mm=$mm, ss=$ss, User=$User, "
			. " Service=$Service, Time=$Time\n"; 
			
		my $FullTime="$hh$mm${ss}${hs}";
		
		print "$Service\t$Time\t$FullTime\t$User\t$Day\n";
	}
}

###################################################################
##                           doDbSpyFormat
###################################################################
sub doDbSpyFormat{

	printDebug 1, "Analysiere JBoss Logfile mit aktiven JDBC-Spy\n"; 
	# 11:52:17,301 DEBUG [jboss.jdbc.spy] (EJB default - 8) java:/datasources/lgkkDatasource [PreparedStatement] executeQuery()
	# 11:52:17,302 DEBUG [jboss.jdbc.spy] (EJB default - 8) java:/datasources/lgkkDatasource [ResultSet] next()
	
	my $Format = '(..):(..):(..),(...).*java:.*\[.*]\s*(\w*)';
	my $Service = "unbelegt";
	my $inExec = 0;
	my $LastTime = 0;
	while ( <> ){
		next unless /jboss.jdbc.spy/;
		#chomp;
		printDebug 4, "Line: $_";
		my ( $hh, $mm, $ss, $ms, $Command ) = /$Format/;

		my $msTime = (($hh * 60 + $mm ) * 60 + $ss) * 1000 + $ms;
		printDebug 3, "hh=$hh, mm=$mm, ss=$ss, Service=$Service, Time=$msTime\n"; 
			
		if ( $inExec ){
			my $Time  = $msTime - $LastTime;
			if ( ! $useMilli ){
				$Time = int($Time / 10);
			}
			my ( $hs ) = $ms =~ /(..)/;
			my $FullTime="$hh$mm${ss}${hs}";
			my $Day = "00";
			my $User = "unknown";
		
			print "$Service\t$Time\t$FullTime\t$User\t$Day\n";
			$inExec = 0;
		}
		if ( $Command =~ /execute/ ){
			$Service = $Command;
			$inExec = 1;
			$LastTime = $msTime;
		}
	}
}
###################################################################
##                           doDemoCliFormat
###################################################################
sub doDemoCliFormat{

	printDebug 1, "Analysiere DemoCli Logfile\n"; 
	# .+ 2014-06-04 18:47:25.520402   MQQsSAnJiaBSqoBoTuVZGiBp.93fbb220-0513-3a15-92e3-2a758c111336   17154
	my $Format = '(....-..-..)\s+(..):(..):(..).(..).*\t(.*)\t(\d+)';
	while ( <> ){
		next unless /$Format/;
		#chomp;
		my ( $Day, $hh, $mm, $ss, $hs, $User, $Time ) = ( $1, $2, $3, $4, $5, $6, $7 );
		printDebug 4, "Line: $_";

		printDebug 3, "hh=$hh, mm=$mm, ss=$ss, User=$User, "
			. " Time=$Time\n"; 
		$Time = int($Time / 1000);
		my $Service="demo7";	
		my $FullTime="$hh$mm${ss}${hs}";
		
		print "$Service\t$Time\t$FullTime\t$User\t$Day\n";
	
	}
}
###################################################################
##                           doJavaAdapter
###################################################################
sub doJavaAdapter{

	printDebug 1, "Analysiere Java Adaper Logfile\n"; 
	# Zeitmessung: Sep 28 15:50:51 ZPAZUSUC         8 00000 00000
#	my $Format = 'Zeitmessung: (\w+) (..):(..):(..) (\w{8})\s*(\w+)';
	my $Format = "";
	if ($optP == 1) {
		$Format = '(\w+)\s+(\w+)\s+(..):(..):(..) (.{8})\s*(\w+)';
	} else {
		$Format = 'Zeitmessung: (\w+)\s+(\w+)\s+(..):(..):(..) (.{8})\s*(\w+)';
	}
	while ( <> ){
		if ($optP == 1) {
			#nothing
		} else {
			next unless /Zeitmessung/;
		}
		#chomp;
		printDebug 4, "Line: $_";
		my ( $Mon, $DD, $hh, $mm, $ss, $Service, $Time ) = /$Format/;
		printDebug 3, "Mon=$Mon, DD=$DD, hh=$hh, mm=$mm,"
			. " ss=$ss, Service=$Service, Time=$Time\n"; 
			
		if ( $Service =~ /^\s*$/ ){
			$Service = "UNBEKANN";
		}
		my $FullTime="$hh$mm${ss}00";
		my $Day = getDay($Mon, $DD);
		my $User = "AAAAAAAA";
		
		print "$Service\t$Time\t$FullTime\t$User\t$Day\n";
	
	}
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
##                           doTuxedo
###################################################################
sub doTuxedo{

	printDebug 1, "Analysiere Tuxedo Logfile\n"; 
	# @LPCKEYSU   7479538    1191861249   89139092     1191861249   89139139
	my $Format = '@(\w+)\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)';
	while ( <> ){
		next unless /^\@/;
		chomp;
		printDebug 4, "Line: $_\n";
		my ( $Service, $Pid, $SDate, $STime, $EDate, $ETime ) = /$Format/;
		printDebug 3, "Service=$Service, STime=$STime, ETime=$ETime\n"; 
			
		my $Time = $ETime - $STime;
		my $Day = getTDay($EDate);
		my $FullTime = getTFullTime($EDate);
		my $User = "AAAAAAAA";
		
		print "$Service\t$Time\t$FullTime\t$User\t$Day\n";
	
	}
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

