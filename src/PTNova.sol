// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract PTToken is ERC20, Ownable {
    address public vaultAddress;
    address public ytToken;

    constructor(address _vaultAddress) ERC20("PT Nova", "PTN") Ownable(msg.sender) {
        vaultAddress = _vaultAddress;
    }

    function setYTToken(address _ytToken) external onlyOwner {
        require(ytToken == address(0), "YT already set");
        ytToken = _ytToken;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == vaultAddress, "Only vault can mint");
        _mint(to, amount);
    }
}