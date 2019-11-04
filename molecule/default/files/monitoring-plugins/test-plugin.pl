#!/usr/bin/perl

if (eval('use Nagios::Plugin; 1')) {
    $plugin_class = 'Nagios::Plugin';
} elsif (eval('use Monitoring::Plugin; 1')) {
    $plugin_class = 'Monitoring::Plugin';
} else {
    die 'Nagios::Plugin or Monitoring::Plugin is required';
}

my $mp = $plugin_class->new(shortname => 'Test');
$mp->nagios_exit(OK, 'Success');
