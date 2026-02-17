// SPDX-License-Identifier: MIT
pragma solidity 0.8.31;

contract tips {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // 1. Put fund in smart contract
    function addtips() public payable {
        require(msg.value > 0, "No ETH sent");
    }

    // 2. View balance
    function viewtips() public view returns (uint) {
        return address(this).balance;
    }

    // 3. Structure for a Waitress
    struct Waitress {
        address payable walletAddress;
        string name;
        uint percent;
    }

    Waitress[] private waitress; // List of all waitresses

    // 4. View waitress
    function viewWaitress() public view returns (Waitress[] memory) {
        return waitress;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    function addWaitress(
        address payable walletAddress,
        string memory name,
        uint percent
    ) public onlyOwner {
        require(percent <= 100, "Percent must not exceed 100");

        bool waitressExist = false;
        uint totalPercent = percent;

        for (uint i = 0; i < waitress.length; i++) {
            if (waitress[i].walletAddress == walletAddress) {
                waitressExist = true;
            }
            totalPercent += waitress[i].percent;
        }

        require(!waitressExist, "Waitress already exists");
        require(totalPercent <= 100, "Total percent exceeds 100");

        waitress.push(Waitress(walletAddress, name, percent));
    }

    function removeWaitress(address walletAddress) public onlyOwner {
        for (uint i = 0; i < waitress.length; i++) {
            if (waitress[i].walletAddress == walletAddress) {
                for (uint j = i; j < waitress.length - 1; j++) {
                    waitress[j] = waitress[j + 1];
                }
                waitress.pop();
                break;
            }
        }
    }

    // Internal transfer helper
    function _transferFunds(address payable to, uint amount) internal {
        require(amount > 0, "Amount is zero");
        (bool success, ) = to.call{value: amount}("");
        require(success, "Transfer failed");
    }

    // 5. Distribute balance
    function distributeBalance() public onlyOwner {
        uint contractBalance = address(this).balance;
        require(contractBalance > 0, "No money to distribute");
        require(waitress.length > 0, "No waitresses");

        for (uint i = 0; i < waitress.length; i++) {
            uint distributeAmount =
                (contractBalance * waitress[i].percent) / 100;

            _transferFunds(waitress[i].walletAddress, distributeAmount);
        }
    }
}
