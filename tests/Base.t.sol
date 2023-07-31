// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IERC721 } from "@openzeppelin/token/ERC721/IERC721.sol";
import { Strings } from "@openzeppelin/utils/Strings.sol";
import { ERC721AMock } from "tests/mocks/ERC721AMock.sol";
import { SpreadSheet } from "contracts/SpreadSheet.sol";
import { Merkle } from "contracts/libraries/Merkle.sol";
import { Test } from "forge-std/Test.sol";
import { stdJson } from "forge-std/StdJson.sol";
import { Users } from "tests/utils/Utils.sol";

/// @notice Base test contract with common functionality for all tests.
abstract contract Base_Test is Test {
    using stdJson for string;
    using Strings for uint256;
    using Strings for bytes;

    /*//////////////////////////////////////////////////////////////////////////
                                     VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    Users internal users;
    uint256 internal transitionTreeSize;
    string internal transitionJSON;
    uint256 internal allocationTreeSize;
    string internal allocationJSON;
    uint256 internal allocationSheetIdStart;
    uint256 internal totalAllocation;
    uint256 internal botId__claimViaTransition;
    uint256 internal sheetId__claimViaTransition;
    bytes32[] internal proof__claimViaTransition;
    address internal allocatee__claimViaAllocation;
    uint256 internal allocation__claimViaAllocation;
    bytes32[] internal proof__claimViaAllocation;
    string internal allocationPath = "/tests/mocks/data/mock-allocation-merkle-tree.json";
    string internal transitionPath = "/tests/mocks/data/mock-transition-merkle-tree.json";

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    SpreadSheet internal spreadSheet;
    ERC721AMock internal sheets;
    ERC721AMock internal bots;

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    uint256 internal constant collectionSize = 8888;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        // Infer config from Merkle tree JSON files.
        allocationJSON = vm.readFile(string.concat(vm.projectRoot(), allocationPath));
        transitionJSON = vm.readFile(string.concat(vm.projectRoot(), transitionPath));
        allocationTreeSize = allocationJSON.readStringArray(".tree").length;
        transitionTreeSize = transitionJSON.readStringArray(".tree").length;
        for (uint256 i; i < allocationTreeSize; ++i) {
            totalAllocation += allocationJSON.readUint(string.concat(".tree.[", i.toString(), "].allocation"));
        }
        allocationSheetIdStart = collectionSize - totalAllocation;

        // Deploy the base test contracts and set config.
        sheets = new ERC721AMock("SheetHeads", "SHEET");
        bots = new ERC721AMock("Pawn Bots", "BOTS");
        spreadSheet = new SpreadSheet(IERC721(address(sheets)), IERC721(address(bots)), allocationSheetIdStart);

        // Create users for testing.
        users = Users({ admin: createUser("Admin"), alice: createUser("Alice") });
    }

    /// @notice Create a transition tree entry for the given tree index.
    function setTransitionEntry(uint256 index) public {
        assert(index < transitionTreeSize);
        botId__claimViaTransition = transitionJSON.readUint(string.concat(".tree.[", index.toString(), "].bots_id"));
        sheetId__claimViaTransition = transitionJSON.readUint(string.concat(".tree.[", index.toString(), "].sheet_id"));
        proof__claimViaTransition =
            transitionJSON.readBytes32Array(string.concat(".tree.[", index.toString(), "].merkleProof"));
    }

    /// @notice Set the transition tree root.
    function setTransitionRoot() public {
        spreadSheet.setTransitionMerkleRoot(transitionJSON.readBytes32(".root"));
    }

    /// @notice Create an allocation tree entry for the given tree index.
    function setAllocationEntry(uint256 index) public {
        assert(index < allocationTreeSize);
        allocatee__claimViaAllocation =
            allocationJSON.readAddress(string.concat(".tree.[", index.toString(), "].allocatee"));
        allocation__claimViaAllocation =
            allocationJSON.readUint(string.concat(".tree.[", index.toString(), "].allocation"));
        proof__claimViaAllocation =
            allocationJSON.readBytes32Array(string.concat(".tree.[", index.toString(), "].merkleProof"));
    }

    /// @notice Set the allocation tree root.
    function setAllocationRoot() public {
        spreadSheet.setAllocationMerkleRoot(allocationJSON.readBytes32(".root"));
    }

    /// @dev Generates a user, labels its address, and funds it with test assets.
    function createUser(string memory name) internal returns (address payable) {
        address payable user = payable(makeAddr(name));
        vm.deal({ account: user, newBalance: 100 ether });
        return user;
    }
}
