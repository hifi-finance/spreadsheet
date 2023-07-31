// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Base_Test } from "../../Base.t.sol";

contract ClaimSheetsViaAllocation_Unit_Fuzz_Test is Base_Test {
    function setUp() public virtual override {
        Base_Test.setUp();
        Base_Test.setAllocationRoot();
        sheets.mint(address(spreadSheet), collectionSize);
    }

    function testFuzz_ClaimSheetsViaAllocation(uint16 claimSize, uint8 claimIndex) external {
        vm.assume(claimSize >= 1);
        vm.assume(claimIndex < allocationTreeSize);
        setAllocationEntry(claimIndex);
        vm.assume(claimSize <= allocation__claimViaAllocation);

        uint256[] memory sheetIdsToClaim = new uint256[](claimSize);

        for (uint256 i; i < claimSize; ++i) {
            sheetIdsToClaim[i] = allocationSheetIdStart + i;
        }

        vm.prank(allocatee__claimViaAllocation);
        bots.setApprovalForAll(address(spreadSheet), true);
        vm.prank(allocatee__claimViaAllocation);
        spreadSheet.claimSheetsViaAllocation(sheetIdsToClaim, allocation__claimViaAllocation, proof__claimViaAllocation);
    }
}
