#!/bin/sh
which node
which grunt
ls -al /var/www/sharelatex/migrations
cd /var/www/sharelatex && grunt migrate -v
