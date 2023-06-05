// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/SpreadSheet.sol";
import { ERC721Mint } from "./mocks/ERC721Mint.sol";

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
        // TODO: implement
    }

    function testClaimSheetsViaAllocation() public {
        // TODO: implement
    }

    function testAdminWithdraw() public {
        uint256[] memory ids = new uint256[](3);
        ids[0] = 0;
        ids[1] = 1;
        ids[2] = 2;

        for (uint256 i; i < ids.length; i++) {
            sheets.mint(address(spreadSheet), ids[i]);
        }

        spreadSheet.pause();
        spreadSheet.adminWithdraw(address(this), ids);

        for (uint256 i; i < ids.length; i++) {
            assertEq(sheets.ownerOf(ids[i]), address(this));
        }
    }

    function testPause() public {
        spreadSheet.pause();
        assertEq(spreadSheet.paused(), true);
    }

    function testUnpause() public {
        spreadSheet.pause();
        assertEq(spreadSheet.paused(), true);
        spreadSheet.unpause();
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
