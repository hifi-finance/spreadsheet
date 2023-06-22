// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Base_Test } from "../../Base.t.sol";

contract ClaimSheets_Unit_Fuzz_Test is Base_Test {
    function setUp() public virtual override {
        Base_Test.setUp();
        createAndSetTransitionMerkleTree();
        createAndSetAllocationMerkleTree();
        bots.mint(address(users.alice), collectionSize);
        sheets.mint(address(spreadSheet), collectionSize);
    }

    function testFuzz_ClaimSheets(uint256 transitionClaimSize, uint256 allocationClaimSize) external {
        vm.pauseGasMetering();
        vm.assume(transitionClaimSize >= 1);
        vm.assume(transitionClaimSize <= transitionSize);
        vm.assume(allocationClaimSize >= 1);
        vm.assume(allocationClaimSize <= allocationSize);

        uint256[] memory botsIdsToBurnViaTransition = new uint256[](transitionClaimSize);
        uint256[] memory sheetIdsToClaimViaTransition = new uint256[](transitionClaimSize);
        bytes32[][] memory transitionProofArg = new bytes32[][](transitionClaimSize);

        for (uint256 i; i < transitionClaimSize; ++i) {
            botsIdsToBurnViaTransition[i] = psuedoRandomUINT256From({ value: i, clock: transitionSize });
            sheetIdsToClaimViaTransition[i] = i;
            transitionProofArg[i] = allTransitionProofs[i];
        }

        uint256[] memory sheetIdsToClaimViaAllocation = new uint256[](allocationClaimSize);

        for (uint256 i; i < allocationClaimSize; ++i) {
            sheetIdsToClaimViaAllocation[i] =
                psuedoRandomUINT256From({ value: i, clock: allocationSize }) + transitionSize;
        }

        vm.prank(address(users.alice));
        bots.setApprovalForAll(address(spreadSheet), true);

        vm.prank(address(users.alice));
        vm.resumeGasMetering();
        spreadSheet.claimSheets({
            sheetIdsToClaimViaTransition: sheetIdsToClaimViaTransition,
            sheetIdsToClaimViaAllocation: sheetIdsToClaimViaAllocation,
            botsIdsToBurnViaTransition: botsIdsToBurnViaTransition,
            allocationAmount: allocationSize,
            transitionProofs: transitionProofArg,
            allocationProof: allAllocationProofs[0]
        });
    }
}
