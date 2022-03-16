.PHONY: lint

bundle:
	brew bundle

check:
	shellcheck sudo-touchid.sh
