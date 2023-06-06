// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { Ownable } from "@openzeppelin/access/Ownable.sol";
import { Pausable } from "@openzeppelin/security/Pausable.sol";
import { IERC721 } from "@openzeppelin/token/ERC721/IERC721.sol";
import { MerkleProof } from "@openzeppelin/utils/cryptography/MerkleProof.sol";

/**
 *
 *     _____                          _ _____ _               _
 *    /  ___|                        | /  ___| |             | |
 *    \ `--. _ __  _ __ ___  __ _  __| \ `--.| |__   ___  ___| |_
 *     `--. \ '_ \| '__/ _ \/ _` |/ _` |`--. \ '_ \ / _ \/ _ \ __|
 *    /\__/ / |_) | | |  __/ (_| | (_| /\__/ / | | |  __/  __/ |_
 *    \____/| .__/|_|  \___|\__,_|\__,_\____/|_| |_|\___|\___|\__|
 *          | |
 *          |_|
 */

/// @title SpreadSheet
/// @notice Handles the claim and distribution of SHEETs.
contract SpreadSheet is Ownable, Pausable {
    /*//////////////////////////////////////////////////////////////////////////
                                       ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the number of SHEETs an allocatee is trying to claim exceeds their allocation.
    error SpreadSheet__AllocationExceeded();

    /// @notice Thrown when the provided Merkle proof is invalid.
    error SpreadSheet__InvalidProof();

    /// @notice Thrown when the provided arrays are not the same length.
    error SpreadSheet__MismatchedArrays();

    /// @notice Thrown when the caller is trying to claim 0 SHEETs.
    error SpreadSheet__ZeroClaim();

    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when claiming SHEETs in exchange for burning BOTS.
    /// @param allocatee The account that claimed the SHEETs.
    /// @param sheetIds The IDs of the SHEETs that were claimed.
    /// @param botsIds The IDs of the BOTS that were burned.
    event ClaimedSheetsViaTransition(address indexed allocatee, uint256[] sheetIds, uint256[] botsIds);

    /// @notice Emitted when claiming SHEETs that were allocated to the caller account.
    /// @param allocatee The account that claimed the SHEETs.
    /// @param sheetIds The IDs of the SHEETs that were claimed.
    /// @param totalAllocated The total number of SHEETs allocated to the caller.
    event ClaimedSheetsViaAllocation(address indexed allocatee, uint256[] sheetIds, uint256 totalAllocated);

    /// @notice Emitted when the owner withdraws SHEETs from the contract.
    /// @param recipient The account that received the SHEETs.
    /// @param sheetIds The IDs of the SHEETs that were withdrawn.
    event AdminWithdraw(address indexed recipient, uint256[] sheetIds);

    /// @notice Emitted when the owner pauses the claim process.
    event Pause();

    /// @notice Emitted when the owner unpauses the claim process.
    event Unpause();

    /// @notice Emitted when the transition Merkle root is set.
    /// @param newTransitionMerkleRoot The new transition Merkle root.
    event SetTransitionMerkleRoot(bytes32 newTransitionMerkleRoot);

    /// @notice Emitted when the allocation Merkle root is set.
    /// @param newAllocationMerkleRoot The new allocation Merkle root.
    event SetAllocationMerkleRoot(bytes32 newAllocationMerkleRoot);

    /*//////////////////////////////////////////////////////////////////////////
                                   PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The Sheetheads NFT contract whose tokens are to be distributed.
    IERC721 public immutable sheetNFT;

    /// @notice The Pawn Bots NFT contract whose tokens are to be burned.
    IERC721 public immutable botsNFT;

    /// @notice The Merkle root of the BOTS -> SHEET transition Merkle tree.
    bytes32 public transitionMerkleRoot;

    /// @notice The Merkle root of the SHEET allocation Merkle tree.
    bytes32 public allocationMerkleRoot;

    /// @notice The total number of SHEETs claimed by an allocatee.
    mapping(address => uint256) public totalClaimedByAllocatee;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @param _sheetNFT The Sheetheads NFT contract whose tokens are to be distributed.
    /// @param _botsNFT The Pawn Bots NFT contract whose tokens are to be burned.
    constructor(IERC721 _sheetNFT, IERC721 _botsNFT) {
        sheetNFT = _sheetNFT;
        botsNFT = _botsNFT;
    }

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Claim SHEETs in exchange for burning BOTS.
    ///
    /// @dev Emits a {ClaimedSheetsViaTransition} event.
    ///
    /// Requirements:
    /// - All provided arrays must be the same length.
    /// - The number of SHEETs to claim must be greater than 0.
    /// - Each provided Merkle proof of a SHEET ID being linked to a corresponding BOTS ID must be valid.
    /// - The caller must own all of the BOTS IDs to burn.
    ///
    /// @param sheetIdsToClaim The IDs of the SHEETs to claim.
    /// @param botsIdsToBurn The IDs of the BOTS to burn.
    /// @param proofs The Merkle proofs for verifying claims.
    function claimSheetsViaTransition(
        uint256[] calldata sheetIdsToClaim,
        uint256[] calldata botsIdsToBurn,
        bytes32[][] calldata proofs
    )
        external
        whenNotPaused
    {
        if (sheetIdsToClaim.length != botsIdsToBurn.length || sheetIdsToClaim.length != proofs.length) {
            revert SpreadSheet__MismatchedArrays();
        }
        if (sheetIdsToClaim.length == 0) {
            revert SpreadSheet__ZeroClaim();
        }
        for (uint256 i = 0; i < sheetIdsToClaim.length; i++) {
            bytes32 node = keccak256(abi.encodePacked(botsIdsToBurn[i], sheetIdsToClaim[i]));
            if (!MerkleProof.verify(proofs[i], transitionMerkleRoot, node)) {
                revert SpreadSheet__InvalidProof();
            }
            botsNFT.transferFrom({ from: msg.sender, to: address(0xdead), tokenId: botsIdsToBurn[i] });
            sheetNFT.transferFrom({ from: address(this), to: msg.sender, tokenId: sheetIdsToClaim[i] });
        }
        emit ClaimedSheetsViaTransition({ allocatee: msg.sender, sheetIds: sheetIdsToClaim, botsIds: botsIdsToBurn });
    }

    /// @notice Claim SHEETs that were allocated to the caller account.
    ///
    /// @dev Emits a {ClaimedSheetsViaAllocation} event.
    ///
    /// Requirements:
    /// - All provided arrays must be the same length.
    /// - The number of SHEETs to claim must be greater than 0.
    /// - The number of SHEETs to claim must not exceed the number of SHEETs allocated to the caller account.
    /// - Each provided Merkle proof must be valid.
    ///
    /// @param sheetIdsToClaim The IDs of the SHEETs to claim.
    /// @param totalAllocated The total number of SHEETs allocated to the caller.
    /// @param proof The Merkle proof for verifying claim.
    function claimSheetsViaAllocation(
        uint256[] calldata sheetIdsToClaim,
        uint256 totalAllocated,
        bytes32[] calldata proof
    )
        external
        whenNotPaused
    {
        if (sheetIdsToClaim.length == 0) {
            revert SpreadSheet__ZeroClaim();
        }
        if (sheetIdsToClaim.length > totalAllocated - totalClaimedByAllocatee[msg.sender]) {
            revert SpreadSheet__AllocationExceeded();
        }
        totalClaimedByAllocatee[msg.sender] += sheetIdsToClaim.length;
        bytes32 node = keccak256(abi.encodePacked(msg.sender, totalAllocated));
        if (!MerkleProof.verify(proof, allocationMerkleRoot, node)) {
            revert SpreadSheet__InvalidProof();
        }
        for (uint256 i = 0; i < sheetIdsToClaim.length; i++) {
            sheetNFT.transferFrom({ from: address(this), to: msg.sender, tokenId: sheetIdsToClaim[i] });
        }
        emit ClaimedSheetsViaAllocation({
            allocatee: msg.sender,
            sheetIds: sheetIdsToClaim,
            totalAllocated: totalAllocated
        });
    }

    /// @notice Withdraw SHEETs from the contract.
    ///
    /// @dev Emits a {AdminWithdraw} event.
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    /// @param recipient The address to withdraw to.
    /// @param sheetIds The IDs of the SHEETs to withdraw.
    function adminWithdraw(address recipient, uint256[] calldata sheetIds) external onlyOwner whenPaused {
        for (uint256 i = 0; i < sheetIds.length; i++) {
            sheetNFT.transferFrom({ from: address(this), to: recipient, tokenId: sheetIds[i] });
        }
        emit AdminWithdraw({ recipient: recipient, sheetIds: sheetIds });
    }

    /// @notice Pause the claim process.
    ///
    /// @dev Emits a {Pause} event.
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    function pause() external onlyOwner {
        _pause();
        emit Pause();
    }

    /// @notice Unpause the claim process.
    ///
    /// @dev Emits an {Unpause} event.
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    function unpause() external onlyOwner {
        _unpause();
        emit Unpause();
    }

    /// @notice Set the Merkle root of the SHEET allocation Merkle tree.
    ///
    /// @dev Emits a {SetTransitionMerkleRoot} event.
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    /// @param newTransitionMerkleRoot The new transition Merkle root.
    function setTransitionMerkleRoot(bytes32 newTransitionMerkleRoot) external onlyOwner {
        transitionMerkleRoot = newTransitionMerkleRoot;
        emit SetTransitionMerkleRoot(newTransitionMerkleRoot);
    }

    /// @notice Set the Merkle root of the BOTS -> SHEET transition Merkle tree.
    ///
    /// @dev Emits a {SetAllocationMerkleRoot} event.
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    /// @param newAllocationMerkleRoot The new allocation Merkle root.
    function setAllocationMerkleRoot(bytes32 newAllocationMerkleRoot) external onlyOwner {
        allocationMerkleRoot = newAllocationMerkleRoot;
        emit SetAllocationMerkleRoot(newAllocationMerkleRoot);
    }
}
