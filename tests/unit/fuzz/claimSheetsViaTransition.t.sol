// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Base_Test } from "../../Base.t.sol";

contract ClaimSheetsViaTransition_Unit_Fuzz_Test is Base_Test {
    function setUp() public virtual override {
        Base_Test.setUp();
        Base_Test.setTransitionRoot();
        bots.mint(address(this), collectionSize);
        sheets.mint(address(spreadSheet), collectionSize);
    }

    function testFuzz_ClaimSheetsViaTransition(uint16 claimSize) external {
        vm.pauseGasMetering();
        vm.assume(claimSize >= 1);
        vm.assume(claimSize <= transitionTreeSize);

        uint256[] memory botsIdsToBurn = new uint256[](claimSize);
        uint256[] memory sheetIdsToClaim = new uint256[](claimSize);
        bytes32[][] memory transitionProofs = new bytes32[][](claimSize);

        for (uint256 i; i < claimSize; ++i) {
            setTransitionEntry(i);
            botsIdsToBurn[i] = botId__claimViaTransition;
            sheetIdsToClaim[i] = sheetId__claimViaTransition;
            transitionProofs[i] = proof__claimViaTransition;
        }

        bots.setApprovalForAll(address(spreadSheet), true);
        vm.prank(address(this));
        vm.resumeGasMetering();
        spreadSheet.claimSheetsViaTransition(sheetIdsToClaim, botsIdsToBurn, transitionProofs);
    }
}
