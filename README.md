# central-decider-client
This tool is used to generate workflow.ini files. It takes in a list of donors or samples from a whitelist, queries the central decider and then generates an INI file for each of the samples in the provided list. Information in the resulting INI's come from either the INI template or from information provided by the central decider. 

##Author
Adam Wright (adam.j.wright82@gmail.com)

##Steps to get started:
1.  Obtain password from OICR
2.  Obtain Whitelist of donors or samples from OICR
3.  Clone repository into desired location
4.  Install required packages
5.  Generate INI's through providing generate_ini_files.pl with the desired input through command line flags
6.  Ini files will appear in the ini folder after being generated

*by default, INI files that have been previously run and submitted to a PanCancer GNOS repository will not be generated.

##Example Command 
      perl generate_ini_files.pl --workflow-name=SangerPancancerCgpCnIndelSnvStr --gnos-repo=https://gtrepo-ebi.annailabs.com/ --whitelist=whitelist-ebi.txt --test --template-file=templates/dkfz-embl-template.ini --password=<password> --vm-location-code=ebi

##Environment
This tool is designed and tested with a Ubuntu 12.04 environment. The tool requires minimal CPU and memory. As the client performs a http request to the central decider the machine will require internet access on port 80. 
      
##Password
In order to use this tool you will need a password. This password is used by the decider client when making a get request to the central decider. Although the INI files do not contain sensitive information, requiring authentication prevents malicious querying of the central decider / elasticsearch database. 

##Installation

      sudo apt-get install make git libipc-system-simple-perl libgetopt-euclid-perl libjson-perl libwww-perl libdata-dumper-simple-perl libtemplate-perl 


##Command line flags for generate_ini_files.pl

    --usage
    --help
    --man

REQUIRED
    --gnos-repo[=][ ]<gnos_repo>
        This is the URL for the repo you would like to pull information from

    --template-file[=][ ]<file>
        The template that should be use for generating the ini files

    --workflow-name[=][ ]<worklflow-name>
        This is the name as it would appear in the metadata and in SeqWare
        for the workflow you would like to schedule donors for.

    --password[=][ ]<password>
        This will be provided to you by OICR

OPTIONAL
    --whitelist[=][ ]<whitelist-file>
        The path to the whitelist the ini files will be generated for

    --donors[=][]<number-of-donors>
        This will generate a list of n ini files that are needing to be processed
    --test
        With this parameter specified it will query the central database but
        the central database will not record the samples as scheduled.
    --force
        This option make it so that INI files will be generated regardless of whether
        or not they have been run before.

