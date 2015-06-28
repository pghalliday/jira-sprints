#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
TMP_DIR=`mktemp -d -t jira-sprints.XXXXXXXXXX` && cd $TMP_DIR
pwd
npm install $DIR
node -e "var assert = require('assert'); var sprints = require('jira-sprints'); assert.equal(typeof sprints, 'function');"
rm -rf $TMP_DIR
