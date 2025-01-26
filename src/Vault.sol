// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Vault is ERC20, Ownable {

    event Deposit(address user, uint256 amount);
    address public immutable wbtc;
    
    constructor(address _wbtc) ERC20("Supply", "supply") Ownable(msg.sender) {
        wbtc = _wbtc;
    }

    function deposit(uint256 amount) public {
        uint256 shares = 0;
        uint256 totalAssets = IERC20(wbtc).balanceOf(address(this));

        //shares math
        if(totalSupply() == 0) {
            shares = amount;
        } else {
            shares = (amount * totalSupply()) / totalAssets;
        }

        _mint(msg.sender, shares);
        IERC20(wbtc).transferFrom(msg.sender, address(this), amount);

        emit Deposit(msg.sender, amount);
    }

    
}