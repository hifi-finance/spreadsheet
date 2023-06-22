// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Base_Test } from "../../Base.t.sol";

contract ClaimSheetsViaAllocation_Unit_Fuzz_Test is Base_Test {
    function setUp() public virtual override {
        Base_Test.setUp();
        createAndSetAllocationMerkleTree();
        bots.mint(address(users.alice), collectionSize);
        sheets.mint(address(spreadSheet), collectionSize);
    }

    function testFuzz_ClaimSheetsViaAllocation(uint256 claimSize) external {
        vm.pauseGasMetering();
        vm.assume(claimSize >= 1);
        vm.assume(claimSize <= allocationSize);

        uint256[] memory sheetIdsToClaim = new uint256[](claimSize);

        for (uint256 i; i < claimSize; ++i) {
            sheetIdsToClaim[i] = psuedoRandomUINT256From({ value: i, clock: allocationSize }) + transitionSize;
        }

        vm.prank(address(users.alice));
        bots.setApprovalForAll(address(spreadSheet), true);
        vm.prank(address(users.alice));
        vm.resumeGasMetering();
        spreadSheet.claimSheetsViaAllocation(sheetIdsToClaim, allocationSize, allAllocationProofs[0]);
    }
}
