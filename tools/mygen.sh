#!/bin/bash -u

in_file=$1
src_files=$2
hdr_files=$3

fce_name=`cat ${in_file}`

mkdir -p $src_files
mkdir -p $hdr_files

cat > $src_files/main.c <<EOT
#include "files.h/another.h"

int main(void) {
    return MYFCE;
}
EOT

cat > $src_files/another.c <<EOT
#include "files.h/another.h"

int ${fce_name}(void) {
    return 0;
}
EOT

cat > $hdr_files/another.h <<EOT
#define MYFCE ${fce_name}
int ${fce_name}(void);
EOT

