/* SPDX-License-Identifier: MIT */

pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract ADA is ERC20PresetMinterPauser {
    constructor() ERC20PresetMinterPauser("Cardano Token", "ADA") {}
}
