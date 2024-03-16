/* SPDX-License-Identifier: MIT */

pragma solidity 0.8.24;

import "../interfaces/IGefionFactory.sol";
import "./GefionVault.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract GefionFactory is IGefionFactory, Ownable2Step {
    using EnumerableSet for EnumerableSet.AddressSet;

    address public router;
    mapping(address => mapping(address => address)) public override getVault;
    address[] private _allVaults;
    mapping(address => address[]) private _vaultsOf;
    EnumerableSet.AddressSet private _dexRouters;

    constructor() Ownable() {}

    function allVaults() external view returns (address[] memory) {
        return _allVaults;
    }

    function getVaultsOf(
        address vaultOwner
    ) external view returns (address[] memory) {
        return _vaultsOf[vaultOwner];
    }

    function isDexRouterValid(address dexRouter) external view returns (bool) {
        return _dexRouters.contains(dexRouter);
    }

    function listDexRouters() external view returns (address[] memory) {
        return _dexRouters.values();
    }

    function setRouter(address router_) external onlyOwner {
        router = router_;
    }

    function addDexRouters(address[] memory dexRouters) external onlyOwner {
        unchecked {
            for (uint256 i = 0; i < dexRouters.length; ++i)
                _dexRouters.add(dexRouters[i]);
        }
    }

    function removeDexRouters(address[] memory dexRouters) external onlyOwner {
        unchecked {
            for (uint256 i = 0; i < dexRouters.length; ++i)
                _dexRouters.remove(dexRouters[i]);
        }
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
