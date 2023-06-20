// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { BaseScript } from "../Base.s.sol";

import { Merkle } from "../../contracts/libraries/Merkle.sol";

import { Strings } from "../../contracts/libraries/Strings.sol";

/// @notice Generates a allocation merkle tree using the user-provided parameters.
contract AllocationMerkleTree is BaseScript {
    using Merkle for bytes32[];
    using Strings for bytes32[];

    /// @param allocatees The accounts to be allocated SHEETs.
    /// @param allocations The amount of SHEETs to be allocated to each account.
    /// @return root The root of the Merkle tree.
    /// @return proofs The proofs for each leaf in the Merkle tree.
    function run(
        address[] memory allocatees,
        uint256[] memory allocations
    )
        public
        virtual
        returns (bytes32 root, string[] memory proofs)
    {
        bytes32[] memory nodes = new bytes32[](allocatees.length);
        for (uint256 i; i < nodes.length; i++) {
            nodes[i] = keccak256(abi.encodePacked(allocatees[i], allocations[i]));
        }
        bytes32[][] memory rawProofs;
        (root, rawProofs) = nodes.getTree();
        proofs = new string[](nodes.length);
        for (uint256 i; i < nodes.length; i++) {
            proofs[i] = rawProofs[i].toJSONString();
        }
    }
}
