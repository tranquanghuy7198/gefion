/* SPDX-License-Identifier: MIT */

pragma solidity 0.8.24;

import "../interfaces/IGefionFactory.sol";
import "../interfaces/IGefionVault.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GefionRouter {
    using SafeERC20 for IERC20;

    address public immutable factory;

    constructor(address factory_) {
        require(
            msg.sender == Ownable(factory_).owner(),
            "GefionRouter: invalid router deployer"
        );
        factory = factory_;
    }

    function addTraders(
        address vaultCurrency,
        address[] memory traders
    ) external {
        address vault = IGefionFactory(factory).getVault(
            msg.sender,
            vaultCurrency
        );
        IGefionVault(vault).addTraders(msg.sender, traders);
    }

    function removeTraders(
        address vaultCurrency,
        address[] memory traders
    ) external {
        address vault = IGefionFactory(factory).getVault(
            msg.sender,
            vaultCurrency
        );
        IGefionVault(vault).removeTraders(msg.sender, traders);
    }

    function invest(
        address vaultOwner,
        address vaultCurrency,
        uint256 amount
    ) external payable {
        address vault = IGefionFactory(factory).getVault(
            vaultOwner,
            vaultCurrency
        );
        IGefionVault(vault).invest{value: msg.value}(msg.sender, amount);
    }

    function redeem(
        address vaultOwner,
        address vaultCurrency,
        uint256 liquidity
    ) external {
        address vault = IGefionFactory(factory).getVault(
            vaultOwner,
            vaultCurrency
        );
        IGefionVault(vault).redeem(msg.sender, liquidity);
    }

    function trade(
        address vaultOwner,
        address vaultCurrency,
        uint256 amount,
        address dexRouterAddr,
        address targetedCurrency
    ) external {
        address vault = IGefionFactory(factory).getVault(
            vaultOwner,
            vaultCurrency
        );
        IGefionVault(vault).trade(
            msg.sender,
            amount,
            dexRouterAddr,
            targetedCurrency
        );
    }
}
