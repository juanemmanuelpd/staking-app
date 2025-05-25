// License
// SPDX-License-Identifier: MIT

// Solidity compiler version
pragma solidity 0.8.24;

// Libraries
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

// Contract
contract stakingToken is ERC20{

    // Variables

    // Constructors
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_){

    }

    // Functions
    function mint(uint256 amount_)external{
        _mint(msg.sender, amount_);
    }

}