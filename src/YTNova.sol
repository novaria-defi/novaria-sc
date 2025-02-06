// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract YTNova is ERC20, Ownable {

    address public ptAddress;

    constructor(address _ptAddress) ERC20("YT NOVA", "ytNOVA") Ownable(msg.sender) {
        ptAddress = _ptAddress;
    }

    modifier onlyPTNova() {
        require(msg.sender == ptAddress, "Only PTNova can call this function");
        _;
    }

    function mint(address to, uint256 amount) external onlyPTNova {
        _mint(to, amount);
    }


}
