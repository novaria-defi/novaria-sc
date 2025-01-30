// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {OpenPositionShortGMX} from "../src/OpenPositionShortGMX.sol";

contract OpenPositionShortGMXTest is Test {
    OpenPositionShortGMX public openPositionShortGMX;
    address public alice = makeAddr("alice");

    address public usdc = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address public wbtc = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;
    address public exchangeRouter = 0x900173A66dbD345006C51fA35fA3aB760FcD843b;
    address public orderVault = 0x31eF83a530Fde1B38EE9A18093A333D8Bbbc40D5;
    address public gvl = 0x489ee077994B6658eAfA855C308275EAd8097C4A; // GMX vault liquidity

    function setUp() public {
        vm.createSelectFork("ALCHEMY_KEY", 300538539);
        
        openPositionShortGMX = new OpenPositionShortGMX();
        deal(wbtc, alice, 1e8); // 10 WBTC (karena 8 desimal)

        vm.deal(alice, 1 ether);
    }

    function test_depositToGlv() public {
        deal(wbtc, alice, 2e8);
        vm.startPrank(alice);
        IERC20(wbtc).approve(address(openPositionShortGMX), 1e8);
    
        vm.expectRevert(); // Tangkap error
        openPositionShortGMX.depositToGlv(1e8);
        vm.stopPrank();
    }

    function test_OrderInGmx() public {
        deal(wbtc, alice, 2e8);
        vm.startPrank(alice);
        IERC20(wbtc).approve(address(openPositionShortGMX), 1e8);
    
        vm.expectRevert(); // Tangkap error
        openPositionShortGMX.orderInGmx(1e8);
        vm.stopPrank();
    }
    
}
