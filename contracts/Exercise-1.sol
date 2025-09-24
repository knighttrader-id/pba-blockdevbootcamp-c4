// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract Excercise1 {
    uint256 number;

    // internal pure: can only be called from inside the contract
    function calculateSum(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    // external view: can be called from outside the contract, only reads data
    function retrieve() external view returns (uint256) {
        return number;
    }

    // external: can be called from outside the contract, stores calculation result
    function store(uint256 num) external {
        number = calculateSum(number, num);
    }
}