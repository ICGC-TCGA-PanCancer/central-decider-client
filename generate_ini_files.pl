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

#perl generate_ini_files.pl --workflow-name=SangerPancancerCgpCnIndelSnvStr --gnos-repo=https://gtrepo-ebi.annailabs.com/ --donors=3 --test --template-file=templates/workflow-1.0.5.bsc.ini --password=<pw>

#or

#perl generate_ini_files.pl --workflow-name=SangerPancancerCgpCnIndelSnvStr --gnos-repo=https://gtrepo-ebi.annailabs.com/ --whitelist=whitelist.txt --test --template-file=templates/workflow-1.0.5.bsc.ini --password=<pw>

my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->env_proxy;

my $host = 'decider.oicrsofteng.org';
my $port = 80;
my $realm = "PanCancer Metadata";

$ua->credentials("$host:$port", $realm, 'pancancer', $ARGV{'--password'});

my %parameters = (
                  'workflow-name' => $ARGV{'--workflow-name'},
                  'gnos-repo'     => $ARGV{'--gnos-repo'},

                 );

$parameters{'vm_location_code'} = 1 if ($ARGV{'vm_location_code'});
$parameters{'force'} = 1 if ($ARGV{'--force'});
$parameters{test} = 1               if ($ARGV{'--test'});

if( ($ARGV{'--cloud-env'} && $ARGV{'--whitelist'}) 
    || ($ARGV{'--donor'} && $ARGV{'--whitelist'})
    || ($ARGV{'--cloud-env'} && $ARGV{'--donor'})
    || (!$ARGV{'--cloud-env'} && !$ARGV{'--whitelist'} && !$ARGV{'--donor'})) {

  die "need to specify either whitelist, cloud env or donors parameters";

}
elsif ($ARGV{'--donors'}) {
    $parameters{'number-of-donors'} = $ARGV{'--donors'}
}
elsif ($ARGV{'--cloud-env'}) {
    $parameters{'cloud-env'} = $ARGV{'--cloud-env'};
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
  die "need to specify either whitelist, cloud env or donors parameters";
} 

my $url = URI->new("http://$host/cgi-bin/central-decider/get-ini");
$url->query_form(%parameters);
my $response = $ua->get($url);

my $ini_parameters;
eval {
  $ini_parameters = JSON->new->utf8->decode($response->decoded_content);
  1;
} or do {
  die $response->decoded_content;
};

if($ini_parameters) {
    foreach my $ini (@$ini_parameters) {
        my $template = Template->new();
        my $donor_id = $ini->{donor_id};
        my $project_code = $ini->{project_code};
        $ini->{workflow_name} = $ARGV{'--workflow-name'};
        $ini->{gnos_repo}     = $ARGV{'--gnos-repo'};
        my $ini_filename = "ini/$donor_id-$project_code.ini";
        if ( ( ($ARGV{'--workflow-name'} eq "DEWrapperWorkflow") 
                 || ($ARGV{'--workflow-name'} eq "EMBLWorkflow") 
                 || ($ARGV{'--workflow-name'} eq "DKFZWorkflow") ) && (index($ini->{'tumour_analysis_ids'}, ',') != -1 )) {
            say "Not creating file $ini_filename because it contains multiple tumours and the German workflows do not";
        }
        else {
            say "Generating: $ini_filename";
            $template->process($ARGV{'--template-file'}, $ini, $ini_filename);
        }
    }
}
else {
  say "No Workflows returned";
}
