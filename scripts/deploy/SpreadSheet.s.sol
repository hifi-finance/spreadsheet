// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IERC721 } from "@openzeppelin/token/ERC721/IERC721.sol";
import { SpreadSheet } from "../../contracts/SpreadSheet.sol";

import "../Base.s.sol";

contract SpreadSheetScript is BaseScript {
    function run(IERC721 sheetNFT, IERC721 botsNFT) public virtual broadcaster returns (SpreadSheet spreadSheet) {
        spreadSheet = new SpreadSheet(sheetNFT, botsNFT, 7079);
    }
}
