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

#perl generate_ini_files.pl --workflow-name=SangerPancancerCgpCnIndelSnvStr --gnos-repo=https://gtrepo-ebi.annailabs.com/ --number-of-donors=3 --test --template-file=templates/workflow-1.0.5.bsc.ini --password=<pw>

#or

#perl generate_ini_files.pl --workflow-name=SangerPancancerCgpCnIndelSnvStr --gnos-repo=https://gtrepo-ebi.annailabs.com/ --whitelist=whitelist.txt --test --template-file=templates/workflow-1.0.5.bsc.ini --password=<pw>

my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->env_proxy;

my $host = 'decider.oicrsofteng.org';
$host = "stage.$host" if ($ARGV{'--stage'});

my $port = 80;
my $realm = "PanCancer Metadata";

$ua->credentials("$host:$port", $realm, 'pancancer', $ARGV{'--password'});

my %parameters = (
                  'workflow-name'  => $ARGV{'--workflow-name'},
                  'gnos-repo'      => $ARGV{'--gnos-repo'},
                  'local-file-dir' => $ARGV{'--local-file-dir'}
                 );

$parameters{'vm-location-code'} = $ARGV{'--vm-location-code'} if ($ARGV{'--vm-location-code'});

$parameters{'force'} = 1            if ($ARGV{'--force'});
$parameters{'test'} = 1             if ($ARGV{'--test'});

if( ($ARGV{'--cloud-env'} && $ARGV{'--whitelist'}) 
    || ($ARGV{'--number-of-donors'} && $ARGV{'--whitelist'})
    || ($ARGV{'--cloud-env'} && $ARGV{'--number-of-donors'})
    || (!$ARGV{'--cloud-env'} && !$ARGV{'--whitelist'} && !$ARGV{'--number-of-donors'})) {

  die "Need to specify only on of the following flags: whitelist, cloud env or number-of-donors";

}
elsif ($ARGV{'--number-of-donors'}) {
    $parameters{'number-of-donors'} = $ARGV{'--number-of-donors'}
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
  die "Need to specify one of the folling flags: whitelist, cloud env or number-of-donors";
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

if($ini_parameters && @$ini_parameters) {
    foreach my $ini (@$ini_parameters) {
        my $template = Template->new();
        my $donor_id = $ini->{donor_id};
        my $project_code = $ini->{project_code};
        my $sample_id = $ini->{submitter_sample_id};
        my $sample_type = $ini->{sample_type};
        my $aliquot_id = $ini->{aliquot_id};

        $ini->{workflow_name}    = $ARGV{'--workflow-name'};
        $ini->{gnos_repo}        = $ARGV{'--gnos-repo'} if ($ARGV{'--gnos-repo'});
        $ini->{vm_location_code} = $ARGV{'--vm-location-code'} if ($ARGV{'--vm-location-code'});

        $ini->{tumour_analysis_paths} = 'inputs/'.join(',inputs/', split(',', $ini->{'tumour_analysis_ids'}));

        my $ini_filename = ($ARGV{'--workflow-name'} eq 'Workflow_Bundle_BWA')? "ini/$donor_id-$project_code-$sample_id-$sample_type.ini" : "ini/$donor_id-$project_code.ini";
                   
        say "Generating: $ini_filename";
        $template->process($ARGV{'--template-file'}, $ini, $ini_filename);
    }
}
else {
  say "No Workflows returned - No workflows should be scheduled based on parameters provided. If you are using the flag cloud-env keep in mind that the whitelists are pulled from the latest tagged version of the https://github.com/ICGC-TCGA-PanCancer/pcawg-operations website. This repo is tagged nightly. If you want to run whitelist that has not made it into a tag yet run the commad by providing the whitelist with the --whitelist flag instead of using the --cloud-env flag ";
}
