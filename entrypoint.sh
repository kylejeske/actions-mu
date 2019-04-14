#!/bin/sh
set -e
# Thanks to the AWS Cli for these
# Respect AWS_DEFAULT_REGION if specified
# [ -n "$AWS_DEFAULT_REGION" ] || export AWS_DEFAULT_REGION=us-east-1
# Respect AWS_DEFAULT_OUTPUT if specified
# [ -n "$AWS_DEFAULT_OUTPUT" ] || export AWS_DEFAULT_OUTPUT=json
# Capture output
#output=$( sh -c "aws $*" )
# Preserve output for consumption by downstream actions
#echo "$output" > "${HOME}/${GITHUB_ACTION}.${AWS_DEFAULT_OUTPUT}"
#echo "$output"

output=$( sh -c "mu $*" )
echo "$output"