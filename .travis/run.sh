#!/bin/bash
if [ ! -z ${CLEAN} ]; then
 bundle exec rake spec_clean
else
 bundle exec rake lint
 bundle exec rake spec_prep
 bundle exec rake spec_standalone
fi
