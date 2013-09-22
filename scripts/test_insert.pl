#!/usr/bin/perl

use strict;
use warnings;
use Carp;

use lib 'lib';
use DBI;
use Data::Dumper;


package main;
use DBIx::InsertMultiTranslator qw/intercept/;
#use TestImport qw/intercept/;

my $dbh = DBI->connect('DBI:mysql:hoge:localhost', 'root', '', {'RaiseError' =>1} );
my $sth = $dbh->prepare(qq{INSERT INTO test (id) VALUES (?)});

#my $translator = DBIx::InsertMultiTranslator->new();

intercept {
  $sth->execute(5);
  $sth->execute(6);
  $sth->execute(7);
};


