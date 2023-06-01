// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/SpreadSheet.sol";
import { ERC721 } from "@openzeppelin/token/ERC721/ERC721.sol";

contract SpreadSheetTest is Test {
    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    SpreadSheet internal spreadSheet;
    IERC721 internal sheets;
    IERC721 internal bots;

    function setUp() public {
        // Deploy the base test contracts.
        sheets = new ERC721("SheetHeads", "SHEET");
        bots = new ERC721("Pawn Bots", "BOTS");
        spreadSheet = new SpreadSheet(sheets, bots);
    }

    function testClaimSheetsViaTransition() public {
        // TODO: implement
    }

    function testClaimSheetsViaAllocation() public {
        // TODO: implement
    }

    function testAdminWithdraw() public {
        // TODO: implement
    }

    function testPause() public {
        // TODO: implement
    }

    function testUnpause() public {
        // TODO: implement
    }

    function testSetTransitionMerkleRoot() public {
        // TODO: implement
    }

    function testSetAllocationMerkleRoot() public {
        // TODO: implement
    }
}
