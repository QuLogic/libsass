#!/bin/bash

set -e

if [ "x$AUTOTOOLS" == "xnewer" ]; then
	sudo add-apt-repository -y ppa:rbose-debianizer/automake &> /dev/null
	sudo apt-get -qq update
	sudo apt-get -qq install automake
	sudo pip install cpp-coveralls --use-mirrors
	AUTOTOOLS=yes
	COVERAGE=--enable-coverage
fi

if [ "x$AUTOTOOLS" == "xyes" ]; then
	autoreconf
	./configure --enable-tests $COVERAGE \
	            --with-sassc-dir=$SASS_SASSC_PATH \
	            --with-sass-spec-dir=$SASS_SPEC_PATH
	make
else
	make ${SASS_SASSC_PATH}/bin/sassc
fi

set +e

make LOG_FLAGS=--skip VERBOSE=1 test
status=$?

if [ -n "$COVERAGE" ]; then
	coveralls --exclude lib --exclude tests
fi

exit $status

