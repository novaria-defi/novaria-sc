// SPDX-License-Identifier: MIT

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

pragma solidity ^0.8.13;

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
        address[2] swapPath;
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
    function createOrder(
        IBaseOrderUtils.CreateOrderParams calldata params
    ) external payable returns (bytes32);

    function multicall(bytes[2] calldata data) external payable;
}

interface IRouter {
    function swapTokensToETH(
        address[] memory _path,
        uint256 _amountIn,
        uint256 _minOut,
        address payable _receiver
    ) external;

    function multicall(bytes[] calldata data) external payable;
}

contract OrderShort is ERC20 {
    address public owner;

    address public WBTC = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;
    address public EXCHANGE_ROUTER = 0x900173A66dbD345006C51fA35fA3aB760FcD843b;
    address public ROUTER = 0xaBBc5F99639c9B6bCb58544ddf04EFA6802F4064;
    address public ORDER_VAULT = 0x31eF83a530Fde1B38EE9A18093A333D8Bbbc40D5;
    address public GLV = 0x489ee077994B6658eAfA855C308275EAd8097C4A;
    address public USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address public WNT = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

    constructor() ERC20("Short Vault", "SHRVT") {
        owner = msg.sender;
    }

    function order(uint256 amount) public payable {
        require(amount > 0, "Amount must be greater than zero");
        bool success = IERC20(WBTC).transferFrom(
            msg.sender,
            address(this),
            amount
        );
        require(success, "WNT transfer failed");

        IERC20(WBTC).transfer(ROUTER, amount);

        address[] memory swapPath = new address[](2);
        swapPath[0] = WBTC;
        swapPath[1] = WNT;

        IRouter(ROUTER).swapTokensToETH(
            swapPath,
            amount,
            0,
            payable(address(this))
        );

        // bytes[2] memory calls;
        // calls[1] = abi.encodeWithSignature(
        //     "sendWnt(address,uint256)",
        //     ORDER_VAULT,
        //     1e16
        // );
        // calls[1] = abi.encodeWithSignature(
        //     "createOrder((address,address,address,address,address,address,address[],(uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256),uint8,uint8,bool,bool,bool,bytes32))",
        //     IBaseOrderUtils.CreateOrderParams({
        //         addresses: IBaseOrderUtils.CreateOrderParamsAddresses({
        //             receiver: address(this),
        //             cancellationReceiver: address(this),
        //             callbackContract: address(this),
        //             uiFeeReceiver: address(this),
        //             market: GLV,
        //             initialCollateralToken: WBTC,
        //             swapPath: swapPath
        //         }),
        //         numbers: IBaseOrderUtils.CreateOrderParamsNumbers({
        //             sizeDeltaUsd: 1e16,
        //             initialCollateralDeltaAmount: 0,
        //             triggerPrice: 0,
        //             acceptablePrice: 0,
        //             executionFee: 0,
        //             callbackGasLimit: 0,
        //             minOutputAmount: 0,
        //             validFromTime: 0
        //         }),
        //         orderType: Order.OrderType.MarketIncrease,
        //         decreasePositionSwapType: Order.DecreasePositionSwapType.NoSwap,
        //         isLong: false,
        //         shouldUnwrapNativeToken: false,
        //         autoCancel: false,
        //         referralCode: bytes32(0)
        //     })
        // );

        // IExchangeRouter(EXCHANGE_ROUTER).multicall{value: 0}(calls);
    }
}
