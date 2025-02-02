// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

struct PriceProps {
    uint256 min;
    uint256 max;
}

interface IExchangeRouter {
    struct Addresses {
        address receiver;
        address callbackContract;
        address cancellationReceiver;
        address uiFeeReceiver;
        address market;
        address initialCollateralToken;
        address[] swapPath;
    }

    struct Numbers {
        uint256 sizeDeltaUsd;
        uint256 initialCollateralDeltaAmount;
        uint256 triggerPrice;
        uint256 acceptablePrice;
        uint256 executionFee;
        uint256 callbackGasLimit;
        uint256 minOutputAmount;
        uint256 validFromTime;
    }

    struct CreateOrderParams {
        Addresses addresses;
        Numbers numbers;
        uint256 orderType;
        uint256 decreasePositionSwapType;
        bool isLong;
        bool shouldUnwrapNativeToken;
        bool autoCancel;
        bytes32 referralCode;
    }

    function createOrder(CreateOrderParams calldata params) external payable;

    function multicall(
        bytes[] calldata data
    ) external payable returns (bytes[] memory results);

    function sendWnt(address receiver, uint256 amount) external payable;

    function sendTokens(
        address token,
        address receiver,
        uint256 amount
    ) external payable;

    function getPrice(address market) external view returns (uint256);
}

interface IOrderVault {
    function executeOrder(bytes32 key, address keeper) external;

    function cancelOrder(bytes32 key) external;
}

interface IReader {
    function getMarketInfo(
        IDataStore dataStore,
        IMarketUtils.MarketPrices memory prices,
        address market
    ) external view returns (IReaderUtils.MarketInfo memory);

    function getDataStore() external view returns (IDataStore);

    function getPrices(
        address market
    ) external view returns (IMarketUtils.MarketPrices memory);
}

interface IDataStore {
    function getUint(bytes32 key) external view returns (uint256);

    function getAddress(bytes32 key) external view returns (address);

    function getBytes32(bytes32 key) external view returns (bytes32);
}

interface IMarketUtils {
    struct MarketPrices {
        PriceProps indexTokenPrice;
        PriceProps longTokenPrice;
        PriceProps shortTokenPrice;
    }
}

interface IReaderUtils {
    struct MarketInfo {
        uint256 indexTokenPrice;
        uint256 longInterestUsd;
        uint256 shortInterestUsd;
    }
}
