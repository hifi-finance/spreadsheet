// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Merkle } from "murky/Merkle.sol";

import { BaseScript } from "../Base.s.sol";

import { Strings } from "../../contracts/libraries/Strings.sol";

/// @notice Generates a allocation merkle tree using the user-provided parameters.
contract AllocationMerkleTree is BaseScript {
    using Strings for bytes32[];

    Merkle internal immutable tree = new Merkle();

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
        for (uint256 i; i < allocatees.length; i++) {
            nodes[i] = keccak256(abi.encodePacked(allocatees[i], allocations[i]));
        }
        root = tree.getRoot(nodes);
        proofs = new string[](allocatees.length);
        for (uint256 i; i < allocatees.length; i++) {
            proofs[i] = tree.getProof(nodes, i).toJSONString();
        }
    }
}
