// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { BaseScript } from "../Base.s.sol";

import { Merkle } from "../../contracts/libraries/Merkle.sol";

import { Strings } from "../../contracts/libraries/Strings.sol";

/// @notice Generates a transition merkle proof using the user-provided parameters.
contract TransitionMerkleProof is BaseScript {
    using Merkle for bytes32[];
    using Strings for bytes32[];

    /// @param botsIds The IDs of the BOTs to be transitioned.
    /// @param sheetIds The IDs of the SHEETs to be claimed.
    /// @param proofIndex The index of the proof to be returned.
    /// @return proof The proof of the Merkle tree.
    function run(
        uint256[] memory botsIds,
        uint256[] memory sheetIds,
        uint256 proofIndex
    )
        public
        virtual
        returns (string memory proof)
    {
        bytes32[] memory nodes = new bytes32[](botsIds.length);
        for (uint256 i; i < nodes.length; i++) {
            nodes[i] = keccak256(abi.encodePacked(botsIds[i], sheetIds[i]));
        }
        proof = nodes.getProof(proofIndex).toJSONString();
    }
}
