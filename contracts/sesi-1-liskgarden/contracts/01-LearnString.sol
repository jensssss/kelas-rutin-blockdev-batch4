// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LearnString {
    // Variabel string for storing plant name
    string public plantName;

    // Constructor for initial value
    constructor() {
        plantName = "Rose";
    }

    // Function for changing name
    function changeName(string memory _newName) public {
        plantName = _newName;
    }
}