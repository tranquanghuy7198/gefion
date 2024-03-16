/* SPDX-License-Identifier: MIT */

pragma solidity 0.8.24;

interface IGefionVault {
    function addTraders(
        address vaultOwner,
        address[] calldata traders
    ) external;

    function removeTraders(
        address vaultOwner,
        address[] calldata traders
    ) external;

    function invest(address investor, uint256 amount) external payable;

    function redeem(address user, uint256 liquidity) external;

    function trade(
        address trader,
        uint256 amount,
        address dexRouterAddr,
        address targetedCurrency
    ) external;
}
