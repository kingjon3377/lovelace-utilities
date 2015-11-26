#!/usr/bin/perl
open(FILE1,$ARGV[0]);
my ($parnumber,$f)=(0,0);
my $paragraph=1;
while ($f=(FILE))
{
for(my $i=0; $i<$paragraph; $i++)
{ last if(!($f .=(FILE1))); };
print $parnumber . "\n";
my $filename=sprintf("temp%05d",$parnumber);
open(TEXTIN,"|text2wave -F 44100 -o $filename.wav -mode nil");
print TEXTIN $f;
close(TEXTIN);
system("lame $filename.wav $filename.mp3");
$parnumber++;
system("touch $ARGV[1] && cat $filename.mp3 >> $ARGV[1] && rm $filename.*");
};
