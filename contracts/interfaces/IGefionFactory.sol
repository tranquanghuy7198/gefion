/* SPDX-License-Identifier: MIT */

pragma solidity 0.8.24;

interface IGefionFactory {
    event VaultCreated(address vault, address owner, address currency);

    function isDexRouterValid(address dexRouter) external view returns (bool);

    function getVault(
        address vaultOwner,
        address vaultCurrency
    ) external view returns (address vault);
}
