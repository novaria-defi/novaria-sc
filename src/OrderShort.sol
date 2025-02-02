// SPDX-License-Identifier: MIT

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IGMX.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {console} from "forge-std/console.sol";

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

interface IRouter {
    function swapTokensToETH(
        address[] memory _path,
        uint256 _amountIn,
        uint256 _minOut,
        address payable _receiver
    ) external;

    function multicall(bytes[] calldata data) external payable;
}

contract OrderShort is ERC20, ReentrancyGuard {
    address public owner;

    address public WBTC = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;
    address public EXCHANGE_ROUTER = 0x900173A66dbD345006C51fA35fA3aB760FcD843b;
    address public ROUTER = 0x7452c558d45f8afC8c83dAe62C3f8A5BE19c71f6;
    address public ORDER_VAULT = 0x31eF83a530Fde1B38EE9A18093A333D8Bbbc40D5;
    address public GLV = 0x489ee077994B6658eAfA855C308275EAd8097C4A;
    address public USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address public WNT = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address public READER = 0xf60becbba223EEA9495Da3f606753867eC10d139; // Arbitrum GMX Reader
    address public DATASTORE = 0xFD70de6b91282D8017aA4E741e9Ae325CAb992d8;
    address public MARKET = 0x47c031236e19d024b42f8AE6780E44A573170703;
    address public MARKET_TOKEN = 0xcaCb964144f9056A8f99447a303E60b4873Ca9B4;

    constructor() ERC20("Short Vault", "SHRVT") {
        owner = msg.sender;
    }

    function deposit(address collateralToken, uint256 amount) public payable {
        require(amount > 0, "Amount must be greater than zero");
        bool success = IERC20(collateralToken).transferFrom(
            msg.sender,
            address(this),
            amount
        );
        require(success, "Transfer failed");
    }

    function swapToEth(uint256 amount) public payable {
        IERC20(WBTC).approve(ROUTER, amount);

        address[] memory swapPath = new address[](2);
        swapPath[0] = WBTC;
        swapPath[1] = WNT;

        IRouter(ROUTER).swapTokensToETH(
            swapPath,
            amount,
            0,
            payable(address(this))
        );
    }

    function order(
        uint256 sizeDelta,
        uint256 collateralAmount,
        address collateralToken,
        uint256 acceptablePrice,
        uint256 executionFee
    ) external payable nonReentrant {
        require(msg.value >= executionFee, "Insufficient execution fee");

        IExchangeRouter router = IExchangeRouter(EXCHANGE_ROUTER);

        console.log(
            "WBTC Balance of current contract:",
            IERC20(WBTC).balanceOf(address(this))
        );

        uint256 allowance = IERC20(collateralToken).allowance(
            address(this),
            ORDER_VAULT
        );
        console.log("WBTC Allowance:", allowance);

        address[] memory swapPaths = new address[](1);
        swapPaths[0] = MARKET_TOKEN;

        IExchangeRouter.CreateOrderParams memory orderParams = IExchangeRouter
            .CreateOrderParams({
                addresses: IExchangeRouter.Addresses({
                    receiver: address(this),
                    cancellationReceiver: address(0),
                    callbackContract: address(0),
                    uiFeeReceiver: 0xff00000000000000000000000000000000000001,
                    market: MARKET,
                    initialCollateralToken: collateralToken,
                    swapPath: swapPaths
                }),
                numbers: IExchangeRouter.Numbers({
                    sizeDeltaUsd: sizeDelta,
                    initialCollateralDeltaAmount: 0,
                    triggerPrice: 0,
                    acceptablePrice: 0,
                    executionFee: executionFee,
                    callbackGasLimit: 0,
                    minOutputAmount: 0,
                    validFromTime: 0
                }),
                orderType: 2,
                decreasePositionSwapType: 0,
                isLong: false,
                shouldUnwrapNativeToken: false,
                autoCancel: false,
                referralCode: bytes32(0)
            });

        router.sendWnt{value: executionFee}(ORDER_VAULT, executionFee);

        IERC20(collateralToken).approve(ROUTER, collateralAmount);
        router.sendTokens(collateralToken, ORDER_VAULT, collateralAmount);

        router.createOrder(orderParams);
    }

    function getPrice(
        address market,
        IMarketUtils.MarketPrices memory prices
    ) external view returns (uint256) {
        IReader reader = IReader(READER);

        // Get required dependencies
        IDataStore dataStore = IDataStore(DATASTORE);

        // Get market info
        IReaderUtils.MarketInfo memory marketInfo = reader.getMarketInfo(
            dataStore,
            prices,
            market
        );

        return marketInfo.indexTokenPrice;
    }

    receive() external payable {}
}
