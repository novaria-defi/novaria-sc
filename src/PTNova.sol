// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract PTNova is ERC20, Ownable {
    address public ytToken;
    address public vaultToken;

    constructor(address _vaultToken) ERC20("PT Nova", "PTNOVA") Ownable(msg.sender) {
        require(_vaultToken != address(0), "Invalid vault token address");
        vaultToken = _vaultToken;
    }

    function setYTToken(address _ytToken) external onlyOwner {
        require(ytToken == address(0), "YT token already set");
        ytToken = _ytToken;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == vaultToken, "Only vault token can mint PTNOVA");
        require(IERC20(vaultToken).balanceOf(to) >= amount, "Insufficient balance");
        _mint(to, amount);
    }

}
