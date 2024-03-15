/* SPDX-License-Identifier: MIT */

pragma solidity 0.8.15;

import "../interfaces/IGefionFactory.sol";
import "./GefionVault.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract GefionFactory is IGefionFactory, Ownable2Step {
    address public router;
    mapping(address => mapping(address => address)) public override getVault;
    address[] private _allVaults;
    mapping(address => address[]) _vaultsOf;

    constructor() Ownable() {}

    function allVaults() external view returns (address[] memory) {
        return _allVaults;
    }

    function getVaultsOf(
        address vaultOwner
    ) external view returns (address[] memory) {
        return _vaultsOf[vaultOwner];
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
        _allVaults.push(address(vault));
        _vaultsOf[msg.sender].push(address(vault));
        getVault[msg.sender][currency] = address(vault);
        emit VaultCreated(address(vault), msg.sender, currency);
        return address(vault);
    }
}
