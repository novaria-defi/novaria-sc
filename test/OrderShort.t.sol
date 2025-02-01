// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {OrderShort} from "../src/OrderShort.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OrderShortTest is Test {
    OrderShort public orderShort;
    
    address public alice = makeAddr("alice");
    address public wbtc = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;

    function setUp() public {
        vm.createSelectFork(
            "https://arb-mainnet.g.alchemy.com/v2/8tbjGo5rD6kKccwcnYjY6NJ67_Nyj1Dm",
            301195203
        );

        orderShort = new OrderShort();
    }

    function testDepositWithWBTC() public {
        deal(wbtc, alice, 1e8);

        vm.startPrank(alice);

        IERC20(wbtc).approve(address(orderShort), 1e8);

        orderShort.order(1e8);
        uint256 amount = IERC20(wbtc).balanceOf(address(orderShort));
        console.log("Balance Vault: ", amount);

        vm.stopPrank();
    }
}
