// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { StdUtils } from "forge-std/StdUtils.sol";

struct Users {
    // Default admin.
    address payable admin;
    // Alice is a user.
    address payable alice;
}
