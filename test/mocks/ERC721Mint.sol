// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { ERC721 } from "@openzeppelin/token/ERC721/ERC721.sol";

/// @notice An implementation of ERC-721 that allows minting tokens.
contract ERC721Mint is ERC721 {
    constructor(string memory name, string memory symbol) ERC721(name, symbol) { }

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}
