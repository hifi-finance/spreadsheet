// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { Merkle as M } from "murky/Merkle.sol";

library Merkle {
    function getProof(bytes32[] memory nodes, uint256 index) internal returns (bytes32[] memory proof) {
        M tree = new M();
        proof = tree.getProof(nodes, index);
    }

    function getRoot(bytes32[] memory nodes) internal returns (bytes32 root) {
        M tree = new M();
        root = tree.getRoot(nodes);
    }
}
