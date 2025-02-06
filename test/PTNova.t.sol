// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {PTNova} from "../src/PTNova.sol";
import {YTNova} from "../src/YTNova.sol";
import {VaultShort} from "../src/VaultShort.sol";


contract PTNovaTest is Test {
    PTNova public ptNova;
    VaultShort public vaultShort;
    YTNova public ytNova;

    function setUp() public {
        vm.createSelectFork("https://arb-mainnet.g.alchemy.com/v2/Ea4M-V84UObD22z2nNlwDD9qP8eqZuSI", 302930829);

        vaultShort = new VaultShort(address(ptNova));
        ptNova = new PTNova(address(this));
        ytNova = new YTNova(address(ptNova));
    }

    function test_pt_nova() public {
        ptNova.setYTToken(address(ytNova));
    }

    function test_mint() public {
        ptNova.setYTToken(address(ytNova));

        vm.prank(address(ptNova));
        ytNova.mint(address(this), 100e18);

        vm.prank(address(vaultShort));
        // vaultShort.mintPtNova(address(this), 100e18);

        uint256 ptNovaBalance = ptNova.balanceOf(address(this));
        console.log("PTNOVA balance:", ptNovaBalance);

        assertEq(ptNovaBalance, 100e18);
    }
}