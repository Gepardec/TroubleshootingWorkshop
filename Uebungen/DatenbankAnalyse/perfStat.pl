#!/usr/bin/perl -w

# Copyright (C) OÖGKK, Linz 2003

use strict;
use Getopt::Std;

$main::DebugLevel = 0;

sub printDebug;

my $Usage = <<EOF;
usage: perfStat.pl [-h] [-b hhmm -e hhmm] [-d n] [-v file] [-t mark] [-s] [-m msg_file] file

Beschreibung:
    Liefert Statistiken bezueglich Serviceaufrufen.

Parameter:
    file: Im Format von perfAusw.pl erstellte Datei mit Serviceaufrufen.

Optionen:
    -h: Aufrufsyntax anzeigen
    -d debuglevel: Debuglevel angeben.
    -b beginn: Beginn der ausgewerteten Daten in hhmm
    -e ende: Ende der ausgewerteten Daten in hhmm
	-v file: Schreibt einen Verlauf der Mittelwerte der Serviceaufrufe ueber
		jeweils eine Minute zwischen 5:00 und 17:00 Uhr nach file.
	-s: Verwendet Sekunden statt Minuten bei -v. Beginn und Ende Max und Min
        Minuten der Eingabedaten.
	-m msg_file: Liest die Datei msg_file um Informatinen ueber die
		Messagegroessen in die Auswertung aufzunehmen. Das Format von
		msg_file ist wie das Ergebnis von "dumpsvc.pl -s"
	-t mark: Haengt bei den Ueberschriften jeweils die angegebene Marke an.

EOF


my %Times;
my %Anz;
my %MinuteTimes;
my %MinuteAnz;
my %MsgSize;

my $MinuteFile;
my $MsgFile;

my $GesAnz = 0;
my $GesTime = 0;

my $UseSeconds;
my $Mark = "";
my $Beginn = "0000";
my $Ende = "9999";


########################## process the options  #########################
my %Opt;
getopts( "b:e:m:v:t:sd:h", \%Opt) or die $Usage;

if ( $Opt{b} ){ $Beginn			 	= $Opt{b} }
if ( $Opt{e} ){ $Ende			 	= $Opt{e} }
if ( $Opt{d} ){ $main::DebugLevel 	= $Opt{d} }
if ( $Opt{v} ){ $MinuteFile 		= $Opt{v} }
if ( $Opt{s} ){ $UseSeconds 		= 1 }
if ( $Opt{m} ){ $MsgFile 			= $Opt{m} }
if ( $Opt{t} ){ $Mark 				= $Opt{t} }
if ( $Opt{h} ){ print $Usage; exit( 0) }

#####################################################################

$Beginn .= "0000";
$Ende .= "9999";

while ( <> ){

	my ( $Service, $Time, $Uhrzeit ) = split( '\t' );

	( $Uhrzeit ) = $Uhrzeit =~ /(.{8})/;
	next if $Uhrzeit < $Beginn;
	next if $Uhrzeit > $Ende;


	$Times{ $Service} |= 0;

	$Times{ $Service} += $Time;
	++$Anz{ $Service};

	$GesTime += $Time;
	++$GesAnz;

	my $Minute;
	if ( $UseSeconds ){
		( $Minute ) = $Uhrzeit =~ /(.{6})/;
	}
	else{
		( $Minute ) = $Uhrzeit =~ /(.{4})/;
	}

	printDebug 3, "Minute: >$Minute<\n";

	$MinuteTimes{ $Minute} |= 0;

	$MinuteTimes{ $Minute} += $Time;
	++$MinuteAnz{ $Minute};
}

if ( $MsgFile ){
	%MsgSize = getMsgSize( $MsgFile);
}

print "Service${Mark}\tDurchschn${Mark}\tAnz${Mark}\tGesamt${Mark}";
if ( $MsgFile ){
	print "\tMSize\tGesSize";
}
	print "\n";
