#!/usr/bin/perl
use strict;
use Getopt::Long;

my %opt;
GetOptions(\%opt,
    'help+',    # write usage info
    'd|debug+', # debug
    'sqlonly!', # print sql only
    't=s',      # grep: only consider threadid that include this string
    'h=s',      # grep: only consider linkip that include this string
    'p=s',      # grep: only consider linkport that include this string
    'c=s',      # grep: only consider client dialogid that include this string
    'u=s',      # grep: only consider uuid that include this string
    'g=s',      # grep: only consider sql stmts that include this string
) or usage("bad option");

$opt{'help'} and usage();

unless (@ARGV) {
    my $generallog = "general_query.log";
    if ( -f $generallog ) {
        @ARGV = ($generallog);
        die "Can't find '$generallog'\n" unless @ARGV;
    }
}

my $entry = '';
my $entry_separator = qr/^(?:\d{4}-\d{2}-\d{2}|\d{2}-\d{2}) \d{2}:\d{2}:\d{2}:\d{3}/;

while (my $line = <>) {
    if ($line =~ $entry_separator) {
        # Process the previous entry if it exists
        process_entry($entry) if $entry;
        # Start a new entry
        $entry = $line;
    } else {
        # Continue accumulating lines
        $entry .= $line;
    }
}

# Process the last entry after the loop ends
process_entry($entry) if $entry;

# Subroutine to process each entry
sub process_entry {
    my ($entry) = @_;
    warn "[[$entry]]\n" if $opt{d}; # Show raw entry being read

    # Extract relevant information using regex
    my ($timestamp, $thread_id, $port, $dialogid, $linkip, $linkport, $uuid, $session, $sql) =
        $entry =~ m{
            ^((?:\d{4}-\d{2}-\d{2}|\d{2}-\d{2})\s\d{2}:\d{2}:\d{2}:\d{3}).*?   # Timestamp
            Threadid\[(\d*)\]
            Port\[(\d*)\]
            Dialogid\[(\d*)\]
            LinkIP\[(\d{1,3}(?:\.\d{1,3}){3})\]
            LinkPort\[(\d*)\]
            UUID\[(\S*)\]
            Session\[(\d*)\]
            SQL\[(.*)\]
        }sx ? ($1, $2, $3, $4, $5, $6, $7, $8, $9) : ('', '', '', '', '', '', '', '', '');

    # Skip processing if the entry doesn't match the expected format
    return unless $timestamp;

    # Apply filters based on options
    return if $opt{g} and $sql !~ /$opt{g}/io;
    return if $opt{t} and $thread_id !~ /$opt{t}/;
    return if $opt{h} and $linkip !~ /$opt{h}/io;
    return if $opt{p} and $linkport !~ /$opt{p}/io;
    return if $opt{c} and $dialogid !~ /$opt{c}/io;
    return if $opt{u} and $uuid !~ /$opt{u}/io;

    # Output the result based on options
    if ($opt{sqlonly}) {
        printf "%s\n", $sql;
    } else {
        printf "%s Threadid[%d] Port[%d] Dialogid[%d] LinkIP[%s] LinkPort[%s] UUID[%s] SQL[%s]\n",
            $timestamp, $thread_id, $port, $dialogid, $linkip, $linkport, $uuid, $sql;
    }
}

# Subroutine to display usage information
sub usage {
    my $str = shift;
    my $text = <<'HERE';
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
