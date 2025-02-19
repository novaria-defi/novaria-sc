// SPDX-License-Identifier: MIT

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

pragma solidity ^0.8.13;

interface IExchangeRouter {
    enum OrderType {
        MarketIncrease,
        LimitIncrease,
        MarketDecrease,
        LimitDecrease,
        StopLossDecrease,
        Liquidation,
        StopIncrease
    }

    struct CreateOrderParams {
        // Address parameters
        address receiver;
        address cancellationReceiver;
        address callbackContract;
        address uiFeeReceiver;
        address market;
        address initialCollateralToken;

        // Order type parameters
        OrderType orderType;

        // Numerical parameters
        uint256 sizeDeltaUsd;
        uint256 initialCollateralDeltaAmount;
        uint256 triggerPrice;
        uint256 acceptablePrice;
        uint256 executionFee;
        uint256 validFromTime;
        bool isLong;
        bool autoCancel;
    }

    function sendTokens(address _token, uint256 _amount) external {}

    function withdrawTokens(address _token, uint256 _amount) external {}

    function createOrder(CreateOrderParams memory _params) external returns (uint256) {}

    function cancelOrder(uint256 _orderId) external {}

    function getPosition(uint256 _orderId) external view returns (CreateOrderParams memory) {}

    function updatePositionSizeDeltaUsd(uint256 _orderId, uint256 _sizeDeltaUsd) external {}
}

contract Vault is ERC20 {
    address owner;

    address public EXCHANGE_ROUTER = 0x658415088be97495ff1652BB7638d5b5f22cf220;
    address public MARKET = 0x47c031236e19d024b42f8AE6780E44A573170703;

    constructor() ERC20("Novaria Vault", "NOVA") {
        owner = msg.sender;
    }

    function deposit(
        uint amount,
        address collateralToken
    ) public payable returns (bytes32) {
        uint256 totalAssets = 0;
        if (positionId != bytes32(0)) {
            totalAssets = getTotalAsset();
        }

        uint256 shares = 0;
        if (totalSupply() == 0) {
            shares = amount;
        } else {
            shares = (amount * totalSupply()) / totalAssets;
        }

        _mint(msg.sender, shares);

        IExchangeRouter.CreateOrderParams memory params = IExchangeRouter.CreateOrderParams({
            receiver: address(this),
            cancellationReceiver: address(0),
            callbackContract: address(0),
            uiFeeReceiver: 0xff00000000000000000000000000000000000001,
            market: MARKET,
            initialCollateralToken: collateralToken,
            orderType: 2,
            sizeDeltaUsd: sizeDeltaUsd,
            sizeDeltaUsd: sizeDeltaUsd,
            initialCollateralDeltaAmount: 0,
            triggerPrice: 0,
            acceptablePrice: 0,
            executionFee: msg.value,
            validFromTime: 0,
            isLong: false,
            autoCancel: false
        })

        uint256 _positionId = IExchangeRouter(EXCHANGE_ROUTER).createOrder(params)
        console.log(_positionId)
    }
}
