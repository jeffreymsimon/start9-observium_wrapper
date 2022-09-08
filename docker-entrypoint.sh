#!/bin/bash


if [[ -z "${SVN_USERNAME}" ]] && [[ -z "${SVN_PASSWORD}" ]]; then
  echo "You must set environment variables SVN_USERNAME and SVN_PASSWORD to update to latest code"
else
  svn update \
    --no-auth-cache \
    --non-interactive \
    --trust-server-cert \
    --username $SVN_USERNAME \
    --password $SVN_PASSWORD
fi

exec "$@"