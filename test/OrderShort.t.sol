// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {OrderShort} from "../src/OrderShort.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../src/interfaces/IGMX.sol";

contract OrderShortTest is Test {
    OrderShort public orderShort;

    address public alice = makeAddr("alice");
    address public WBTC = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;
    address public USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address public WNT = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address public ETH_USD_MARKET = 0x70d95587d40A2caf56bd97485aB3Eec10Bee6336; // ETH/USD market
    address public EXCHANGE_ROUTER = 0x900173A66dbD345006C51fA35fA3aB760FcD843b;

    uint256 constant EXECUTION_FEE = 75826647000000;

    function setUp() public {
        vm.createSelectFork(
            "https://arb-mainnet.g.alchemy.com/v2/8tbjGo5rD6kKccwcnYjY6NJ67_Nyj1Dm",
            301889232
        );

        orderShort = new OrderShort();

        // Setup alice with some ETH for gas
        vm.deal(alice, 100 ether);
    }

    function testCreateShortPositionWithWBTC() public {
        IMarketUtils.MarketPrices memory prices = IMarketUtils.MarketPrices({
            indexTokenPrice: PriceProps({
                min: 654698000000000000000000000,
                max: 654698000000000000000000000
            }),
            longTokenPrice: PriceProps({
                min: 654698000000000000000000000,
                max: 654698000000000000000000000
            }),
            shortTokenPrice: PriceProps({
                min: 999500000000000000000000,
                max: 1000000000000000000000000
            })
        });
        // Give alice some WBTC
        deal(WBTC, alice, 10e8); // 1 WBTC

        vm.startPrank(alice);

        // Approve WBTC spending
        IERC20(WBTC).approve(address(orderShort), 10e8);

        // Parameters for short position
        uint256 sizeDeltaUsd = (1e8 * 2 * 1e35) / 1e8;
        uint256 collateralAmount = 10e8; // 1 WBTC as collateral

        uint256 currentPrice = orderShort.getPrice(ETH_USD_MARKET, prices);
        uint256 acceptablePrice = (currentPrice * 101) / 100; // Allow 1% slippage

        orderShort.deposit(WBTC, collateralAmount);
        console.log(
            "WBTC Balance of Contract:",
            IERC20(WBTC).balanceOf(address(orderShort))
        );

        // Create short position
        orderShort.order{value: EXECUTION_FEE}(
            sizeDeltaUsd,
            collateralAmount,
            WBTC,
            acceptablePrice,
            EXECUTION_FEE
        );

        vm.stopPrank();

        // Log balances for verification
        console.log(
            "WBTC Balance of Contract:",
            IERC20(WBTC).balanceOf(address(orderShort))
        );
    }
}
