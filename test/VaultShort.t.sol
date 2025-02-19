// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {PTToken} from "../src/PTToken.sol";
import {YTToken} from "../src/YTToken.sol";
import {VaultShort} from "../src/VaultShort.sol";
<<<<<<< HEAD
import "../src/interfaces/IGMX.sol";
=======
import {IReaderOrder, IReaderPosition, Order} from "../src/interfaces/IGMX.sol";
>>>>>>> dcc9285b4c5cb52ca43b5418ed2b4f73878ac12c


contract VaultShortTest is Test {
    address public wbtc = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;

    address public dataStore = 0xFD70de6b91282D8017aA4E741e9Ae325CAb992d8;
    address public reader = 0xf60becbba223EEA9495Da3f606753867eC10d139;
    address public orderStoreUtils = 0x3C2233B0CaA8437827f03366556186f5e5899FA8;

    VaultShort public vaultShort;
    PTToken public ptToken;
    YTToken public ytToken;

    address public user = makeAddr("user");

    function setUp() public {
        vm.createSelectFork("https://arb-mainnet.g.alchemy.com/v2/Ea4M-V84UObD22z2nNlwDD9qP8eqZuSI", 301883180);

        deal(wbtc, address(this), 10e8);
        vaultShort = new VaultShort(address(0), address(0), address(0));
        ptToken = new PTToken(address(vaultShort));
        ytToken = new YTToken(address(vaultShort));

        console.log("Deployed Addresses:");
        console.log("Vault:", address(vaultShort));
        console.log("PT Token:", address(ptToken));
        console.log("YT Token:", address(ytToken));

        // Setup tokens in vault
        vm.startPrank(vaultShort.owner());
        vaultShort.setPTToken(address(ptToken));
        vaultShort.setYTToken(address(ytToken));
        vm.stopPrank();

        // Setup PT and YT token references
        ptToken.setYTToken(address(ytToken));
        ytToken.setPTToken(address(ptToken));
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

<<<<<<< HEAD
        console.log("================");

        IReaderPosition.Props memory position = IReaderPosition(reader).getPosition(dataStore, positionId);
        console.log("position.numbers.sizeInUsd", position.numbers.sizeInUsd);
        console.log("position.flags.isLong", position.flags.isLong);
    }

    function test_yt_pt_token() public {
        uint256 executionFee = 75826647000000;
        uint256 depositAmount = 1e8; // 1 WBTC (in satoshis)
        
        // Approve vault to spend WBTC
        IERC20(wbtc).approve(address(vaultShort), depositAmount);
        console.log("depositAmount:", depositAmount);
        
        // Deposit WBTC into VaultShort and get position ID
        bytes32 positionId = vaultShort.deposit{value: executionFee}(depositAmount, wbtc);
        
        console.log("positionId:", vm.toString(positionId));
        
        // Retrieve position details
        IReaderOrder.Props memory order = IReaderOrder(reader).getOrder(dataStore, positionId);
        console.log("order.numbers.sizeDeltaUsd", order.numbers.sizeDeltaUsd);
        console.log("order.flags.isLong", order.flags.isLong);
        
        console.log("================");
        
        IReaderPosition.Props memory position = IReaderPosition(reader).getPosition(dataStore, positionId);
        console.log("position.numbers.sizeInUsd", position.numbers.sizeInUsd);
        console.log("position.flags.isLong", position.flags.isLong);
        
        // Check minted Vault Token balance
        uint256 vaultTokenBalance = vaultShort.balanceOf(address(this));
        assertEq(vaultTokenBalance, depositAmount, "Vault token minting failed");
        
        // Deposit Vault Token into PTToken
        vaultShort.depositToPT(depositAmount);
        
        // Check PTToken and YTToken balance
        uint256 ptTokenBalance = ptToken.balanceOf(address(this));
        uint256 ytTokenBalance = ytToken.balanceOf(address(this));
        
        assertEq(ptTokenBalance, depositAmount, "PTToken minting failed");
        assertEq(ytTokenBalance, depositAmount, "YTToken minting failed");

        console.log("================");

        console.log("ptTokenBalance:", ptTokenBalance);
        console.log("ytTokenBalance:", ytTokenBalance);
=======
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
>>>>>>> dcc9285b4c5cb52ca43b5418ed2b4f73878ac12c
    }
}