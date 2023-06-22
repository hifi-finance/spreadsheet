// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Base_Test } from "../../Base.t.sol";

contract SpreadSheet_Unit_Basic_Test is Base_Test {
    function setUp() public virtual override {
        Base_Test.setUp();
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
