// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {OpenPositionShortGMX} from "src/OpenPositionShortGMX.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library Order {
    enum OrderType {
        // @dev MarketSwap: swap token A to token B at the current market price
        // the order will be cancelled if the minOutputAmount cannot be fulfilled
        MarketSwap,
        // @dev LimitSwap: swap token A to token B if the minOutputAmount can be fulfilled
        LimitSwap,
        // @dev MarketIncrease: increase position at the current market price
        // the order will be cancelled if the position cannot be increased at the acceptablePrice
        MarketIncrease,
        // @dev LimitIncrease: increase position if the triggerPrice is reached and the acceptablePrice can be fulfilled
        LimitIncrease,
        // @dev MarketDecrease: decrease position at the current market price
        // the order will be cancelled if the position cannot be decreased at the acceptablePrice
        MarketDecrease,
        // @dev LimitDecrease: decrease position if the triggerPrice is reached and the acceptablePrice can be fulfilled
        LimitDecrease,
        // @dev StopLossDecrease: decrease position if the triggerPrice is reached and the acceptablePrice can be fulfilled
        StopLossDecrease,
        // @dev Liquidation: allows liquidation of positions if the criteria for liquidation are met
        Liquidation,
        // @dev StopIncrease: increase position if the triggerPrice is reached and the acceptablePrice can be fulfilled
        StopIncrease
    }
}

interface IBaseOrderUtils{
    struct CreateOrderParams {
        Order.OrderType orderType;
        bool isLong;
        bool shouldUnwrapNativeToken;
        bool autoCancel;
    }
}

contract OpenPositionShortGMXTest is Test {

    OpenPositionShortGMX public openPositionShortGMX;
    address public usdc = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address public wbtc = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;
    address public exchangeRouter = 0x900173A66dbD345006C51fA35fA3aB760FcD843b;
    address public orderVault = 0x31eF83a530Fde1B38EE9A18093A333D8Bbbc40D5;

    address public alice = makeAddr("alice");

    function setUp() public {
        vm.createSelectFork("ALCHEMY_KEY", 300080856);
        openPositionShortGMX = new OpenPositionShortGMX();
        deal(wbtc, alice, 1e8);
    }

    function test_createOrder() public {
        vm.startPrank(alice);
        IERC20(wbtc).approve(address(openPositionShortGMX), 1e8);

        vm.expectRevert();
        openPositionShortGMX.createOrder(1e8);
    
        uint256 wbtcBalance = IERC20(wbtc).balanceOf(alice);
        console.log("wbtcBalance: ", wbtcBalance);

        vm.stopPrank();
    }

    function test_updateOrder() public {
        vm.startPrank(alice);
        IERC20(wbtc).approve(address(openPositionShortGMX), 1e8);

        uint256 wbtcBalance = IERC20(wbtc).balanceOf(alice);
        console.log("wbtcBalance: ", wbtcBalance);

        vm.expectRevert();
        openPositionShortGMX.updateOrder(alice);

        vm.stopPrank();
    }
}