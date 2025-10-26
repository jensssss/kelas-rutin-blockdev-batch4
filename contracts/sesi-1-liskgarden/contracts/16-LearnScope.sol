// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LearnScopes {
    // 1. STATE VARIABLE: Stored in blockchain storage
    uint256 public plantCounter;  // Permanently stored
    address public owner;         // Gas Fee for write/update

    // 2. GLOBAL VARIABLES: Built-in Solidity
    function getGlobalVariables() public view returns (
        address sender,
        uint256 timestamp,
        uint256 blockNumber,
        address contractAddress
    ) {
        sender = msg.sender;              // Address that calls the function
        timestamp = block.timestamp;      // Current unix timestamp
        blockNumber = block.number;       // Current block number
        contractAddress = address(this);  // Current contract address

        return (sender, timestamp, blockNumber, contractAddress);
    }

    // 3. LOCAL VARIABLES: Temporary in function
    function calculateAge(uint256 _plantedTime) public view returns (uint256) {
        // Local variable - only when the function is working
        uint256 currentTime = block.timestamp;
        uint256 age = currentTime - _plantedTime;

        // age dan currentTime will be disapear after the function is executed
        return age;
    }

    constructor() {
        owner = msg.sender;
        plantCounter = 0;
    }

    function addPlant() public {
        // Local variable
        uint256 newId = plantCounter + 1;

        // Update state variable (gas fee)
        plantCounter = newId;
    }
}