// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Base_Test } from "../../Base.t.sol";

contract ClaimSheets_Unit_Fuzz_Test is Base_Test {
    function setUp() public virtual override {
        Base_Test.setUp();
        Base_Test.setTransitionRoot();
        Base_Test.setAllocationRoot();
        sheets.mint(address(spreadSheet), collectionSize);
    }

    function testFuzz_ClaimSheets(
        uint16 transitionClaimSize,
        uint16 allocationClaimSize,
        uint8 allocationClaimIndex
    )
        external
    {
        vm.pauseGasMetering();
        vm.assume(transitionClaimSize >= 1);
        vm.assume(transitionClaimSize <= transitionTreeSize);
        vm.assume(allocationClaimSize >= 1);
        vm.assume(allocationClaimIndex < allocationTreeSize);
        setAllocationEntry(allocationClaimIndex);
        vm.assume(allocationClaimSize <= allocation__claimViaAllocation);

        bots.mint(allocatee__claimViaAllocation, collectionSize);

        uint256[] memory botsIdsToBurnViaTransition = new uint256[](transitionClaimSize);
        uint256[] memory sheetIdsToClaimViaTransition = new uint256[](transitionClaimSize);
        bytes32[][] memory transitionProofArg = new bytes32[][](transitionClaimSize);

        for (uint256 i; i < transitionClaimSize; ++i) {
            setTransitionEntry(i);
            botsIdsToBurnViaTransition[i] = botId__claimViaTransition;
            sheetIdsToClaimViaTransition[i] = sheetId__claimViaTransition;
            transitionProofArg[i] = proof__claimViaTransition;
        }

        uint256[] memory sheetIdsToClaimViaAllocation = new uint256[](allocationClaimSize);

        for (uint256 i; i < allocationClaimSize; ++i) {
            sheetIdsToClaimViaAllocation[i] = allocationSheetIdStart + i;
        }

        vm.prank(allocatee__claimViaAllocation);
        bots.setApprovalForAll(address(spreadSheet), true);

        vm.prank(allocatee__claimViaAllocation);
        vm.resumeGasMetering();
        spreadSheet.claimSheets({
            sheetIdsToClaimViaTransition: sheetIdsToClaimViaTransition,
            sheetIdsToClaimViaAllocation: sheetIdsToClaimViaAllocation,
            botsIdsToBurnViaTransition: botsIdsToBurnViaTransition,
            allocationAmount: allocation__claimViaAllocation,
            transitionProofs: transitionProofArg,
            allocationProof: proof__claimViaAllocation
        });
    }
}
