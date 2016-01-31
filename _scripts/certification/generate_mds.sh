#!/bin/bash
##
## Author:  N2OMatt
## Date:    Dec 31 2015
## License: GPLv3
##
## This script will scan the Certification directory and generate
## for each certification a markdown page in the certs directory.
##

################################################################################
## Vars                                                                       ##
################################################################################
SITE_ROOT_PATH=$(realpath $PWD/../..)
SOURCE_PATH=$SITE_ROOT_PATH/_mycerts
IMAGES_PATH=$SITE_ROOT_PATH/assets/certs
HTMLS_PATH=$SITE_ROOT_PATH/certs

################################################################################
## Functions                                                                  ##
################################################################################
clean_htmls_dir()
{
    rm    -rf $HTMLS_PATH;
    mkdir -p  $HTMLS_PATH;
}

url_encode()
{
    echo $(python -c "import sys, urllib as ul; \
    print ul.quote(\" \".join(sys.argv[1:]))" $1)
}

create_certifications_pages()
{
    #Change the to the images directory to ease
    #the paths manipulation.
    cd $IMAGES_PATH;

    TEMP_FILENAMES_FILE=$IMAGES_PATH/temp.txt;

    #Save all certification filenames into temp file.
    #Save all certification filenames into temp file.
    find . -not \( -path '*/\.*' -or -path '*/_*' \)                    \
           \( -iname "*.pdf" -or -iname "*.jpg" -or -iname "*.png" \) | \
    sort > $TEMP_FILENAMES_FILE;

    cd $HTMLS_PATH

    CURRENT_PROVIDER_NAME="INVALID";
    while read LINE ; do
        #Get the name of provider.
        PROVIDER_NAME=$(echo $LINE | cut -d \/ -f 2);
        #Get the name of certification.
        #Remove path.
        #Remove extension.
        #Remove the date.
        CERTIFICATION_FULL_NAME=$(basename "$LINE")
        CERTIFICATION_NAME="${CERTIFICATION_FULL_NAME%.*}"

        CERTIFICATION_NAME=$(echo $CERTIFICATION_NAME | cut -d \/ -f 3     \
                                                      | cut -d _  -f 4-100 );

        #Get the name of certification (whitespaced).
        WHITESPACED_NAME=$(echo $CERTIFICATION_NAME | sed s/_/" "/g);

        #Create the image url.
        IMAGE_URL=$(echo $LINE | cut -d \/ -f 2-100);
        IMAGE_URL=$(url_encode $IMAGE_URL);

        #Create the full path of page.
        OUTPUT_FULLPATH=$(realpath -m $HTMLS_PATH/$CERTIFICATION_NAME.md);

        #Show the current page...
        echo $OUTPUT_FULLPATH;

        #Echo the Front-Matter.
        echo "---"                              > $OUTPUT_FULLPATH
        echo "layout: default"                 >> $OUTPUT_FULLPATH
        echo "assets: /assets/certs/$PROVIDER" >> $OUTPUT_FULLPATH
        echo "---"                             >> $OUTPUT_FULLPATH

        #Echo the script generated warning.
        MSG="<!-- THIS PAGE IS GENERATED BY SCRIPT - DO NOT EDIT BY HAND -->";
        echo   "" >> $OUTPUT_FULLPATH;
        echo $MSG >> $OUTPUT_FULLPATH;
        echo $MSG >> $OUTPUT_FULLPATH;
        echo $MSG >> $OUTPUT_FULLPATH;
        echo   "" >> $OUTPUT_FULLPATH;

        #Echo the image.
        echo "![\"Certification\"]({{ page.assets }}$IMAGE_URL)" >> $OUTPUT_FULLPATH;

    done < $TEMP_FILENAMES_FILE;

    #Remove the temp file.
    rm $TEMP_FILENAMES_FILE;
}

clean_htmls_dir
create_certifications_pages
