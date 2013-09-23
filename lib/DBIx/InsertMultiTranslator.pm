package DBIx::InsertMultiTranslator;

use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

use Exporter qw(import);

use DBI;
use SQL::Statement;
use SQL::Abstract;
use SQL::Abstract::Plugin::InsertMulti;

our(@EXPORT_OK);
@EXPORT_OK = qw/intercept/;
use constant _ORG_EXECUTE => \&DBI::st::execute;

#sub new {
#    my $class = shift;
#    my %args  = shift;
#    my $self = bless \%args, $class;
#    return $self;
#}

sub intercept(&) {
    my ($orig) = @_;

    my $insert_sth = +{};
    my $st_execute ||= _st_execute(_ORG_EXECUTE, $insert_sth);

    no warnings qw(redefine prototype);
    *DBI::st::execute = $st_execute;
    $orig->();
    *DBI::st::execute = _ORG_EXECUTE;

    my $sql = SQL::Abstract->new;

    for my $table (keys %{$insert_sth}) {
        my ($stmt, @bind) = $sql->insert_multi($table, $insert_sth->{$table}->{columns}, $insert_sth->{$table}->{values});
        my $sth = $insert_sth->{$table}->{dbh}->prepare($stmt);
        $sth->execute(@bind);
    }
}

sub _st_execute {
    my ($org, $insert_sth) = @_;

    return sub {
        my $sth = shift;
        my @params = @_;
        my @types;
        my $statment = $sth->{Statement};
        my($parser) = SQL::Parser->new();
        my ($stmt) = SQL::Statement->new($statment, $parser);

        if ($stmt->command eq 'INSERT') {
            my @tables =  $stmt->tables();
            my @columns = map { $_->{value} } @{$stmt->column_defs};
            my @values;

            my $multi_values;
            if (defined($insert_sth->{ $tables[0]->name })) {
                $multi_values = $insert_sth->{ $tables[0]->name }->{values} || [];
            }

            my $count = 0;
            my @row_values = $stmt->row_values();
            for my $value (@{$row_values[0]}) {
                if ($value eq '?') {
                    push @values, $params[$count];
                    $count++;
                    next;
                }
                push @values, $value;
            }
            my $dbh = $sth->{Database};
            push @{$multi_values}, \@values;
            $insert_sth->{$tables[0]->name} = +{columns => \@columns, values => $multi_values, dbh => $dbh};
            return;
        }
        return $org->($sth, @params);
    };
}


1;
__END__

=encoding utf-8

=head1 NAME
[![Build Status](https://travis-ci.org/SpringMT/DBIx-InsertMultiTranslator.png?branch=master)](https://travis-ci.org/SpringMT/DBIx-InsertMultiTranslator)
[![Coverage Status](https://coveralls.io/repos/SpringMT/DBIx-InsertMultiTranslator/badge.png?branch=master)](https://coveralls.io/r/SpringMT/DBIx-InsertMultiTranslator?branch=master)

DBIx::InsertMultiTranslator - It's new $module

=head1 SYNOPSIS

    use DBIx::InsertMultiTranslator;

=head1 DESCRIPTION

DBIx::InsertMultiTranslator is ...

=head1 LICENSE

Copyright (C) SpringMT.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

SpringMT E<lt>today.is.sky.blue.sky@gmail.comE<gt>

=cut

