/* SPDX-License-Identifier: MIT */

pragma solidity ^0.8.15;

interface IGefionVault {
    function addTraders(
        address vaultOwner,
        address[] calldata traders
    ) external;

    function removeTraders(
        address vaultOwner,
        address[] calldata traders
    ) external;

    function invest(address investor, uint256 amount) external;

    function redeem(address user, uint256 liquidity) external;

    function borrow(address trader, uint256 amount) external;

    function repay(
        address trader,
        bytes32 investmentId,
        uint256 amount
    ) external;
}
