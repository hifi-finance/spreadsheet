// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IERC721 } from "@openzeppelin/token/ERC721/IERC721.sol";
import { SheetHeads } from "../../contracts/SheetHeads.sol";

import "../Base.s.sol";

contract SheetHeadsScript is BaseScript {
    function run() public virtual broadcaster returns (SheetHeads sheet) {
        sheet = new SheetHeads(8888);
    }
}
