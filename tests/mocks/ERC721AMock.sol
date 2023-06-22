// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { ERC721AQueryableMock } from "erc721a/mocks/ERC721AQueryableMock.sol";

/// @notice ERC721A mock contract.
contract ERC721AMock is ERC721AQueryableMock {
    constructor(string memory name_, string memory symbol_) ERC721AQueryableMock(name_, symbol_) { }

    function mint(address to, uint256 quantity) public {
        _mint(to, quantity);
    }
}
