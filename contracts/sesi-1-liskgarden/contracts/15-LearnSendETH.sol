// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LearnSendETH {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // Receive ETH
    function deposit() public payable {}

    // Send ETH to someone
    function sendReward(address _to) public {
        require(msg.sender == owner, "Hanya owner");

        // Send 0.001 ETH
        (bool success, ) = _to.call{value: 0.001 ether}("");
        require(success, "Transfer gagal");
    }

    // Check wallet balance
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}