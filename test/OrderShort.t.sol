// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {OrderShort} from "../src/OrderShort.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OrderShortTest is Test {
    OrderShort public orderShort;
    
    address public alice = makeAddr("alice");
    address public WBTC = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;
    address public USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address public WNT = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

    function setUp() public {
        vm.createSelectFork(
            "https://arb-mainnet.g.alchemy.com/v2/8tbjGo5rD6kKccwcnYjY6NJ67_Nyj1Dm",
            301195203
        );

        orderShort = new OrderShort();
    }

    function testDepositWithWBTC() public {
        deal(WBTC, alice, 1e8);

        vm.startPrank(alice);
        IERC20(WBTC).approve(address(orderShort), 1e8);
        orderShort.deposit(1e8);
        vm.stopPrank();

        orderShort.swapToEth(1e8);
        uint256 wntAmount = IERC20(WNT).balanceOf(address(orderShort));
        console.log("WETH/WNT Amount:", wntAmount);

        uint256 wbtcAmount = IERC20(WBTC).balanceOf(address(orderShort));
        console.log("WBTC Amount:", wbtcAmount);

        console.log("Contract ETH Balance:", address(orderShort).balance);
        orderShort.order(address(orderShort).balance);
    }
}
