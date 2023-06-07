# Include .env file if it exists and export its env vars.
-include .env

# Set the default goal to setup.
.DEFAULT_GOAL := setup

# Prepare the local development environment.
setup::
	@sh .shell/setup.sh

# Run Foundry scripts.
#
# Prerequisites:
# - [Foundry](https://getfoundry.sh)
build::
	@forge build

clean::
	@forge clean

coverage::
	@forge coverage

deploy::
	@forge script script/deploy/SpreadSheet.s.sol\
		--broadcast\
		--rpc-url $(network)\
		--sig "run(address,address)"\
		$(sheet)\
		$(bots)\

fmt-check::
	@forge fmt --check

fmt-write::
	@forge fmt

generate-allocation-merkle-tree::
	@sh .shell/generate-allocation-merkle-tree.sh $(csv_file)

generate-transition-merkle-tree::
	@sh .shell/generate-transition-merkle-tree.sh $(csv_file)

gas-report::
	@forge test --gas-report

install::
	@forge install --no-commit $(package)

test::
	@forge test

update::
	@forge update

watch::
	@forge test --watch contracts/
