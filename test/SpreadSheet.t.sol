// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/SpreadSheet.sol";
import { ERC721Mint } from "./mocks/ERC721Mint.sol";
import { MerkleProof } from "@openzeppelin/utils/cryptography/MerkleProof.sol";
import "forge-std/console.sol";

contract SpreadSheetTest is Test {
    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    SpreadSheet internal spreadSheet;
    ERC721Mint internal sheets;
    ERC721Mint internal bots;

    function setUp() public {
        // Deploy the base test contracts.
        sheets = new ERC721Mint("SheetHeads", "SHEET");
        bots = new ERC721Mint("Pawn Bots", "BOTS");
        spreadSheet = new SpreadSheet(sheets, bots);
    }

    function testClaimSheetsViaTransition() public {
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = 0x44f9494ddace41673149b1ce2120e2a8dc5880bba93ff68e6b6c883c57a0c695;
        proof[1] = 0xcbc4e5fb02c3d1de23a9f1e014b4d2ee5aeaea9505df5e855c9210bf472495af;
        bytes32 leaf = keccak256(abi.encodePacked(uint256(1234), uint256(14)));
        bytes32 root = 0xf0b93ca8df1bab71e35019befbc9ca96f0eec759a63e645de229d4764e649549;
        assertEq(MerkleProof.verify(proof, root, leaf), true);

        bots.mint(address(this), 1234);
        sheets.mint(address(spreadSheet), 14);

        spreadSheet.setTransitionMerkleRoot(root);

        uint256[] memory botIdsToBurn = new uint256[](1);
        uint256[] memory sheetIdsToClaim = new uint256[](1);

        botIdsToBurn[0] = 1234;
        sheetIdsToClaim[0] = 14;

        bytes32[][] memory proofs = new bytes32[][](1);
        proofs[0] = proof;

        bots.setApprovalForAll(address(spreadSheet), true);
        vm.prank(address(this));
        spreadSheet.claimSheetsViaTransition(sheetIdsToClaim, botIdsToBurn, proofs);
    }

    function testClaimSheetsViaAllocation() public {
        // TODO: update this test to use the new allocation merkle root
        // bytes32[] memory proof = new bytes32[](1);
        // proof[0] = 0xcc4ae8f2af5b4bfc5bf63df104b924bb2f06595e3e8a992cf75e218dff7141c8;
        // bytes32 leaf = keccak256(abi.encodePacked(0xAA8FB2F69B0eb88dfA9690B79e766A7e05D2Abc5, uint256(12)));
        // bytes32 root = 0x42123b430d0c009c6c4028d90e1d0309d4037a62a516c2af802f4d9a32a57a04;
        // assertEq(MerkleProof.verify(proof, root, leaf), true);

        // uint256[] memory ids = new uint256[](12);
        // for (uint256 i; i < 12; i++) {
        //     ids[i] = i;
        //     sheets.mint(address(spreadSheet), i);
        // }

        // spreadSheet.setAllocationMerkleRoot(root);
        // vm.prank(0xAA8FB2F69B0eb88dfA9690B79e766A7e05D2Abc5);
        // spreadSheet.claimSheetsViaAllocation(ids, 12, proof);
        // for (uint256 i; i < ids.length; i++) {
        //     assertEq(sheets.ownerOf(ids[i]), address(0xAA8FB2F69B0eb88dfA9690B79e766A7e05D2Abc5));
        // }
    }

    function testAdminWithdraw() public {
        uint256[] memory ids = new uint256[](3);
        ids[0] = 0;
        ids[1] = 1;
        ids[2] = 2;

        for (uint256 i; i < ids.length; i++) {
            sheets.mint(address(spreadSheet), ids[i]);
        }

        spreadSheet.pauseClaims();
        spreadSheet.adminWithdraw(address(this), ids);

        for (uint256 i; i < ids.length; i++) {
            assertEq(sheets.ownerOf(ids[i]), address(this));
        }
    }

    function testPause() public {
        spreadSheet.pauseClaims();
        assertEq(spreadSheet.paused(), true);
    }

    function testUnpause() public {
        spreadSheet.pauseClaims();
        assertEq(spreadSheet.paused(), true);
        spreadSheet.unpauseClaims();
        assertEq(spreadSheet.paused(), false);
    }

    function testSetTransitionMerkleRoot() public {
        spreadSheet.setTransitionMerkleRoot("0x1234");
        assertEq(spreadSheet.transitionMerkleRoot(), "0x1234");
    }

    function testSetAllocationMerkleRoot() public {
        spreadSheet.setAllocationMerkleRoot("0x1234");
        assertEq(spreadSheet.allocationMerkleRoot(), "0x1234");
    }
}
