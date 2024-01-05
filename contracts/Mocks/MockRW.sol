// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
///@notice Mock of Base Asset ERC20 contract

contract MockRW is ERC20, Ownable(msg.sender) {

    constructor() ERC20("Mock Reward", "MOCK-R") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}