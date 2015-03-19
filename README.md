# central-decider-client
This tool is used to generate workflow.ini files from ini templates and information gather from the central-decider server. 

Installation

      sudo apt-get install make git libipc-system-simple-perl libgetopt-euclid-perl libjson-perl libwww-perl libdata-dumper-simple-perl libtemplate-perl 

AUTHOR(S)
    Adam Wright

    --usage
    --help
    --man

DESCRIPTION
    A tool for generating VCF workflow ini files for the PanCancer project

NAME
    generate_ini_files.pl

REQUIRED
    --gnos-repo[=][ ]<gnos_repo>
        This is the URL for the repo you would like to pull information from

    --template-file[=][ ]<file>
        The template that should be use for generating the ini files

    --workflow-name[=][ ]<worklflow-name>
        This is the name as it would appear in the metadata and in SeqWare
        for the workflow you would like to schedule donors for.

OPTIONAL
    --whitelist[=][ ]<whitelist-file>
        The path to the whitelist the ini files will be generated for

    --donors[=][]<number-of-donors>
    --test
        With this parameter specified it will query the central database but
        the central database will not record the samples as scheduled.

