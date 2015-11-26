#!/usr/bin/perl -w
use strict;

# Ratbar: a nutritious breakfast snack for people on the move.
# Ratbar is a task bar for the Ratpoison window manager (http://www.nongnu.org/ratpoison/).
# The default output format for `ratpoison -c windows` is assumed.

# using Ratbar:
#  The leftmost button, with the triangle arrow, is the menu.
#  Right of the menu is the task bar.
#  The taskbar will list windows in the current group.
#  Clicking on a button in the task bar will select the corresponding window.
#  On the far right of Ratbar is the text display. This you don't technically use.
#  Ratbar can also receive commands from the file '~/.ratbar/command_queue'.
#  Valid commands are 'menu', which opens the ratbar menu, 'reparse', which re-reads
#  the menu file ~/.ratbar/menu and updates the menu listings, and 'quit', which
#  closes Ratbar. Invalid commands are ignored.
#  All commands (valid or not) are removed from the queue upon execution.

# configuring Ratbar:
#  The menu is read from ~/.ratbar/menu
#  If this file doesn't exist, or is empty, there will be no menu.
#  The format for this file is label|command\n...
#  example menu file:
#   Mozilla|mozilla
#   reparse menu|echo reparse>>~/.ratbar/command_queue
#  The text display is the output from `~/.ratbar/text`
#  Further configuration can be made by editing this file.

use Ratpoison;
use Gtk2;
use File::Basename;

set_locale Gtk2;
init Gtk2;

# configuration

# maximum length for a taskbar title
my $maxLength = 20;

# clock or other text status program
my $commandFile = $ENV{'HOME'}."/.ratbar/text";
# queue for ratbar commands
my $queueFile = $ENV{'HOME'}."/.ratbar/command_queue";
# menu
my $menuFile = $ENV{'HOME'}."/.ratbar/menu";

# figure out the name ratbar will have in the taskbar
# so that it can be ignored
my $progname = basename($0);


# window

my $window = new Gtk2::Window("toplevel");
# Cooperate with the delete signal
$window->signal_connect("delete_event", \&close_app_window);

# break window into horizontal pieces
my $box = new Gtk2::HBox(0,0);
$window->add($box);


# menu

my $menu = new Gtk2::Menu;
my $menuBar = new Gtk2::MenuBar;
my $menuButton = new Gtk2::MenuItem;
my $arrow = new Gtk2::Arrow("right","in");
$menuButton->add($arrow);
$menuBar->append($menuButton);
$box->pack_start($menuBar,0,0,0);

# shows output from commandFile
my $label = new Gtk2::Label("");
$box->pack_end($label,0,0,0);

$window->show_all;

sub update_text
{
   if (-e $commandFile && -x $commandFile)
   {
      my $text = `$commandFile`;
      chomp($text);
      $label->set_text(" ".$text." ");
   }
}

# create a button for the task bar
sub task_button
{
   # truncate titles that are too long
   my $title = shift;
   if (length($title) > $maxLength)
   {
      $title = substr($title,0,$maxLength-3)."..."
   }
   # find the task number
   my $num;
   ($num) = split(/\*|\+|-/,$title);
   my $item = new Gtk2::Button($title);
   $item->signal_connect("clicked", sub { Ratpoison::select($num); });
   return $item;
}

my $taskbar;
my $windowsStringCache = "";
sub update_taskbar
{
   my $windowsString = Ratpoison::windows;
   return if $windowsString eq $windowsStringCache;

   $windowsStringCache = $windowsString;
   my @windowsList = split(/\n/,$windowsString);

   $taskbar->destroy if $taskbar;
   $taskbar = new Gtk2::HBox(0,0);

   foreach my $windowString (@windowsList)
   {
      my ($num,$title) = split(/\*|\+|-/,$windowString);
      if ($title ne $progname)
      {
         my $taskButton = task_button($windowString);
         $taskbar->pack_start($taskButton,0,0,0);
      }
   }

   $box->pack_start($taskbar,0,0,5);
   $taskbar->show_all;
   $window->window->clear;

   foreach my $child ($taskbar->get_children)
   {
#      $child->show_now;
   }
}

# create a menu item
sub menu_item
{
   my $label = shift;
   my $cmd = shift;
   my $item = new Gtk2::MenuItem($label);
   $item->signal_connect("activate", sub { system($cmd); });
   return $item;
}

# read ~/.ratbar/menu and repopulate ratbar's menu
sub parse_menu
{
   $menu->destroy;
   $menu = new Gtk2::Menu;
   open(MENU,$menuFile) || return;
   my @lines=<MENU>;
   close(MENU);

   foreach my $line (@lines)
   {
      chomp($line);
      my ($title,$command) = split(/\|/,$line);
      $menu->append(menu_item($title,$command));
   }

   $menuButton->set_submenu($menu);
}

sub close_app_window
{
   Gtk2->exit(0);
   return 0;
}

sub next_command
{
   # get a command (if any are queued)
   if (-e $queueFile)
   {
      my $cmd = `head -1 $queueFile`;
      system("sed -i -e 1d $queueFile");
      return $cmd;
   }
   return "";
}

sub exec_command
{
   my $cmd = shift;
   chomp $cmd;
   if ($cmd ne "")
   {
      if ($cmd eq "reparse")
      {
         parse_menu;
      }
      elsif ($cmd eq "menu")
      {
         $menuButton->select;
      }
      elsif ($cmd eq "quit")
      {
         close_app_window;
      }
   }
}

sub exec_next_command
{
   exec_command(next_command);
}

sub init
{
   parse_menu;
   update_taskbar;
   update_text;
}

sub main_iteration
{
   exec_next_command;
   update_taskbar;
   update_text;
}

init;

while (1)
{
   Gtk2->main_iteration;
   main_iteration;
}
