#!/usr/bin/perl -U

use File::Tail;
use Term::ANSIColor;
use strict;

BEGIN{unshift(@INC, "../lib");unshift(@INC, "./");};

#"/var/log/apache2/error_log.fciliberti.sauron.com.ar"

my $archivo = shift();

die "Ingrese archivo.\n" unless($archivo);

my $file=File::Tail->new(name=>$archivo, maxinterval=>1, tail=>100);

my $block;
my $line;
my $act;
my ($soft_green,$soft_yellow,$soft_blue, $red, $blue,$yellow,$reset) = (color('green'),color('yellow'),color('cyan'),color('red'),color('bold cyan'), color('yellow'), color('reset'));

while (defined($line=$file->read)) {

  $line=~s/\,\ refer.*$//g;
  #NOTE: Nombre del archivo.
    $line=~s/([\w_\d]+\.p[lm])/$blue$1$reset/g;
  #NOTE: Tiempo transcurrido.
    $line=~s/(\[\>?\d+\.\d*\<?\])/$yellow$1$reset/g;

  #NOTE: Elementos sql.
    $line=~s/FROM (\w*)/FROM $red$1$reset/ig;
    $line=~s/INTO (\w*)/INTO $red$1$reset/ig;
    $line=~s/(INSERT|UPDATE|REPLACE|DELETE|INTO)\s/$soft_yellow$1$reset /gi;
    $line=~s/(SELECT)\s/$soft_green$1$reset /g;
    $line=~s/\s(FROM|WHERE|AND|GROUPBY|LEFT|JOIN|ON|SET)\s/ $soft_blue$1$reset /gi;
  #NOTE: Cadenas de texto en rojo.
    $line=~s/'(.*?)'/'$red$1$reset'/gi;
    $line=~s/"(.*?)"/'$red$1$reset'/gi;

  #NOTE: Marcas temporales.
    $line=~s/^\[.*?(\d\d\:\d\d\:\d\d).*?\]\s\[.*?\]\s\[.*?\]\s*//g;
    $line=~s/\[client.*?\]\s*AH01215://g;

  $line=~s/\\t/\t/g;

  if ($1 ne "" and ($1 ne $act)){
    print color 'bold red';
    print "\n\n\n$1\n";
    print color 'reset';
    $act = $1;
  }

  $line=~s/\\n/\n/g;

  print "$line";
}
