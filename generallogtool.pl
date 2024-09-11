#!/usr/bin/perl
use strict;
use Getopt::Long;
my %opt ;
GetOptions(\%opt,
    'help+', # write usage info
    'd|debug+', # debug
    'sqlonly!', # print sql only
    't=s', # grep: only consider threadid that include this string
    'h=s', # grep: only consider linkip that include this string
    'p=s', # grep: only consider linkport that include this string
    'c=s', # grep: only consider client dialogid that include this string
    'u=s', # grep: only consider uuid that include this string
    'g=s', # grep: only consider sql stmts that include this string
) or usage("bad option");
$opt{'help'} and usage();
unless (@ARGV) {
    my $generallog = "general_query.log";
    if ( -f $generallog ) {
        @ARGV = ($generallog);
        die "Can't find '$generallog'\n" unless @ARGV;
    }
}
my $whole_file = do {local $/; <> };
my $entry_separator = '(?m)(?=^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}:\d{3})';
my @entries = split /$entry_separator/,$whole_file;

foreach my $entry (@entries) {
        warn "[[$_]]\n" if $opt{d}; # show raw paragraph being read
        my ($timestamp,$thread_id,$port,$dialogid,$linkip,$linkport,$uuid,$session,$sql)  = $entry =~ s/^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}:\d{3}).*Threadid\[(\d*)\]Port\[(\d*)\]Dialogid\[(\d*)\]LinkIP\[(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\]LinkPort\[(\d*)\]UUID\[(\S*)\]Session\[(\d*)\]SQL\[(.*)\]//s ? ($1,$2,$3,$4,$5,$6,$7,$8,$9) : ('','','','','','','','','');
        next if $opt{g} and $sql !~ /$opt{g}/io;
        next if $opt{t} and $thread_id !~ /$opt{t}/;
        next if $opt{h} and $linkip !~ /$opt{h}/io;
        next if $opt{p} and $linkport !~ /$opt{p}/io;
        next if $opt{c} and $dialogid !~ /$opt{c}/io;
        next if $opt{u} and $uuid !~ /$opt{u}/io;
        if ($opt{sqlonly}) {
                        printf "%s\n",$sql;
                        next;
                }else{
                        printf "%s Threadid[%d] Port[%d] Dialogid[%d] LinkIP[%s] LinkPort[%s] UUID[%s] SQL[%s]\n", $timestamp,$thread_id,$port,$dialogid,$linkip,$linkport,$uuid,$sql;
                }
}

sub usage {
    my $str= shift;
    my $text= <<HERE;
Usage: perl generallogtool.pl [ OPTS... ] [ LOGS... ]
Parse and summarize the goldendb general_query.log. Options are
  --help       write this text to standard output
  -d           debug
  -sqlonly     print sql only
  -t threadid         grep: only consider threadid that include this string
  -h hostip         grep: only consider linkip that include this string
  -p linkport         grep: only consider linkport that include this string
  -c dialogid        grep: only consider client dialogid that include this string
  -u uuid        grep: only consider uuid that include this string
  -g PATTERN grep: only consider sql stmts that include this string
HERE
    if ($str) {
      print STDERR "ERROR: $str\n\n";
      print STDERR $text;
      exit 1;
    } else {
      print $text;
      exit 0;
    }
}
