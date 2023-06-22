// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Base_Test } from "../../Base.t.sol";

contract AdminWithdraw_Unit_Fuzz_Test is Base_Test {
    function setUp() public virtual override {
        Base_Test.setUp();
        sheets.mint(address(spreadSheet), collectionSize);
        spreadSheet.pauseClaims();
    }

    function testFuzz_AdminWithdraw(uint256 withdrawAmount) external {
        vm.pauseGasMetering();
        vm.assume(withdrawAmount >= 1);
        vm.assume(withdrawAmount <= collectionSize);

        uint256[] memory sheetIdsToWithdraw = new uint256[](withdrawAmount);

        for (uint256 i; i < withdrawAmount; ++i) {
            sheetIdsToWithdraw[i] = i;
        }

        bots.setApprovalForAll(address(spreadSheet), true);
        vm.resumeGasMetering();
        spreadSheet.adminWithdraw(users.admin, sheetIdsToWithdraw);
    }
}
