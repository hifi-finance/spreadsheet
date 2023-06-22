// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IERC721 } from "@openzeppelin/token/ERC721/IERC721.sol";
import { ERC721AMock } from "tests/mocks/ERC721AMock.sol";
import { SpreadSheet } from "contracts/SpreadSheet.sol";
import { Merkle } from "contracts/libraries/Merkle.sol";
import { Test } from "forge-std/Test.sol";
import { Users, Utils } from "tests/utils/Utils.sol";

/// @notice Base test contract with common functionality for all tests.
abstract contract Base_Test is Utils, Test {
    /*//////////////////////////////////////////////////////////////////////////
                                     VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    Users internal users;
    bytes32[][] internal allTransitionProofs;
    bytes32[][] internal allAllocationProofs;

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    SpreadSheet internal spreadSheet;
    ERC721AMock internal sheets;
    ERC721AMock internal bots;

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    uint256 internal constant collectionSize = 8888;
    uint256 internal constant allocationSize = 1809;
    uint256 internal constant transitionSize = collectionSize - allocationSize;
    uint256 private constant knuthConstant = 2_654_435_761;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        // Deploy the base test contracts.
        sheets = new ERC721AMock("SheetHeads", "SHEET");
        bots = new ERC721AMock("Pawn Bots", "BOTS");
        spreadSheet = new SpreadSheet(IERC721(address(sheets)), IERC721(address(bots)), transitionSize);

        // Create users for testing.
        users = Users({ admin: createUser("Admin"), alice: createUser("Alice") });
    }

    /// @dev Generates a user, labels its address, and funds it with test assets.
    function createUser(string memory name) internal returns (address payable) {
        address payable user = payable(makeAddr(name));
        vm.deal({ account: user, newBalance: 100 ether });
        return user;
    }

    /// @dev Creates the transition merkle tree.
    function createAndSetTransitionMerkleTree() internal returns (bytes32) {
        bytes32[] memory transitionNodes = new bytes32[](transitionSize);
        for (uint256 i; i < transitionNodes.length; ++i) {
            transitionNodes[i] =
                keccak256(abi.encodePacked(psuedoRandomUINT256From({ value: i, clock: transitionSize }), i));
        }
        bytes32 transitionRoot;
        (transitionRoot, allTransitionProofs) = Merkle.getTree(transitionNodes);
        spreadSheet.setTransitionMerkleRoot(transitionRoot);
        return transitionRoot;
    }

    /// @dev Creates the allocation merkle tree.
    function createAndSetAllocationMerkleTree() internal returns (bytes32) {
        bytes32[] memory allocationNodes = new bytes32[](allocationSize);
        for (uint256 i; i < allocationNodes.length; ++i) {
            allocationNodes[i] = keccak256(abi.encodePacked(psuedoRandomAddressFrom(i), allocationSize));
        }
        allocationNodes[0] = keccak256(abi.encodePacked(users.alice, allocationSize));
        bytes32 allocationRoot;
        (allocationRoot, allAllocationProofs) = Merkle.getTree(allocationNodes);
        spreadSheet.setAllocationMerkleRoot(allocationRoot);
        return allocationRoot;
    }
}
