// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract YTToken is ERC20, Ownable {
    address public vaultAddress;
    address public ptToken;

    constructor(address _vaultAddress) ERC20("YT Nova", "YTN") Ownable(msg.sender) {
        vaultAddress = _vaultAddress;
    }

    function setPTToken(address _ptToken) external onlyOwner {
        require(ptToken == address(0), "PT already set");
        ptToken = _ptToken;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == vaultAddress, "Only vault can mint");
        _mint(to, amount);
    }
}