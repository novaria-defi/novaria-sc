// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {VaultShort} from "../src/VaultShort.sol";
import {PTToken} from "../src/PTNova.sol";
import {YTToken} from "../src/YTNova.sol";
import "../src/interfaces/IGMX.sol";

contract VaultShortTest is Test {
    VaultShort public vaultShort;
    PTToken public ptToken;
    YTToken public ytToken;

    address public wbtc = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;
    address public dataStore = 0xFD70de6b91282D8017aA4E741e9Ae325CAb992d8;
    address public reader = 0xf60becbba223EEA9495Da3f606753867eC10d139;

    uint256 constant INITIAL_WBTC_BALANCE = 10e8; // 10 WBTC
    uint256 constant DEPOSIT_AMOUNT = 1e8;        // 1 WBTC
    uint256 constant EXECUTION_FEE = 75826647000000;

    function setUp() public {
        vm.createSelectFork("https://arb-mainnet.g.alchemy.com/v2/Ea4M-V84UObD22z2nNlwDD9qP8eqZuSI", 301883180);

        // Deploy contracts
        vaultShort = new VaultShort(address(0), address(0));
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

        // Fund test contract with WBTC
        deal(wbtc, address(this), INITIAL_WBTC_BALANCE);
    }

    function test_vault_short() public {
        IERC20(wbtc).approve(address(vaultShort), DEPOSIT_AMOUNT);

        // Deposit WBTC
        bytes32 positionId = vaultShort.deposit{value: EXECUTION_FEE}(DEPOSIT_AMOUNT, wbtc);

        console.log("\nDeposit Results:");
        console.log("Position ID:", vm.toString(positionId));

        IReaderOrder.Props memory order = IReaderOrder(reader).getOrder(dataStore, positionId);
        console.log("order.numbers.sizeDeltaUsd", order.numbers.sizeDeltaUsd);
        console.log("order.flags.isLong", order.flags.isLong);

        console.log("================");

        IReaderPosition.Props memory position = IReaderPosition(reader).getPosition(dataStore, positionId);
        console.log("position.numbers.sizeInUsd", position.numbers.sizeInUsd);
        console.log("position.flags.isLong", position.flags.isLong);

        // Test send PT/YT
        IERC20(address(vaultShort)).approve(address(vaultShort), DEPOSIT_AMOUNT);
        vaultShort.depositToPT(DEPOSIT_AMOUNT);

        // Cek saldo token setelah deposit PT
        uint256 vaultBalance = IERC20(address(vaultShort)).balanceOf(address(this));
        uint256 ptBalance = IERC20(address(ptToken)).balanceOf(address(this));
        uint256 ytBalance = IERC20(address(ytToken)).balanceOf(address(this));
        uint256 ptVaultBalance = IERC20(address(vaultShort)).balanceOf(address(ptToken));

        console.log("\nSaldo Token setelah deposit PT:");
        console.log("Vault Token Pengguna:", vaultBalance);
        console.log("PT Token:", ptBalance);
        console.log("YT Token:", ytBalance);
        console.log("Vault Token di Kontrak PT:", ptVaultBalance);
    }
}

// forge test --match-path test/VaultShortTest.t.sol -vv