# central-decider-client
This tool is used to generate workflow.ini files. It takes in a list of donors or samples from a whitelist, queries the central decider and then generates an INI file for each of the samples in the provided list. Information in the resulting INI's come from either the INI template or from information provided by the central decider. 

##Author
Adam Wright (adam.j.wright82@gmail.com)

##Steps to get started:
1.  Obtain password from OICR, email Adam
2.  Obtain Whitelist of donors or samples from OICR, email Christina Yung <Christina.Yung@oicr.on.ca> for a list and see them stored here: https://github.com/ICGC-TCGA-PanCancer/pcawg-operations
3.  Clone this repository into desired location
4.  Install required packages
5.  Generate INI's through providing generate_ini_files.pl with the desired input through command line flags
6.  Ini files will appear in the ini folder after being generated

*by default, INI files that have been previously run and submitted to a PanCancer GNOS repository will not be generated.

##Example Command 
      perl generate_ini_files.pl --workflow-name=SangerPancancerCgpCnIndelSnvStr --gnos-repo=https://gtrepo-ebi.annailabs.com/ --whitelist=whitelist-ebi.txt --test --template-file=templates/dkfz-embl-template.ini --password=<password> --vm-location-code=ebi

##Example transfer to S3
      perl generate_ini_files.pl --test --workflow-name=Workflow_GNOS_to_S3 --password=<password> --vm-location-code=bsc --template-file=templates/gnos_to_s3.ini --number-of-donors=1

##Environment
This tool is designed and tested with a Ubuntu 14.04 environment. The tool requires minimal CPU and memory. As the client performs a http request to the central decider the machine will require internet access on port 80. 
      
##Password
In order to use this tool you will need a password. This password is used by the decider client when making a get request to the central decider. Although the INI files do not contain sensitive information, requiring authentication prevents malicious querying of the central decider / elasticsearch database. 

##Installation
      If you have cpanminus run: cpanm --quiet --notest --installdeps .

      Or with Apt-get run: sudo apt-get update; sudo apt-get install make git libipc-system-simple-perl libgetopt-euclid-perl libjson-perl libwww-perl libdata-dumper-simple-perl libtemplate-perl 

##DKFZ / EMBL Workflows
In order to specify the correct parameters and to schedule out the German Workflows refer to: https://github.com/SeqWare/public-workflows/blob/release/dkfz_embl_1.0.0/DEWrapperWorkflow/README.md

##Creating Template
Within the template folder there are samples templates for each of the major workflows that we run with the PanCancer project. With in these templates there are are values that can get injected into the templatem, when generating the INI files. 

The the fields that get injected will appear in template in the format "[% \<desired-field-name\> %]", where you wil replace "\<desired-field-name\>" with one of the following values:

| field name    | Example Injected Value   |
| ------------- |----------------|
| upload_gnos_key | TCGA |
| control_analysis_id | 1f3cb1fe-a83f-4099-b4d4-0f0f6a3c0e48 |
| tumour_analysis_ids | 88545635-e0dd-4710-a762-fb8bf1408d23 |
| workflow_name | SangerPancancerCgpCnIndelSnvStr |
| control_bam | PCAWG.458023b4-e6d6-45d4-bebe-2321fc693837.bam |
| tumour_bams | PCAWG.fe319028-03ac-4741-bcc2-a6ed7a1e07ce.bam |
| vm-location-code | ebi |
| project_code | UCEC-US |
| tumour_aliquot_ids | 31bc44b9-35ff-43fd-8a01-a834f3b1ce46 |
| download_gnos_url | https://cghub.ucsc.edu/ |
| upload_gnos_url | https://gtrepo-osdc-tcga.annailabs.com/ |
| donor_id | f6d136c7-c250-4361-9fed-50f513959a40 |
| download_gnos_key | cghub |

##Command line flags

see [generate_ini_files.pod](generate_ini_files.pod) 

##Travis

Travis utility is used to test if the repo is compiling correctly
