// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Vault} from "src/Vault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VaultTest is Test {

    address public wbtc = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;

    Vault public vault;

    function setUp() public {
        vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/jIQwSPn0l4YehffUHdlUcicsq1pMLEfu", 21699814);
        vault = new Vault(wbtc);
    }

    function test_deposit() public {
        deal(wbtc, address(this), 1e8);
        IERC20(wbtc).approve(address(vault), 1e8);
        vault.deposit(1e8);
        
        uint256 vaultBalance = IERC20(wbtc).balanceOf(address(vault));
        console.log("Vault balance: ", vaultBalance);

        assertEq(vaultBalance, 1e8, "Vault balance should match the deposite amount");
    }
}
