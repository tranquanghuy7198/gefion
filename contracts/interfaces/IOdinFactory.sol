/* SPDX-License-Identifier: MIT */

pragma solidity ^0.8.15;

interface IOdinFactory {
    event VaultCreated(address vault, address owner, address currency);

    function getVault(
        address vaultOwner,
        address vaultCurrency
    ) external view returns (address vault);
}
