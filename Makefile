.PHONY: bundle check

bundle:
	brew bundle

check:
	shellcheck sudo-touchid.sh
