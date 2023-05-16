// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { IERC721 } from "@openzeppelin/token/ERC721/IERC721.sol";
import { MerkleProof } from "@openzeppelin/utils/cryptography/MerkleProof.sol";
import { Ownable } from "@openzeppelin/access/Ownable.sol";

/// @title SpreadSheet
/// @notice Handles the distribution of Sheetheads via Merkle trees.
contract SpreadSheet is Ownable {
    error SpreadSheet__AllocationExceeded();
    error SpreadSheet__InvalidProof();
    error SpreadSheet__MismatchedArrays();
    error SpreadSheet__NoSheetsToClaim();

    /// @notice The Sheetheads NFT contract whose tokens are to be distributed.
    IERC721 public immutable sheetNFT;

    /// @notice The Pawn Bots NFT contract whose tokens are to be burned.
    IERC721 public immutable botsNFT;

    /// @notice The Merkle root of the BOTS -> SHEET transition Merkle tree.
    bytes32 public transitionMerkleRoot;

    /// @notice The Merkle root of the SHEET account allocation Merkle tree.
    bytes32 public allocationMerkleRoot;

    /// @notice The total number of SHEETs claimed by an allocatee.
    mapping(address => uint256) public totalClaimedByAllocatee;

    constructor(IERC721 _sheetNFT, IERC721 _botsNFT) {
        sheetNFT = _sheetNFT;
        botsNFT = _botsNFT;
    }

    /// @notice Claim SHEETs in exchange for burning BOTS.
    /// @param sheetIdsToClaim The IDs of the SHEETs to claim.
    /// @param botsIdsToBurn The IDs of the BOTS to burn.
    /// @param proofs The Merkle proofs for verifying eligibility.
    function claimSheetsViaTransition(
        uint256[] calldata sheetIdsToClaim,
        uint256[] calldata botsIdsToBurn,
        bytes32[][] calldata proofs
    )
        external
    {
        if (botsIdsToBurn.length != sheetIdsToClaim.length || botsIdsToBurn.length != proofs.length) {
            revert SpreadSheet__MismatchedArrays();
        }
        if (sheetIdsToClaim.length == 0) {
            revert SpreadSheet__NoSheetsToClaim();
        }

        for (uint256 i = 0; i < botsIdsToBurn.length; i++) {
            bytes32 node = keccak256(abi.encodePacked(botsIdsToBurn[i], sheetIdsToClaim[i]));
            if (!MerkleProof.verify(proofs[i], transitionMerkleRoot, node)) {
                revert SpreadSheet__InvalidProof();
            }
            botsNFT.transferFrom(msg.sender, address(0), botsIdsToBurn[i]);
            sheetNFT.transferFrom(address(this), msg.sender, sheetIdsToClaim[i]);
        }
    }

    /// @notice Claim SHEETs that were allocated to the caller EOA.
    /// @param sheetIdsToClaim The IDs of the SHEETs to claim.
    /// @param totalAllocated The total number of SHEETs allocated to the caller.
    /// @param proofs The Merkle proofs for verifying eligibility.
    function claimSheetsViaAllocation(
        uint256[] calldata sheetIdsToClaim,
        uint256 totalAllocated,
        bytes32[][] calldata proofs
    )
        external
    {
        if (sheetIdsToClaim.length != proofs.length) {
            revert SpreadSheet__MismatchedArrays();
        }
        if (sheetIdsToClaim.length == 0) {
            revert SpreadSheet__NoSheetsToClaim();
        }
        if (sheetIdsToClaim.length > totalAllocated - totalClaimedByAllocatee[msg.sender]) {
            revert SpreadSheet__AllocationExceeded();
        }

        totalClaimedByAllocatee[msg.sender] += sheetIdsToClaim.length;

        for (uint256 i = 0; i < sheetIdsToClaim.length; i++) {
            bytes32 node = keccak256(abi.encodePacked(msg.sender, totalAllocated));
            if (!MerkleProof.verify(proofs[i], allocationMerkleRoot, node)) {
                revert SpreadSheet__InvalidProof();
            }
            sheetNFT.transferFrom(address(this), msg.sender, sheetIdsToClaim[i]);
        }
    }

    /// @notice Set the Merkle root of the SHEET account allocation Merkle tree.
    function setTransitionMerkleRoot(bytes32 _transitionMerkleRoot) external onlyOwner {
        transitionMerkleRoot = _transitionMerkleRoot;
    }

    /// @notice Set the Merkle root of the BOTS -> SHEET transition Merkle tree.
    function setAllocationMerkleRoot(bytes32 _allocationMerkleRoot) external onlyOwner {
        allocationMerkleRoot = _allocationMerkleRoot;
    }
}
