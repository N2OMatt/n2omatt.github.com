#!/bin/bash
##
## Author:  N2OMatt
## Date:    12 Dec 2015
## License: GPLv3
##
## This script will scan the Certification directory and generate
## for each certification a image with same name in the assets directory.
##

################################################################################
## Vars                                                                       ##
################################################################################
SITE_ROOT_PATH=$(realpath $PWD/../..)
SOURCE_PATH=$SITE_ROOT_PATH/_mycerts
IMAGES_PATH=$SITE_ROOT_PATH/assets/certs

################################################################################
## Functions                                                                  ##
################################################################################
clean_images_dir()
{
    echo "Cleaning ($IMAGES_PATH) dir...";
    #Force make as new.
    rm    -rf $IMAGES_PATH;
    mkdir -p  $IMAGES_PATH;
}

copy_certifications()
{
    #Change the current directory to ease the find calls.
    cd $SOURCE_PATH

    echo "Creating directories..."

    #Create the directories.
    find ./* -not \( -path '*/\.*' -or -path '*/_*' \)    \
             -type d                                      \
             -exec mkdir -p "$IMAGES_PATH/{}" \;

    echo "Copying PDFs..."

    #Copy the certifications.
    find ./* -not \( -path '*/\.*' -or -path '*/_*' \) \
             -type f                                   \
             -exec cp {} "$IMAGES_PATH/{}" \;

    #Change back the current directory.
    cd --
}

create_images()
{
    #Change the directory to ease the paths manipulation.
    cd $IMAGES_PATH;

    echo "Generating images..."
    find . -iname "*.pdf" \
           -exec bash -c "convert_pdf_to_img \"{}\"" \;

    #Change back the current directory.
    cd --
}

convert_pdf_to_img()
{
    PDF_NAME=$1
    JPG_NAME=$(echo $PDF_NAME | sed s/pdf/jpg/g);

    echo "Converting..."
    echo $PDF_NAME
    echo $JPG_NAME

    #Convert to JPG.
    convert -background white \
            -alpha remove     \
            -density 288      \
            "$PDF_NAME"       \
            "$JPG_NAME"

    #Delete the PDF.
    echo "Deleting ($PDF_NAME)..."
    rm "$PDF_NAME";

    echo "";
}
export -f convert_pdf_to_img

################################################################################
## Script Initialization                                                      ##
################################################################################
clean_images_dir
copy_certifications
create_images
