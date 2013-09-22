requires 'perl', '5.008001';

requires 'DBI';
requires 'SQL::Statement';
requires 'SQL::Abstract';
requires 'SQL::Abstract::Plugin::InsertMulti';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

