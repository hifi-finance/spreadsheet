// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Merkle } from "murky/Merkle.sol";

import { BaseScript } from "../Base.s.sol";

import { Strings } from "../../contracts/libraries/Strings.sol";

/// @notice Generates a transition merkle tree using the user-provided parameters.
contract TransitionMerkleTree is BaseScript {
    using Strings for bytes32[];

    Merkle internal immutable tree = new Merkle();

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
        for (uint256 i; i < botsIds.length; i++) {
            nodes[i] = keccak256(abi.encodePacked(botsIds[i], sheetIds[i]));
        }
        root = tree.getRoot(nodes);
        proofs = new string[](botsIds.length);
        for (uint256 i; i < botsIds.length; i++) {
            proofs[i] = tree.getProof(nodes, i).toJSONString();
        }
    }
}
