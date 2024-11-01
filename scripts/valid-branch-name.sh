#!/bin/bash

BRANCH_NAME="$1"
CONFIG_FILE=(config/*action-config.ini)

WARNING_MSG="[WARN]"
ERROR_MSG="[ERROR]"

# The script loads the workflow's configuration file to retrieve
# the section with valid branch names for the project. If no
# configuration file is found, it applies a default set of valid
# branch names.
if [[ ! -f ${CONFIG_FILE[0]} ]]; then
  echo "$WARNING_MSG Configuration file not found. Applying default
branch naming conventions."
  prefixes=feature,hotfix,release,docs
else
  # Creates an array containing all the defined branch names in the
  # configuration file.
  prefixes=$(awk \
                -F'=' \
                '/^\[branches\]/{f=1} f==1 && \
                /^prefixes=/{print $2; exit}' "${CONFIG_FILE[0]}" | \
                tr -d ' ')
fi

IFS=',' read -r -a prefixes_array <<< "$prefixes"

# Performs the branch naming check looping all over the defined names
# in the configuration file and returns exit failure if naming
# conventions are not being followed.
is_valid=false
for prefix in "${prefixes_array[@]}"; do
  if [[ $prefix != '' && "$BRANCH_NAME" == "$prefix"/* ]]; then
    is_valid=true
    break
  fi
done

if ! $is_valid; then
  echo "$ERROR_MSG Branch name '$BRANCH_NAME' does not follow naming
conventions. Please, update the branch name to comply with them."
  exit 1
fi
