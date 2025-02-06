// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {VaultShort} from "../src/VaultShort.sol";
import {PTNova} from "../src/PTNova.sol";
import {IReaderOrder, IReaderPosition} from "../src/interfaces/IGMX.sol";


contract VaultShortTest is Test {
    address public wbtc = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;

    address public dataStore = 0xFD70de6b91282D8017aA4E741e9Ae325CAb992d8;
    address public reader = 0xf60becbba223EEA9495Da3f606753867eC10d139;

    VaultShort public vaultShort;
    PTNova public ptNova;
    function setUp() public {
        vm.createSelectFork("https://arb-mainnet.g.alchemy.com/v2/Ea4M-V84UObD22z2nNlwDD9qP8eqZuSI", 301883180);

        deal(wbtc, address(this), 10e8);
        vaultShort = new VaultShort(address(ptNova));
    }

    function test_vault_short() public {
        uint256 executionFee = 75826647000000;

        IERC20(wbtc).approve(address(vaultShort), 1e8);
        bytes32 positionId = vaultShort.deposit{value: executionFee}(1e8, wbtc);

        console.log("positionId:", vm.toString(positionId));

        IReaderOrder.Props memory order = IReaderOrder(reader).getOrder(dataStore, positionId);
        console.log("order.numbers.sizeDeltaUsd", order.numbers.sizeDeltaUsd);
        console.log("order.flags.isLong", order.flags.isLong);

        console.log("================");

        IReaderPosition.Props memory position = IReaderPosition(reader).getPosition(dataStore, positionId);
        console.log("position.numbers.sizeInUsd", position.numbers.sizeInUsd);
        console.log("position.flags.isLong", position.flags.isLong);

        uint256 totalAsset = vaultShort.getTotalAsset();
        console.log("Total Assets", totalAsset / 1e8);
        console.log("Balance of", vaultShort.balanceOf(address(this))); // check balance of current contract
    }
}