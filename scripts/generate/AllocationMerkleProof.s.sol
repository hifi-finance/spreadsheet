// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { BaseScript } from "../Base.s.sol";

import { Merkle } from "../../contracts/libraries/Merkle.sol";

import { Strings } from "../../contracts/libraries/Strings.sol";

/// @notice Generates a transition merkle proof using the user-provided parameters.
contract AllocationMerkleProof is BaseScript {
    using Merkle for bytes32[];
    using Strings for bytes32[];

    /// @param allocatees The accounts to be allocated SHEETs.
    /// @param allocations The amount of SHEETs to be allocated to each account.
    /// @param proofIndex The index of the proof to be returned.
    /// @return proof The proof of the Merkle tree.
    function run(
        address[] memory allocatees,
        uint256[] memory allocations,
        uint256 proofIndex
    )
        public
        virtual
        returns (string memory proof)
    {
        bytes32[] memory nodes = new bytes32[](allocatees.length);
        for (uint256 i; i < nodes.length; i++) {
            nodes[i] = keccak256(abi.encodePacked(allocatees[i], allocations[i]));
        }
        proof = nodes.getProof(proofIndex).toJSONString();
    }
}
