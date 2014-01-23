#!/bin/sh

#  run_jruby.sh
#  FontPrep
#
#  Created by Brian M. Gonzalez on 6/11/13.
#  Copyright (c) 2013 gnzlz. All rights reserved

cd ../fontprep_server && /usr/bin/java -Xmx512m -jar jruby-complete-1.7.3.jar ./app.rb $1 JRUBY_OPTS=--1.9
