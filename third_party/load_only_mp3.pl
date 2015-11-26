#!/usr/bin/perl -w
use strict;

# A program which accepts commandline args, and writes .mp3 files into
# a USB Mass Storage MP3 player.
#
# Usage:
#       $ loadmp3.pl [-check] filenames
#
# If the -check flag is enabled, the ONLY thing it does it to test
# whether your specified filelist fits into your MP3 device. It does
# no mount/umount activities.
#
# Features:
#   * Copies .mp3 files blindly, but knows how to convert .ogg
#     files into .mp3 files of a stated resolution.
#   * Tests whether you have enough room for the files.
#     Offers a flag -check which only talks about projected flash usage.
#   * Fully automates mount... convert... copy... umount.
#   * Takes some care to keep the USB bus humming, for writes to not
#     just go into Unix caches and then generate a long delay at umount.
#   * Moves data in pipes, doesn't use disk space for intermediate
#     files.
#   * When the filenames supplied on the commandline do NOT use up
#     all available space, it will randomly pick files from your
#     music collection and put them onto the device. Hence, saying
#       $ loadmp3.pl
#     with no args would be tantamount to asking him to only use his
#     randomised selection.
#   * It checks that in randomisation, it doesn't reuse a file which
#     was already taken.
#
# Requirements:
#   * You have to obviously have a USB Mass Storage MP3 device which
#     mounts and umounts successfully.
#   * You have to have the following binaries:
#       ogginfo
#       ogg123
#       bladeenc
#       df
#       id
#     In Debian, these come from the following packages:
#       vorbis-tools
#       bladeenc
#       fileutils
#       shellutils
#
# Future todo:
#   * Right now it wants to be root, thinking that only root can
#     mount..umount. That's not true in general.
#
#   * Right now it panics if a filename contains special characters.
#     Need to fix this.
#
#   * Right now, it assumes that after it has done 'rm *mp3' on the
#     device, there is no gunk left lying around. If you had used the
#     MP3 player as portable media, and you had some files lying around,
#     it just breaks. It does not CHECK that there is nothing on the
#     device after doing "rm *mp3".
#
#   * Right now, it merely keeps track of the exact string for the
#     name of a file that was 'used up'. Strictly, thanks to relative
#     addressing in filepaths, some nonunique files could still slip
#     through.
#
# Ajay Shah
# ajayshah at mayin.org
# http://www.mayin.org/~ajayshah
# Version 0.03, Wed Oct 23 07:24:35 IST 2002

# CONFIGURATION PARAMETERS
my($my_kbitrate) = 96000;          # what kilobitrate do you like to listen at -- for gstreamer has to be actual bitrate
#my($capacity) =  2013152;          # how many kilobytes fit into your device
#my($capacity) =    416352;          # how many kilobytes fit into your device
my($capacity) =    1461732;          # how many kilobytes fit into your device
my($musicdir) = '/home/kingjon/tmp/music/favorites';  # Where do your music files sit
my($mountpoint) = '/media/disk';   # Where does the device appear when mounted
my($mountcommand) = "mount $mountpoint > /dev/null 2>&1";
my($umountcommand) = "umount $mountpoint > /dev/null 2>&1";
my($low_water_mark) = 20000;  # how much wasted space is okay?
my($impossibly_large) = 2000;    # how many times to try to fill up space?
my($verbose) = 1;               # only 0 or 1 - two choices
my($needroot) = 0;              # does user need to be root to run this?
                                #  mostly this is a mount..umount perms issue.
# END OF CONFIGURATION PARAMETERS

# Given an arg (a .mp3 or a .ogg file), estimate the size of the
# finished product which you will send down to the device.
# In the case of .ogg, assume conversion into .mp3 at $my_kbitrate
# In the case of .mp3, assume the file just gets copied.
sub estfilesize {
    my($filename) = @_;
#    my($filename) = '$filename';
    die "$0: File $filename does not exist\n" if (! -f $filename);
    if ($filename =~ /.mp3$/) {
        my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
           $atime,$mtime,$ctime,$blksize,$blocks) = stat($filename);
        return $size;
    }
    if ($filename =~ /.ogg/) {
        my($safetymargin) = 1024; # pad an extra 1k bytes into the answer
        open(F, "ogminfo -s $filename | grep seconds | sed -e 's/^.*: //'|")
            or die "$0: ogminfo croaked on $filename: $!\n";
        my($length) = <F> or die "$0: setting length variable on file $filename\n";
        #my(@pieces) = split(/ /, $length);
        #my($seconds) = $pieces[1];
        my($seconds) = $length;
        return int($safetymargin + $seconds * $my_kbitrate /8);
    }
    if ($filename =~ /.flac/) {
        my($safetymargin) = 1024; # pad an extra 1k bytes into the answer
	my($seconds) = `metaflac --show-total-samples "$filename"`/44100;
        return int($safetymargin + $seconds*$my_kbitrate/8);
    }
    die "$0: File $filename is neither .flac, .ogg nor .mp3\n";
}

