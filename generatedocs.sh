#!/bin/bash
if which jazzy >/dev/null; then
	jazzy --config "${BASH_SOURCE%/*}/.jazzy.yaml" --output "${BASH_SOURCE%/*}/docs"
else
	echo "Jazzy not installed, use 'gem install jazzy' or download from https://github.com/realm/jazzy"
fi