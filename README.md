# SpreadSheet [![Github Actions][gha-badge]][gha] [![Foundry][foundry-badge]][foundry] [![pre-commit][pre-commit-badge]][pre-commit] [![License: MIT][license-badge]][license]

[gha]: https://github.com/hifi-finance/spreadsheet/actions
[gha-badge]: https://github.com/hifi-finance/spreadsheet/actions/workflows/ci.yml/badge.svg
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[license]: https://opensource.org/licenses/MIT
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg
[pre-commit]: https://pre-commit.com
[pre-commit-badge]: https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit

## Overview

The SpreadSheet contract is designed to handle the claim and distribution of SHEETs. The contract leverages two key mechanisms for this process - a burn-transition mechanism and an allocation mechanism.

## Contract Details

### High Level Description

- It allows users to claim SHEETs in two ways:
  - By burning Pawn Bots NFTs.
  - Via allocation, where certain addresses are pre-allocated SHEETs which they can claim.
- The claims are controlled and validated through Merkle proofs linked to respective Merkle roots for each mechanism.

### Functions

#### claimSheetsViaTransition

Allows a user to claim SHEETs in exchange for burning BOTS. The user needs to provide:

- An array of SHEET IDs they wish to claim
- An array of BOTS IDs they are willing to burn
- An array of Merkle proofs, each corresponding to a claim

Each BOTS ID should correspond to a SHEET ID and have a valid Merkle proof in the burn-transition Merkle tree.

#### claimSheetsViaAllocation

Allows a user to claim SHEETs that were allocated to their address. The user needs to provide:

- An array of SHEET IDs they wish to claim
- The total number of SHEETs allocated to them
- A Merkle proof proving their allocation

Each address can only claim up to the number of SHEETs allocated to them in the allocation Merkle tree.

#### adminWithdraw

Allows the contract owner to withdraw any SHEETs from the contract to a specific address. This function can only be executed when the contract is paused.

#### pause, unpause

Allows the contract owner to pause or unpause the contract, which toggles the ability of users to claim SHEETs and the ability of the contract owner to withdraw SHEETs.

#### setTransitionMerkleRoot, setAllocationMerkleRoot

Allows the contract owner to set the Merkle roots of the burn-transition and allocation Merkle trees, respectively.

## Installation

Run the following commands to install the project locally:

```sh
git clone https://github.com/hifi-finance/spreadsheet.git
cd spreadsheet
make
```

This project was built using [Foundry](https://book.getfoundry.sh/). Refer to installation instructions [here](https://github.com/foundry-rs/foundry#installation).

### Sensible Defaults

This project comes with sensible default configurations in the following files:

```text
├── .commitlintrc.yaml
├── .gitattributes
├── .gitignore
├── .gitmodules
├── .pre-commit-config.yaml
├── foundry.toml
├── makefile
└── remappings.txt
```

### VSCode Integration

This project is IDE agnostic, but for the best user experience, you may want to use it in VSCode with Hardhat's
[Solidity extension](https://github.com/NomicFoundation/hardhat-vscode).

For guidance on how to integrate a Foundry project in VSCode, please refer to this
[guide](https://book.getfoundry.sh/config/vscode).

### GitHub Actions

This project comes with GitHub Actions pre-configured. Your contracts will be linted and tested on every push and pull
request made to the `main` branch.

You can edit the CI script in [.github/workflows/ci.yml](./.github/workflows/ci.yml).

### Conventional Commits

This project enforces the [Conventional Commits](https://www.conventionalcommits.org/) standard for git commit
messages. This is a lightweight convention that creates an explicit commit history, which makes it easier to write
automated tools on top of.

## Commands

To make it easier to perform some tasks within the repo, a few commands are available through a [makefile](https://github.com/hifi-finance/spreadsheet/blob/main/makefile):

### Build Commands

| Command                               | Action                                                   |
| ------------------------------------- | -------------------------------------------------------- |
| `make build`                          | Compile all contracts in the repo, including submodules. |
| `make clean`                          | Delete the build artifacts and cache directories.        |
| `make install package=<PACKAGE_NAME>` | Install one or more dependencies.                        |
| `make fmt-check`                      | Lint the contracts.                                      |
| `make fmt-write`                      | Format the contracts.                                    |

### Test Commands

| Command           | Description                       |
| ----------------- | --------------------------------- |
| `make coverage`   | Get a test coverage report.       |
| `make test`       | Run all tests located in `test/`. |
| `make gas-report` | Get a gas report.                 |

Specific tests can be run using `forge test` conventions, specified in more detail in the Foundry [Book](https://book.getfoundry.sh/reference/forge/forge-test#test-options).

### Deploy Commands

| Command       | Description                                                                       |
| ------------- | --------------------------------------------------------------------------------- |
| `make deploy` | Deploy contract (e.g. `make deploy sheet=0x123... bots=0x123... network=mainnet`) |

For instructions on how to deploy to a testnet or mainnet, check out the
[Solidity Scripting tutorial](https://book.getfoundry.sh/tutorials/solidity-scripting.html).

## Notes

1. Foundry piggybacks off [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) to manage dependencies.
   There's a [guide](https://book.getfoundry.sh/projects/dependencies.html) about how to work with dependencies in the
   book.
2. You don't have to create a `.env` file, but filling in the environment variables may be useful when debugging and
   testing against a mainnet fork.

## License

[MIT](./LICENSE.md) © Mainframe Group Inc.
