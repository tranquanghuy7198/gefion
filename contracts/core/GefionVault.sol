/* SPDX-License-Identifier: MIT */

pragma solidity 0.8.24;

import "../interfaces/IGefionFactory.sol";
import "../interfaces/IGefionVault.sol";
import "../interfaces/ISwapRouter.sol";
import "./GefionToken.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract GefionVault is IGefionVault, GefionToken, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct Investment {
        bytes32 id;
        address trader;
        uint256 borrowAmount;
        uint256 repayAmount;
        bool completed;
    }

    address public immutable owner;
    IGefionFactory public immutable factory;
    address public immutable router;
    address public immutable currency;
    uint256 public immutable creationTime;
    uint256 public immutable traderSharingRate;
    uint256 public capital;
    int256 public interest;
    mapping(bytes32 => Investment) public getInvestment;

    bytes32[] private _allInvestments;
    mapping(address => bytes32[]) private _investmentsOf;
    EnumerableSet.AddressSet private _traders;
    EnumerableSet.AddressSet private _investors;

    constructor(
        address creator,
        address currency_, // The currency to invest in this vault
        string memory name, // Vault liquidity name
        string memory symbol, // Vault liquidity symbol
        uint256 traderSharingRate_,
        address router_
    ) GefionToken(name, symbol) {
        require(
            traderSharingRate_ < 10000,
            "GefionVault: sharing rate is too high"
        );
        owner = creator;
        factory = IGefionFactory(msg.sender);
        currency = currency_;
        router = router_;
        creationTime = block.timestamp;
        traderSharingRate = traderSharingRate_;
    }

    modifier onlyRouter() {
        require(msg.sender == router, "GefionVault: caller is not router");
        _;
    }

    function listTraders() external view returns (address[] memory) {
        return _traders.values();
    }

    function listInvestors() external view returns (address[] memory) {
        return _investors.values();
    }

    function investmentHistory() external view returns (Investment[] memory) {
        Investment[] memory investments = new Investment[](
            _allInvestments.length
        );
        unchecked {
            for (uint256 i = 0; i < _allInvestments.length; ++i)
                investments[i] = getInvestment[_allInvestments[i]];
        }
        return investments;
    }

    function traderInvestmentHistory(
        address trader
    ) external view returns (Investment[] memory) {
        Investment[] memory investments = new Investment[](
            _investmentsOf[trader].length
        );
        unchecked {
            for (uint256 i = 0; i < _investmentsOf[trader].length; ++i)
                investments[i] = getInvestment[_investmentsOf[trader][i]];
        }
        return investments;
    }

    function receivable(uint256 liquidity) public pure returns (uint256) {
        return liquidity;
    }

    // Vault owner adds new traders
    function addTraders(
        address vaultOwner,
        address[] calldata traders
    ) external onlyRouter {
        require(vaultOwner == owner, "GefionVault: caller is not owner");
        unchecked {
            for (uint256 i = 0; i < traders.length; ++i)
                _traders.add(traders[i]);
        }
    }

    // Vault owner removes traders
    function removeTraders(
        address vaultOwner,
        address[] calldata traders
    ) external onlyRouter {
        require(vaultOwner == owner, "GefionVault: caller is not owner");
        unchecked {
            for (uint256 i = 0; i < traders.length; ++i)
                _traders.remove(traders[i]);
        }
    }

    // Investor invests and receives liquidity
    function invest(
        address investor,
        uint256 amount
    ) external payable nonReentrant onlyRouter {
        if (!_investors.contains(investor)) _investors.add(investor);
        capital = capital + amount;
        _mint(investor, amount);
        if (currency == address(0)) {
            require(msg.value >= amount, "GefionVault: insufficient payment");
            if (msg.value > amount) {
                (bool success, ) = payable(investor).call{
                    value: msg.value - amount
                }("");
                require(success, "GefionVault: failed to return excess");
            }
        } else {
            IERC20(currency).safeTransferFrom(investor, address(this), amount);
            (bool success, ) = payable(investor).call{value: msg.value}("");
            require(success, "GefionVault: failed to return excess");
        }
    }

    // Investor redeems liquidity and receives money
    function redeem(
        address investor,
        uint256 liquidity
    ) external nonReentrant onlyRouter {
        uint256 receivableAmount = receivable(liquidity);
        _burn(investor, liquidity);
        if (currency == address(0)) {
            (bool success, ) = payable(investor).call{value: receivableAmount}(
                ""
            );
            require(success, "GefionVault: failed to redeem");
        } else IERC20(currency).safeTransfer(investor, receivableAmount);
    }

    // Traders borrows money from the vault, swaps and earns profit then repays to the vault
    function trade(
        address trader,
        uint256 amount,
        address dexRouterAddr,
        address targetedCurrency // Swap vault currency to get `targetedCurrency`
    ) external nonReentrant onlyRouter {
        // Validate
        require(
            _traders.contains(trader),
            "GefionVault: Not GefionVault trader"
        );
        require(
            factory.isDexRouterValid(dexRouterAddr),
            "GefionVault: invalid DEX"
        );

        // Prepare DEX info
        ISwapRouter dexRouter = ISwapRouter(dexRouterAddr);
        address[] memory path = new address[](2);
        path[0] = currency;
        path[1] = targetedCurrency;
        uint256 deadline = block.timestamp + 20 * 60;

        // Trade
        if (currency == address(0))
            dexRouter.swapExactETHForTokens{value: amount}(
                0,
                path,
                address(this),
                deadline
            );
        else {
            IERC20(currency).approve(dexRouterAddr, amount);
            dexRouter.swapExactTokensForTokens(
                amount,
                0,
                path,
                address(this),
                deadline
            );
        }
    }
}
