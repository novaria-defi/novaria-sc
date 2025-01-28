// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library Position{
    struct Addresses {
        address account;
        address market;
        address collateralToken;
    }
}

library Order {
    enum OrderType {
        // @dev MarketSwap: swap token A to token B at the current market price
        // the order will be cancelled if the minOutputAmount cannot be fulfilled
        MarketSwap,
        // @dev LimitSwap: swap token A to token B if the minOutputAmount can be fulfilled
        LimitSwap,
        // @dev MarketIncrease: increase position at the current market price
        // the order will be cancelled if the position cannot be increased at the acceptablePrice
        MarketIncrease,
        // @dev LimitIncrease: increase position if the triggerPrice is reached and the acceptablePrice can be fulfilled
        LimitIncrease,
        // @dev MarketDecrease: decrease position at the current market price
        // the order will be cancelled if the position cannot be decreased at the acceptablePrice
        MarketDecrease,
        // @dev LimitDecrease: decrease position if the triggerPrice is reached and the acceptablePrice can be fulfilled
        LimitDecrease,
        // @dev StopLossDecrease: decrease position if the triggerPrice is reached and the acceptablePrice can be fulfilled
        StopLossDecrease,
        // @dev Liquidation: allows liquidation of positions if the criteria for liquidation are met
        Liquidation,
        // @dev StopIncrease: increase position if the triggerPrice is reached and the acceptablePrice can be fulfilled
        StopIncrease
    }
}

interface IBaseOrderUtils{
    struct CreateOrderParams {
        Order.OrderType orderType;
        bool isLong;
        bool shouldUnwrapNativeToken;
        bool autoCancel;
    }
}

interface IExchangeRouter {
    function createOrder(
        IBaseOrderUtils.CreateOrderParams calldata params
    ) external payable returns (bytes32);
}

contract OpenPositionShortGMX {
    address public exchangeRouter = 0x900173A66dbD345006C51fA35fA3aB760FcD843b;

    function createOrder(uint256 payableAmount) external {
        IERC20(wbtc).transferFrom(msg.sender, address(this), payableAmount);
        IERC20(wbtc).approve(exchangeRouter, payableAmount);
    
        IExchangeRouter(exchangeRouter).createOrder(
            IBaseOrderUtils.CreateOrderParams({
                orderType: Order.OrderType.MarketSwap,
                isLong: false,
                shouldUnwrapNativeToken: false,
                autoCancel: false
            })
        );
    
        IERC20(wbtc).transfer(msg.sender, payableAmount);
    }
    
    function getPositionKey(address _account, address _market, address _collateralToken, bool _isLong) public pure returns (bytes32) {
        bytes32 _key = keccak256(abi.encode(_account, _market, _collateralToken, _isLong));
        return _key;
    }
}
