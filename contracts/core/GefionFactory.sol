/* SPDX-License-Identifier: MIT */

pragma solidity ^0.8.15;

import "../interfaces/IGefionFactory.sol";
import "./GefionVault.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GefionFactory is IGefionFactory, Ownable {
    address public router;
    address[] public allPools;
    mapping(address => mapping(address => address)) public override getVault;

    constructor() Ownable() {}

    function allPoolsLength() external view returns (uint256) {
        return allPools.length;
    }

    function setRouter(address router_) external onlyOwner {
        router = router_;
    }

    function createVault(
        address currency,
        string memory name,
        string memory symbol,
        uint256 traderSharingRate
    ) external returns (address) {
        require(
            getVault[msg.sender][currency] == address(0),
            "GefionFactory: vault exists"
        );
        bytes32 salt = keccak256(abi.encodePacked(currency, msg.sender));
        GefionVault vault = new GefionVault{salt: salt}(
            msg.sender,
            currency,
            name,
            symbol,
            traderSharingRate,
            router
        );
        allPools.push(address(vault));
        getVault[msg.sender][currency] = address(vault);
        emit VaultCreated(address(vault), msg.sender, currency);
        return address(vault);
    }
}
