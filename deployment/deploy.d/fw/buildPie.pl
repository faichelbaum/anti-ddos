#!/usr/bin/perl -w
# buildPie.pl - build a simple pie chart using modified GD::Pie.pm

BEGIN {
        push @INC,"/etc/honeypot";
}

use strict;
use lib qw(./);
use customPie;

if( @ARGV != 1 ){ die "specify an output filename" }

my( @name, @ratio ) = ();
my $filename = $ARGV[0];

chomp($filename);
while(<STDIN>){
  my @parts = split "#", $_;
  push @name, $parts[2];
  push @ratio, $parts[1];
}#while stdin

my $mygraph = GD::Graph::pie->new(600,600);
# colors of the pie slices
$mygraph->set( dclrs => [ "#A8A499","#685E3F","#6C7595","#D8E21F",
                          "#D19126","#B5B87D","#B7C8E2","#DFE3E1" ] );
# color of pie divisors
$mygraph->set( accentclr => '#0000ff');
$mygraph->set( '3d' =>'0');
my @togr = ( [@name], [@ratio] );

my $myimage = $mygraph->plot(\@togr) or die $mygraph->error;

open(IMG, "> $filename.pie.png") or die $1;
  binmode IMG;
  print IMG $myimage->png;
close(IMG);

