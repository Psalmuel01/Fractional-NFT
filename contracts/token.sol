//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Psalmuel is ERC20 {
    constructor() ERC20("Psalmuel01", "PSM") {}

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }
}