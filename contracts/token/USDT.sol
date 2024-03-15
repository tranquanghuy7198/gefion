/* SPDX-License-Identifier: MIT */

pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract USDT is ERC20PresetMinterPauser {
    constructor() ERC20PresetMinterPauser("Tether USD", "USDT") {}
}
