#!/usr/bin/perl
#
# verzija datoteke 1.0.0
# datum: 20.5.2014
#
# promjene:

use MIME::Lite;
my ($filename,$frommail,$from,$emailTo,$uniqueid) = @ARGV;

my $msg = MIME::Lite->new(
        From => $frommail,
        To => $emailTo,
        Subject => "[Faks poruka] ".$uniqueid,
        Type => 'multipart/mixed'
);
$msg->attach(
        Type => 'TEXT',
        Data => "Nova faks poruka je stigla." .
        "U privitku je.\n\n--".$from
);

$msg->attach(
        Type => 'image/tiff',
        Path => "$filename.tif",
        Disposition => 'attachment'
);

$msg->attach(
        Type => 'application/pdf',
        Path => "$filename.pdf",
        Disposition => 'attachment'
);


$msg->send;

