/* SPDX-License-Identifier: MIT */

pragma solidity ^0.8.15;

import "../interfaces/IFreyrVault.sol";
import "./ThorToken.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract FreyrVault is IFreyrVault, ThorToken {
    using SafeERC20 for IERC20;

    struct Investment {
        bytes32 id;
        address trader;
        uint256 borrowAmount;
        uint256 repayAmount;
        bool completed;
    }

    address public owner;
    address public factory;
    address public router;
    IERC20 public currency;
    uint256 public creationTime;
    uint256 public capital;
    int256 public interest;
    uint256 public traderSharingRate;
    mapping(bytes32 => Investment) public getInvestment;

    bytes32[] private _allInvestments;
    mapping(address => bytes32[]) private _investmentsOf;
    mapping(address => bool) private _isTrader;

    constructor(
        address creator,
        address currency_, // The currency to invest in this vault
        string memory name, // Vault liquidity name
        string memory symbol, // Vault liquidity symbol
        uint256 traderSharingRate_,
        address router_
    ) ThorToken(name, symbol) {
        require(
            traderSharingRate_ < 10000,
            "FreyrVault: sharing rate is too high"
        );
        owner = creator;
        factory = msg.sender;
        currency = IERC20(currency_);
        router = router_;
        creationTime = block.timestamp;
        traderSharingRate = traderSharingRate_;
    }

    modifier onlyRouter() {
        require(msg.sender == router, "FreyrVault: caller is not router");
        _;
    }

    function investmentHistory() external view returns (Investment[] memory) {
        Investment[] memory investments = new Investment[](
            _allInvestments.length
        );
        for (uint256 i = 0; i < _allInvestments.length; i++) {
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
        for (uint256 i = 0; i < _investmentsOf[trader].length; i++) {
            investments[i] = getInvestment[_investmentsOf[trader][i]];
        }
        return investments;
    }

    function receivable(uint256 liquidity) public view returns (uint256) {
        return (liquidity * currency.balanceOf(address(this))) / totalSupply();
    }

    // Vault owner adds new traders
    function addTraders(
        address vaultOwner,
        address[] calldata traders
    ) external onlyRouter {
        require(vaultOwner == owner, "FreyrVault: caller is not owner");
        for (uint256 i = 0; i < traders.length; i++) {
            _isTrader[traders[i]] = true;
        }
    }

    // Vault owner removes traders
    function removeTraders(
        address vaultOwner,
        address[] calldata traders
    ) external onlyRouter {
        require(vaultOwner == owner, "FreyrVault: caller is not owner");
        for (uint256 i = 0; i < traders.length; i++) {
            _isTrader[traders[i]] = false;
        }
    }

    // Investor invests and receives liquidity
    function invest(address investor, uint256 amount) external onlyRouter {
        capital += amount;
        _mint(investor, amount);
        currency.safeTransferFrom(investor, address(this), amount);
    }

    // Investor redeems liquidity and receives money
    function redeem(address investor, uint256 liquidity) external onlyRouter {
        uint256 receivableAmount = receivable(liquidity);
        _burn(investor, liquidity);
        currency.safeTransfer(investor, receivableAmount);
    }

    // Trader borrows money from the vault to trade
    function borrow(address trader, uint256 amount) external onlyRouter {
        require(_isTrader[trader], "FreyrVault: Not FreyrVault trader");
        bytes32 investmentId = keccak256(
            abi.encodePacked(trader, amount, block.timestamp)
        );
        Investment memory investment = Investment(
            investmentId,
            trader,
            amount,
            0,
            false
        );
        getInvestment[investmentId] = investment;
        _investmentsOf[trader].push(investmentId);
        _allInvestments.push(investmentId);
        currency.safeTransfer(trader, amount);
    }

    // Trader repays the vault
    function repay(
        address trader,
        bytes32 investmentId,
        uint256 amount
    ) external onlyRouter {
        // Update investment info
        Investment storage investment = getInvestment[investmentId];
        require(
            investment.trader == trader && !investment.completed,
            "FreyrVault: invalid investment"
        );
        investment.repayAmount = amount;
        investment.completed = true;

        // Share the benefit to the trader
        uint256 traderBenefit = 0;
        if (investment.repayAmount > investment.borrowAmount) {
            traderBenefit =
                ((investment.repayAmount - investment.borrowAmount) *
                    traderSharingRate) /
                10000;
        }
        interest +=
            int256(investment.repayAmount) -
            int256(investment.borrowAmount);
        currency.safeTransferFrom(
            trader,
            address(this),
            amount - traderBenefit
        );
    }
}
