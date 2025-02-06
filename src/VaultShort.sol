// SPDX-License-Identifier: MIT

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IGMX.sol";

pragma solidity ^0.8.13;

interface IERC20Decimals {
    function decimals() external view returns (uint8);
}

interface IPTToken {
        function mint(address to, uint256 amount) external;
}

interface IYTToken {
    function mint(address to, uint256 amount) external;
}

contract VaultShort is ERC20, Ownable {
    address public WBTC = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;
    uint public leverage = 2;

    address public EXCHANGE_ROUTER = 0x900173A66dbD345006C51fA35fA3aB760FcD843b;
    address public ORDER_VAULT = 0x31eF83a530Fde1B38EE9A18093A333D8Bbbc40D5;
    address public ROUTER = 0x7452c558d45f8afC8c83dAe62C3f8A5BE19c71f6;
    address public MARKET = 0x47c031236e19d024b42f8AE6780E44A573170703;
    address public MARKET_TOKEN = 0xcaCb964144f9056A8f99447a303E60b4873Ca9B4;

    // address PT and YT
    address public ptToken;
    address public ytToken;
    mapping(bytes32 => uint256) public positionToTokenAmount;

    constructor(address _ptToken, address _ytToken) ERC20("Vault Nova", "vNova") Ownable(msg.sender) {
        ptToken = _ptToken;
        ytToken = _ytToken;
    }

    function deposit(
        uint amount,
        address collateralToken
    ) public payable returns (bytes32) {
        IERC20(collateralToken).transferFrom(msg.sender, address(this), amount);
        require(ptToken != address(0) && ytToken != address(0), "Tokens not set");

        IExchangeRouter(EXCHANGE_ROUTER).sendWnt{value: msg.value}(
            ORDER_VAULT,
            msg.value
        );

        IERC20(collateralToken).approve(ROUTER, amount);
        IExchangeRouter(EXCHANGE_ROUTER).sendTokens(
            collateralToken,
            ORDER_VAULT,
            amount
        );

        address[] memory swapPaths = new address[](1);
        swapPaths[0] = MARKET_TOKEN;

        uint256 sizeDeltaUsd = amount * leverage * 1e35 / IERC20Decimals(collateralToken).decimals();

        IExchangeRouter.CreateOrderParams memory params = IExchangeRouter.CreateOrderParams({
            addresses: IExchangeRouter.CreateOrderParamsAddresses({
                receiver: address(this),
                cancellationReceiver: address(0),
                callbackContract: address(0),
                uiFeeReceiver: 0xff00000000000000000000000000000000000001,
                market: MARKET,
                initialCollateralToken: collateralToken,
                swapPath: swapPaths
            }),
            numbers: IExchangeRouter.CreateOrderParamsNumbers({
                sizeDeltaUsd: sizeDeltaUsd,
                initialCollateralDeltaAmount: 0,
                triggerPrice: 0,
                acceptablePrice: 0,
                executionFee: msg.value,
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

        bytes32 positionId = IExchangeRouter(EXCHANGE_ROUTER).createOrder(params);

        // Store position amount
        positionToTokenAmount[positionId] = amount;

        // Mint tokens vault
        _mint(msg.sender, amount);

        return positionId;
    }

    function depositToPT(uint256 amount) external {
        // Transfer vault token dari pengguna ke kontrak PT
        transfer(ptToken, amount);
        
        // Cetak PT dan YT token untuk pengguna
        IPTToken(ptToken).mint(msg.sender, amount);
        IYTToken(ytToken).mint(msg.sender, amount);
    }

    function setPTToken(address _ptToken) external onlyOwner {
        require(ptToken == address(0), "PT already set");
        ptToken = _ptToken;
    }

    function setYTToken(address _ytToken) external onlyOwner {
        require(ytToken == address(0), "YT already set");
        ytToken = _ytToken;
    }
}