// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {VaultShort} from "../src/VaultShort.sol";
import {IReaderOrder, IReaderPosition, Order} from "../src/interfaces/IGMX.sol";


contract VaultShortTest is Test {
    address public wbtc = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;

    address public dataStore = 0xFD70de6b91282D8017aA4E741e9Ae325CAb992d8;
    address public reader = 0xf60becbba223EEA9495Da3f606753867eC10d139;
    address public orderStoreUtils = 0x3C2233B0CaA8437827f03366556186f5e5899FA8;

    VaultShort public vaultShort;

    function setUp() public {
        vm.createSelectFork("https://arb-mainnet.g.alchemy.com/v2/Ea4M-V84UObD22z2nNlwDD9qP8eqZuSI", 301883180);

        deal(wbtc, address(this), 10e8);
        vaultShort = new VaultShort();
    }

    function test_vault_short() public {
        uint256 executionFee = 75826647000000;

        IERC20(wbtc).approve(address(vaultShort), 1e8);
        bytes32 positionId1 = vaultShort.deposit{value: executionFee}(1e8, wbtc);
        console.log("positionId:", vm.toString(positionId1));
        IReaderOrder.Props memory order1 = IReaderOrder(reader).getOrder(dataStore, positionId1);
        console.log("order1.numbers.sizeDeltaUsd", order1.numbers.sizeDeltaUsd);
        IReaderPosition.Props memory position1 = IReaderPosition(reader).getPosition(dataStore, positionId1);
        console.log("position1.numbers.sizeInUsd", position1.numbers.sizeInUsd);

        console.log("============");

        IERC20(wbtc).approve(address(vaultShort), 2e8);
        bytes32 positionId2 = vaultShort.deposit{value: executionFee}(2e8, wbtc);
        console.log("positionId:", vm.toString(positionId2));
        IReaderOrder.Props memory order2 = IReaderOrder(reader).getOrder(dataStore, positionId2);
        console.log("order2.numbers.sizeDeltaUsd", order2.numbers.sizeDeltaUsd);
         IReaderPosition.Props memory position2 = IReaderPosition(reader).getPosition(dataStore, positionId2);
        console.log("position2.numbers.sizeInUsd", position2.numbers.sizeInUsd);

        console.log("============");

        uint256 totalAsset = vaultShort.getTotalAsset();
        console.log("Total Assets", totalAsset / 1e8);
        console.log("Balance of", vaultShort.balanceOf(address(this))); // check balance of current contract

    //    IReaderOrder(reader).getAccountOrders(dataStore, address(vaultShort), 0, 1);
        
        // for (uint256 i = 0; i < 10; i++){
        //     Order.Props memory order = orderList[i];
        //     console.log("Size Delta USD",order.numbers.sizeDeltaUsd);
        //     console.log("Address", order.addresses.receiver);
        // }
    }
}