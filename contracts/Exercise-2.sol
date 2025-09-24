// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract Excercise2 {
    struct Box {
        uint256 width;
        uint256 length;
        uint256 height;
    }

    Box[] public boxes;

    /// @notice Add a new Box to the boxes array
    function addBox(uint256 width, uint256 length, uint256 height) external {
        boxes.push(Box(width, length, height));
    }
}