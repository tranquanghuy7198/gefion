/* SPDX-License-Identifier: MIT */

pragma solidity ^0.8.15;

import "../interfaces/IGefionVault.sol";
import "./GefionToken.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract GefionVault is IGefionVault, GefionToken, ReentrancyGuard {
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
    address public currency;
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
    ) GefionToken(name, symbol) {
        require(
            traderSharingRate_ < 10000,
            "GefionVault: sharing rate is too high"
        );
        owner = creator;
        factory = msg.sender;
        currency = currency_;
        router = router_;
        creationTime = block.timestamp;
        traderSharingRate = traderSharingRate_;
    }

    modifier onlyRouter() {
        require(msg.sender == router, "GefionVault: caller is not router");
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
        uint256 vaultBalance = 0;
        if (currency == address(0)) vaultBalance = address(this).balance;
        else vaultBalance = IERC20(currency).balanceOf(address(this));
        return (liquidity * vaultBalance) / totalSupply();
    }

    // Vault owner adds new traders
    function addTraders(
        address vaultOwner,
        address[] calldata traders
    ) external onlyRouter {
        require(vaultOwner == owner, "GefionVault: caller is not owner");
        for (uint256 i = 0; i < traders.length; i++) {
            _isTrader[traders[i]] = true;
        }
    }

    // Vault owner removes traders
    function removeTraders(
        address vaultOwner,
        address[] calldata traders
    ) external onlyRouter {
        require(vaultOwner == owner, "GefionVault: caller is not owner");
        for (uint256 i = 0; i < traders.length; i++) {
            _isTrader[traders[i]] = false;
        }
    }

    // Investor invests and receives liquidity
    function invest(
        address investor,
        uint256 amount
    ) external payable onlyRouter nonReentrant {
        capital += amount;
        _mint(investor, amount);
        if (currency == address(0)) {
            require(msg.value >= amount, "GefionVault: insufficient payment");
            if (msg.value > amount) {
                (bool success, ) = payable(investor).call{
                    value: msg.value - amount
                }("");
                require(success, "GefionVault: failed to return excess");
            }
        } else
            IERC20(currency).safeTransferFrom(investor, address(this), amount);
    }

    // Investor redeems liquidity and receives money
    function redeem(
        address investor,
        uint256 liquidity
    ) external onlyRouter nonReentrant {
        uint256 receivableAmount = receivable(liquidity);
        _burn(investor, liquidity);
        if (currency == address(0)) {
            (bool success, ) = payable(investor).call{value: receivableAmount}(
                ""
            );
            require(success, "GefionVault: failed to redeem");
        } else IERC20(currency).safeTransfer(investor, receivableAmount);
    }

    // Trader borrows money from the vault to trade
    function borrow(
        address trader,
        uint256 amount
    ) external onlyRouter nonReentrant {
        require(_isTrader[trader], "GefionVault: Not GefionVault trader");
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
        if (currency == address(0)) {
            (bool success, ) = payable(trader).call{value: amount}("");
            require(success, "GefionVault: failed to borrow");
        } else IERC20(currency).safeTransfer(trader, amount);
    }

    // Trader repays the vault
    function repay(
        address trader,
        bytes32 investmentId,
        uint256 amount
    ) external payable onlyRouter nonReentrant {
        // Update investment info
        Investment storage investment = getInvestment[investmentId];
        require(
            investment.trader == trader && !investment.completed,
            "GefionVault: invalid investment"
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
        if (currency == address(0)) {
            require(
                msg.value >= amount - traderBenefit,
                "GefionVault: insufficient payment"
            );
            if (msg.value > amount - traderBenefit) {
                (bool success, ) = payable(trader).call{
                    value: msg.value - amount + traderBenefit
                }("");
                require(success, "GefionVault: failed to return excess");
            }
        } else
            IERC20(currency).safeTransferFrom(
                trader,
                address(this),
                amount - traderBenefit
            );
    }
}
