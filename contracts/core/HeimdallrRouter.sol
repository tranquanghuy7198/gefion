/* SPDX-License-Identifier: MIT */

pragma solidity ^0.8.15;

import "../interfaces/IOdinFactory.sol";
import "../interfaces/IThorToken.sol";
import "../interfaces/IFreyrVault.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HeimdallrRouter is Ownable {
    using SafeERC20 for IERC20;

    address public factory;

    constructor(address factory_) {
        require(msg.sender == Ownable(factory_).owner());
        factory = factory_;
    }

    function addTraders(
        address vaultCurrency,
        address[] memory traders
    ) external {
        address vault = IOdinFactory(factory).getVault(
            msg.sender,
            vaultCurrency
        );
        IFreyrVault(vault).addTraders(msg.sender, traders);
    }

    function removeTraders(
        address vaultCurrency,
        address[] memory traders
    ) external {
        address vault = IOdinFactory(factory).getVault(
            msg.sender,
            vaultCurrency
        );
        IFreyrVault(vault).removeTraders(msg.sender, traders);
    }

    function invest(
        address vaultOwner,
        address vaultCurrency,
        uint256 amount
    ) external {
        address vault = IOdinFactory(factory).getVault(
            vaultOwner,
            vaultCurrency
        );
        IFreyrVault(vault).invest(msg.sender, amount);
    }

    function redeem(
        address vaultOwner,
        address vaultCurrency,
        uint256 liquidity
    ) external {
        address vault = IOdinFactory(factory).getVault(
            vaultOwner,
            vaultCurrency
        );
        IFreyrVault(vault).redeem(msg.sender, liquidity);
    }

    function borrow(
        address vaultOwner,
        address vaultCurrency,
        uint256 amount
    ) external {
        address vault = IOdinFactory(factory).getVault(
            vaultOwner,
            vaultCurrency
        );
        IFreyrVault(vault).borrow(msg.sender, amount);
    }

    function repay(
        address vaultOwner,
        address vaultCurrency,
        bytes32 investmentId,
        uint256 amount
    ) external {
        address vault = IOdinFactory(factory).getVault(
            vaultOwner,
            vaultCurrency
        );
        IFreyrVault(vault).repay(msg.sender, investmentId, amount);
    }
}
