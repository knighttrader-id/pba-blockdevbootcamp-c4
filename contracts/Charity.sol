// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Charity - simple contract to receive, tip owner, and donate full balance to charity
contract Charity {
    address public owner;
    address public charity;

    event Received(address indexed from, uint256 amount);
    event Tipped(address indexed from, address indexed owner, uint256 amount);
    event Donated(address indexed donor, address indexed charity, uint256 amount);
    event CharityChanged(address indexed oldCharity, address indexed newCharity);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    /// @param _owner initial owner address
    /// @param _charity initial charity address
    constructor(address _owner, address _charity) {
        require(_owner != address(0), "owner zero");
        require(_charity != address(0), "charity zero");
        owner = _owner;
        charity = _charity;
    }

    /// Allow contract to receive ETH via plain transfer / send
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /// Fallback just in case (optional)
    fallback() external payable {
        emit Received(msg.sender, msg.value);
    }

    /// Tip: send ETH to owner immediately. Caller sends ETH with this call.
    /// Forwards entire msg.value to owner and reverts if forward failed.
    function tip() external payable {
        require(msg.value > 0, "No ETH sent");
        (bool sent, ) = owner.call{value: msg.value}("");
        require(sent, "Transfer to owner failed");
        emit Tipped(msg.sender, owner, msg.value);
    }

    /// Donate everything stored in this contract to charity.
    /// Restricted to owner (you can change this if you want public donation trigger)
    function donate() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to donate");

        (bool sent, ) = charity.call{value: balance}("");
        require(sent, "Transfer to charity failed");

        emit Donated(msg.sender, charity, balance);
    }

    /// Owner can update charity address if needed
    function setCharity(address _charity) external onlyOwner {
        require(_charity != address(0), "zero address");
        emit CharityChanged(charity, _charity);
        charity = _charity;
    }

    /// Read-only helper to get contract balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
