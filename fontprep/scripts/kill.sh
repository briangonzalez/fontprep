#!/bin/sh

#  kill.sh
#  FontPrep
#
#  Created by Brian M. Gonzalez on 9/16/13.
#  Copyright (c) 2013 gnzlz. All rights reserved.

cd ../fontprep_server && /usr/bin/ruby -e "require './application/lib/runner.rb'; FontPrepRunner.kill"