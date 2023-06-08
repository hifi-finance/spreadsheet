// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Merkle } from "murky/Merkle.sol";

import { BaseScript } from "../Base.s.sol";

/// @notice Generates a allocation reserve merkle tree using the user-provided parameters.
contract AllocationReserveMerkleTree is BaseScript {
    Merkle internal immutable tree = new Merkle();

    /// @param sheetIds The IDs of the SHEETs to be claimed.
    /// @return root The root of the Merkle tree.
    /// @return proofs The proofs for each leaf in the Merkle tree.
    function run(uint256[] memory sheetIds) public virtual returns (bytes32 root, bytes32[][] memory proofs) {
        bytes32[] memory nodes = new bytes32[](sheetIds.length);
        for (uint256 i; i < sheetIds.length; i++) {
            nodes[i] = keccak256(abi.encodePacked(sheetIds[i]));
        }
        root = tree.getRoot(nodes);
        proofs = new bytes32[][](sheetIds.length);
        for (uint256 i; i < sheetIds.length; i++) {
            proofs[i] = tree.getProof(nodes, i);
        }
    }
}
