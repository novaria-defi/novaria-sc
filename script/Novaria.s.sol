// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MockGTX} from "../src/mocks/MockGTX.sol";
import {FundingVault} from "../src/FundingVault.sol";

contract NovariaScript is Script {
    MockGTX public mockGTX;
    FundingVault public fundingVault;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        mockGTX = new MockGTX();
        fundingVault = new FundingVault(address(mockGTX), 0xf1CeAFabFe0c541fe45Bcd2Ed391e8BE4105b66A);

        vm.stopBroadcast();
    }
}
