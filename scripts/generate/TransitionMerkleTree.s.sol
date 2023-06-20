// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { BaseScript } from "../Base.s.sol";

import { Merkle } from "../../contracts/libraries/Merkle.sol";

import { Strings } from "../../contracts/libraries/Strings.sol";

/// @notice Generates a transition merkle tree using the user-provided parameters.
contract TransitionMerkleTree is BaseScript {
    using Merkle for bytes32[];
    using Strings for bytes32[];

    /// @param botsIds The IDs of the BOTs to be transitioned.
    /// @param sheetIds The IDs of the SHEETs to be claimed.
    /// @return root The root of the Merkle tree.
    /// @return proofs The proofs for each leaf in the Merkle tree.
    function run(
        uint256[] memory botsIds,
        uint256[] memory sheetIds
    )
        public
        virtual
        returns (bytes32 root, string[] memory proofs)
    {
        bytes32[] memory nodes = new bytes32[](botsIds.length);
        for (uint256 i; i < nodes.length; i++) {
            nodes[i] = keccak256(abi.encodePacked(botsIds[i], sheetIds[i]));
        }
        bytes32[][] memory rawProofs;
        (root, rawProofs) = nodes.getTree();
        proofs = new string[](nodes.length);
        for (uint256 i; i < nodes.length; i++) {
            proofs[i] = rawProofs[i].toJSONString();
        }
    }
}