foreach my $Service ( keys %Times ){

	my $Durchschn = sprintf "%d", $Times{ $Service} / $Anz{ $Service};

	my $MSize = 0;
	my $GesSize = 0;
	if ( $MsgSize{ $Service} ){
		$MSize = $MsgSize{ $Service};
		$GesSize = $MSize * $Anz{ $Service};
	}
	print "$Service\t$Durchschn\t$Anz{ $Service}\t$Times{ $Service}";
	if ( $MsgFile ){
		print "\t$MSize\t$GesSize";
	}
	print "\n";

}

my $Durchschn = sprintf "%d", $GesTime / $GesAnz;
print "Gesamt  \t$Durchschn\t$GesAnz\t$GesTime\n";


if ( $MinuteFile ){
	if ( $UseSeconds ){
		printSecondsFile( $MinuteFile, \%MinuteTimes, \%MinuteAnz);
	}
	else{
		printMinuteFile( $MinuteFile, \%MinuteTimes, \%MinuteAnz);
	}
}


###################################################################
##                           printMinuteFile
###################################################################
sub printMinuteFile{
	my ($MinuteFile, $pMinuteTimes, $pMinuteAnz ) = @_;

	open( MINUTEFILE, ">$MinuteFile")
		or die "Can't open File $MinuteFile for writing: $!\n";

	print MINUTEFILE "Uhrzeit${Mark}\tDurchschn${Mark}\tAnz${Mark}\tGesamt${Mark}\n";
	foreach my $Std (5..17) {
		foreach my $Min (0..59){

			my $Time 	= sprintf "%2.2d%2.2d", $Std, $Min;
			my $SumTime = $pMinuteTimes->{ $Time} || 0;
			my $Anz 	= $pMinuteAnz->{ $Time} || 0;
			my $Durch = 0;
			if ( $Anz ){
				$Durch   = sprintf "%d", $SumTime / $Anz;
			}

			print MINUTEFILE "$Time\t$Durch\t$Anz\t$SumTime\n";
		}
	}
	close(MINUTEFILE);
}


###################################################################
##                           printSecondsFile
###################################################################
sub printSecondsFile{
	my ($MinuteFile, $pMinuteTimes, $pMinuteAnz ) = @_;

	open( MINUTEFILE, ">$MinuteFile")
		or die "Can't open File $MinuteFile for writing: $!\n";

	print MINUTEFILE "Uhrzeit${Mark}\tDurchschn${Mark}\tAnz${Mark}\tGesamt${Mark}\n";
	my ( $B, $E ) = (sort keys %$pMinuteTimes)[0, -1];
	printDebug 2, "Schreibe Sekunden von $B bis $E\n";
	my ( $BStd, $BMin ) = $B =~ /(..)(..)/;
	my ( $EStd, $EMin ) = $E =~ /(..)(..)/;
	printDebug 4, "Beginn / Ende: $BStd, $BMin, $EStd, $EMin\n";


	foreach my $Std ($BStd..$EStd) {
		foreach my $Min (0..59){
			next if ( $Std == $BStd && $Min < $BMin );
			last if ( $Std == $EStd && $Min > $EMin );

			foreach my $Sec (0..59){

				my $Time 	= sprintf "%2.2d%2.2d%2.2d", $Std, $Min, $Sec;
				my $SumTime = $pMinuteTimes->{ $Time} || 0;
				my $Anz 	= $pMinuteAnz->{ $Time} || 0;
				my $Durch = 0;
				if ( $Anz ){
					$Durch   = sprintf "%d", $SumTime / $Anz;
				}

				print MINUTEFILE "$Time\t$Durch\t$Anz\t$SumTime\n";
			}
		}
	}

	close(MINUTEFILE);
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
##                           getMsgSize
###################################################################
sub getMsgSize{
	my ( $MsgFile ) = @_;

	my %MsgSize;

	open( MSGFILE, "<$MsgFile")
		or die "Can't open File $MsgFile for writing: $!\n";

	while( <MSGFILE> ){
		my ( $LName, $SName, $Req, $Res ) = split( '\t')
			or die "Can't parse $MsgFile Line >$_<\n";

		$MsgSize{ $SName} = $Req + $Res;
	}

	close( MSGFILE);

	return %MsgSize;
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

