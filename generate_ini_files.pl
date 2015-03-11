#!/usr/bin/env perl

use strict;
use warnings;

use feature 'say';

use autodie qw(:all);
use IPC::System::Simple;

use Getopt::Euclid;

use JSON;
use LWP::UserAgent;

use Template;

use Data::Dumper; 

#USAGE: 

#perl generate_ini_files.pl --w orkflow-name=SangerPancancerCgpCnIndelSnvStr --gnos-repo=https://gtrepo-ebi.annailabs.com/ --donors=3 --test --template-file=templates/workflow-1.0.5.bsc.ini

#or


#perl generate_ini_files.pl --w orkflow-name=SangerPancancerCgpCnIndelSnvStr --gnos-repo=https://gtrepo-ebi.annailabs.com/ --whitelist=whitelist.txt --test --template-file=templates/workflow-1.0.5.bsc.ini



my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->env_proxy;

my %parameters = (
                  'workflow-name' => $ARGV{'--workflow-name'},
                  'gnos-repo'     => $ARGV{'--gnos-repo'},
                 );

$parameters{test} = 1 if ($ARGV{'--test'});

if ($ARGV{'--donors'}) {
    $parameters{'donor'} = $ARGV{'--donors'};
}
elsif ($ARGV{'--whitelist'}) {
    my %donors;
 
    open my $fh, '<', $ARGV{'--whitelist'};
    while (my $row = <$fh>) {
        my ($project, $donor_id) = split ' ', $row;
        #Remove trailing and leading whitespace
        $project =~ s/^\s+|\s+$//g;
        $donor_id =~ s/^\s+|\s+$//g;
        $donors{"$project\:\:$donor_id"} = 1;
    }

    close $fh;       

    $parameters{'donor'} = [keys \%donors];
}
else {
  die "need to specify either donors or whitelist parameters";
} 

my $url = URI->new('http://172.16.18.137/cgi-bin/central-decider/donor-vcf');
$url->query_form(%parameters);
my $response = $ua->get($url);

die $response->status_line unless ($response->is_success);
 
my $json_ini_parameters = $response->decoded_content;

my $ini_parameters = JSON->new->utf8->decode($json_ini_parameters);

foreach my $ini (@$ini_parameters) {
    my $template = Template->new();
    my $donor_id = $ini->{donor_id};
    my $project_code = $ini->{project_code};
    $ini->{workflowName} = $ARGV{'--workflow-name'};
    my $ini_filename = "ini/$donor_id-$project_code.ini";
    say "Generating: $ini_filename";
    $template->process($ARGV{'--template-file'}, $ini, $ini_filename);
}

