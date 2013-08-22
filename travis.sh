#!/bin/bash

set -e

if [ "x$AUTOTOOLS" == "xnewer" ]; then
	echo -en 'travis_fold:start:update_automake\r'
	sudo add-apt-repository -y ppa:rbose-debianizer/automake
	sudo apt-get update
	sudo apt-get install automake
	echo -en 'travis_fold:end:update_automake\r'
	echo -en 'travis_fold:start:install_coveralls\r'
	sudo pip install cpp-coveralls --use-mirrors
	echo -en 'travis_fold:end:install_coveralls\r'
	AUTOTOOLS=yes
	COVERAGE=--enable-coverage
fi

if [ "x$AUTOTOOLS" == "xyes" ]; then
	echo -en 'travis_fold:start:configure\r'
	autoreconf
	./configure --enable-tests $COVERAGE \
	            --with-sassc-dir=$SASS_SASSC_PATH \
	            --with-sass-spec-dir=$SASS_SPEC_PATH
	echo -en 'travis_fold:end:configure\r'
	make
else
	make ${SASS_SASSC_PATH}/bin/sassc
fi

set +e

make LOG_FLAGS=--skip VERBOSE=1 AM_COLOR_TESTS=always test
status=$?

if [ -n "$COVERAGE" ]; then
	echo -en 'travis_fold:start:coveralls\r'
	coveralls --exclude .libs --exclude $SASS_SPEC_PATH
	echo -en 'travis_fold:end:coveralls\r'
fi

exit $status

