#!/bin/sh

REPO=.

mvn deploy:deploy-file -Dfile=libdashboard.swc \
                       -DgroupId=com.adobe.flex \
                       -DartifactId=libdashboard \
                       -Dversion=1.0 \
                       -Dpackaging=swc \
                       -DcreateChecksum=true \
                       -DgeneratePom=true \
                       -Durl=file://$REPO