# Given a list of files, push them onto device.
sub putintodevice {
    my($pflist) = @_;
    my($f);
    my($n)=0;

    print "Mounting MP3 device...\n";
    system($umountcommand); # Harmless - just in case it's mounted
    system($mountcommand) == 0
        or die "$0: Mounting MP3 device failed: $!\n";
    system("rm -f $mountpoint/*mp3") == 0
        or die "$0: Deleting existing files at $mountpoint failed: $!\n";
    print "MP3 device ready for use...\n" if ($verbose);

    for $f (@$pflist) {
        print "Processing $f...\n";
        if ($f =~ /.mp3$/) {
            system("cp $f $mountpoint/") == 0
                or die "$0: Copying $f to $mountpoint failed: $!\n";
        } else {
        open(F, "basename \"$f\" .ogg|") or die "$0: basename failed on $f: $!\n";
        my($basename) = <F> or die "$0: setting basename variable\n";
	chomp($basename);
	close(F);
	    #system("gst-launch-0.10 filesrc location=$f ! oggdemux !  vorbisdec ! audioconvert ! ffenc_mp2 bitrate=$my_kbitrate ! xingmux !  id3v2mux ! filesink location=$mountpoint/$basename.mp3");
	    system("gst-launch-0.10 filesrc location=$f ! oggdemux !  vorbisdec ! audioconvert ! ffenc_mp2 bitrate=$my_kbitrate ! id3v2mux ! filesink location=$mountpoint/$basename.mp3");
            #system("ogg123 -q --device=wav $f -f -| toolame -b $my_kbitrate - $mountpoint/$basename.mp3 2> /dev/null") == 0 
                #or die "$0: Making MP3 out of $f and writing onto $mountpoint/$basename.mp3 failed: $!\n";
        }
        $n++;
        system("sync");       # to get the USB disk humming...
    }

    system("df $mountpoint");
    print "Umounting...\n";
    system($umountcommand) == 0
        or die "$0: Umounting MP3 device failed: $!\n";
}

# ---------------------------------------------------------------------------
# Main program
if ($needroot) {
    my($id)=`id -u`;
    die "$0: You must run this as root.\n" if ($id != 0);
}

# Step 1 - check that the files supplied do not overflow
my($estsize)=0;
my($checkonly)=0;
my(%parcel);
if ($#ARGV != -1) {
    for (@ARGV) {
        if ($_ eq "-check") {
            $checkonly=1;
            print "$0: In check-only mode - will only check whether your files fit in your capacity of $capacity\n";
        } else {
            $parcel{$_} = 1;
            $estsize += &estfilesize($_);
        }
    }
    die "$0: Your files add up to an estimated $estsize, but your
        device has only $capacity kilobytes of space.\n" 
        if ($estsize > 1024*$capacity);
}
# So now we know how much room for my intelligence we have.
my($available) = 1024*$capacity - $estsize;
print "Okay, your files add up to $estsize bytes.\n";
print "The device has $available bytes left, which I will try to utilise.\n";
exit(0) if ($checkonly);

#=pod
## Append files to keys %parcel, trying to use up $available
print "about to run find command.\n";
my(@fileslist)=`find $musicdir -name '*.ogg' -or -name '*.mp3'`;
print "finished find command.\n";
chomp @fileslist;
my($N)=$#fileslist;
my($n)=0;
print "about to begin loop.\n";
#while ($available > $low_water_mark) {
#    my($tryfile);
#    do {
#        $tryfile = $fileslist[int($N*rand())];
#    } while (defined $parcel{$tryfile});
#    my($trysize) = &estfilesize($tryfile);
#    print "Trying $tryfile ($trysize)..." if ($verbose);
#    if ($trysize < $available) {
#        $parcel{$tryfile} = 1; $available -= $trysize;
#        print "Yes.\n" if ($verbose);
#    }
#    last if (++$n > $impossibly_large);      # to avoid infinite loops
#}
print "ended loop.\n";

# Now we have a happy parcel - push it onto the device.
print "\nWill try to place this parcel, with $available free: ",
    join("\n\t", keys %parcel), "\n" if ($verbose);
my(@names) = keys %parcel;
&putintodevice(\@names);

=cut
