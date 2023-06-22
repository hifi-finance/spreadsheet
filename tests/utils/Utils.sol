// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { StdUtils } from "forge-std/StdUtils.sol";

struct Users {
    // Default admin.
    address payable admin;
    // Alice is a user.
    address payable alice;
}

abstract contract Utils is StdUtils {
    /// @dev The Knuth constant used for generating pseudo-random numbers.
    uint256 private constant KNUTH_CONSTANT = 2_654_435_761;

    /// @dev Converts a given `uint256` to a pseudo-random `uint256`.
    function psuedoRandomUINT256From(uint256 value, uint256 clock) internal pure returns (uint256) {
        return (value * KNUTH_CONSTANT) % clock;
    }

    /// @dev Converts a given `uint256` to a pseudo-random `address`.
    function psuedoRandomAddressFrom(uint256 value) internal pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(value))) % type(uint160).max * KNUTH_CONSTANT));
    }
}
