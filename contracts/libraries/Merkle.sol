// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { Merkle as M } from "murky/Merkle.sol";

library Merkle {
    function getTree(bytes32[] memory nodes) internal returns (bytes32 root, bytes32[][] memory proofs) {
        M tree = new M();
        root = tree.getRoot(nodes);
        proofs = new bytes32[][](nodes.length);
        for (uint256 i; i < nodes.length; ++i) {
            proofs[i] = tree.getProof(nodes, i);
        }
    }
}
