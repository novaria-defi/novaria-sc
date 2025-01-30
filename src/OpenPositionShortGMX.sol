// SPDX-License-Identifier: MIT

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

pragma solidity ^0.8.13;

library DepositUtils {
    struct CreateDepositParams {
        address receiver;
        address callbackContract;
        address uiFeeReceiver;
        address market;
        address initialLongToken;
        address initialShortToken;
        address[] longTokenSwapPath;
        address[] shortTokenSwapPath;
        uint256 minMarketTokens;
        bool shouldUnwrapNativeToken;
        uint256 executionFee;
        uint256 callbackGasLimit;
    }
}

library Order {
    enum OrderType {
        MarketSwap,
        LimitSwap,
        MarketIncrease,
        LimitIncrease,
        MarketDecrease,
        LimitDecrease,
        StopLossDecrease,
        Liquidation,
        StopIncrease
    }
    enum DecreasePositionSwapType {
        NoSwap,
        SwapPnlTokenToCollateralToken,
        SwapCollateralTokenToPnlToken
    }
}

interface IBaseOrderUtils {
    struct CreateOrderParams {
        CreateOrderParamsAddresses addresses;
        CreateOrderParamsNumbers numbers;
        Order.OrderType orderType;
        Order.DecreasePositionSwapType decreasePositionSwapType;
        bool isLong;
        bool shouldUnwrapNativeToken;
        bool autoCancel;
        bytes32 referralCode;
    }

    struct CreateOrderParamsAddresses {
        address receiver;
        address cancellationReceiver;
        address callbackContract;
        address uiFeeReceiver;
        address market;
        address initialCollateralToken;
        address[] swapPath;
    }

    struct CreateOrderParamsNumbers {
        uint256 sizeDeltaUsd;
        uint256 initialCollateralDeltaAmount;
        uint256 triggerPrice;
        uint256 acceptablePrice;
        uint256 executionFee;
        uint256 callbackGasLimit;
        uint256 minOutputAmount;
        uint256 validFromTime;
    }
}

interface IExchangeRouter {
    function createDeposit(
        DepositUtils.CreateDepositParams calldata params
    ) external payable returns (bytes32);

    function createOrder(
        IBaseOrderUtils.CreateOrderParams calldata params
    ) external payable returns (bytes32);
}

contract OpenPositionShortGMX {
    address public wbtc = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;
    address public exchangeRouter = 0x900173A66dbD345006C51fA35fA3aB760FcD843b;
    address public orderVault = 0x31eF83a530Fde1B38EE9A18093A333D8Bbbc40D5;
    address public glv = 0x489ee077994B6658eAfA855C308275EAd8097C4A;

    function depositToGlv(uint256 amountDeposit) public payable {
        IERC20(wbtc).transferFrom(msg.sender, address(this), amountDeposit); // Transfer WBTC
        IERC20(wbtc).approve(glv, amountDeposit); // Approve WBTC
    
        DepositUtils.CreateDepositParams memory params = DepositUtils.CreateDepositParams({
            receiver: address(this),
            callbackContract: address(this),
            uiFeeReceiver: address(this),
            market: glv,
            initialLongToken: wbtc,
            initialShortToken: wbtc,
            longTokenSwapPath: new address[](0),
            shortTokenSwapPath: new address[](1),
            minMarketTokens: 0,
            shouldUnwrapNativeToken: false,
            executionFee: msg.value,
            callbackGasLimit: 200000
        });
    
        IExchangeRouter(exchangeRouter).createDeposit{value: msg.value}(params);
        IERC20(wbtc).transfer(glv, amountDeposit);
    }

    function orderInGmx(uint256 payableAmount) public payable {
        IERC20(wbtc).transferFrom(msg.sender, address(this), payableAmount);
        IERC20(wbtc).approve(exchangeRouter, payableAmount);

        IBaseOrderUtils.CreateOrderParams memory params = IBaseOrderUtils.CreateOrderParams({
            addresses: IBaseOrderUtils.CreateOrderParamsAddresses({
                receiver: address(this),
                cancellationReceiver: address(this),
                callbackContract: address(this),
                uiFeeReceiver: address(this),
                market: glv,
                initialCollateralToken: wbtc,
                swapPath: new address[](0)
            }),
            numbers: IBaseOrderUtils.CreateOrderParamsNumbers({
                sizeDeltaUsd: 0,
                initialCollateralDeltaAmount: 0,
                triggerPrice: 0,
                acceptablePrice: 0,
                executionFee: 0,
                callbackGasLimit: 0,
                minOutputAmount: 0,
                validFromTime: 0
            }),
            orderType: Order.OrderType.MarketSwap,
            decreasePositionSwapType: Order.DecreasePositionSwapType.NoSwap,
            isLong: false,
            shouldUnwrapNativeToken: false,
            autoCancel: false,
            referralCode: 0
        });

        IExchangeRouter(exchangeRouter).createOrder{value: msg.value}(params);
        IERC20(wbtc).transfer(glv, payableAmount);
    }

    function cekPositionOrder() public {
        
    }
}