// License

// SPDX-License-Identifier: MIT

// Solidity compiler version

pragma solidity 0.8.24;

// Libraries

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


// Staking fixed amount
// Staking reward period

// Contract

contract stakingApp is Ownable{

    // Variables

    address public stakingToken;
    uint256 public stakingPeriod;
    uint256 public fixedStakingAmount;
    uint256 public rewardPerPeriod;
    mapping (address => uint256)public userBalance;
    mapping (address => uint256)public elapsePeriod;

    // Events

    event e_modifyStakingPeriod(uint256 newStakingPeriod_);
    event e_depositTokens(address user_, uint256 depositAmount_);
    event e_withdrawTokens(address user_, uint256 withdrawAmount_);
    event e_ethSend(uint256 amount_);

    // Constructor

    constructor(address stakingToken_, address owner_, uint256 stakingPeriod_, uint256 fixedStakingAmount_, uint256 rewardPerPeriod_) Ownable(owner_) {
        stakingToken = stakingToken_;
        stakingPeriod = stakingPeriod_;
        fixedStakingAmount = fixedStakingAmount_;
        rewardPerPeriod = rewardPerPeriod_;
    }

    // Functions

    // External functions

    function modifyStakingPeriod(uint256 newStakingPeriod_) external onlyOwner{
        stakingPeriod = newStakingPeriod_;
        emit e_modifyStakingPeriod(newStakingPeriod_);
    }

    function depositTokens(uint256 tokenAmount_) external{
        require(tokenAmount_ == fixedStakingAmount, "Incorrect amount");
        require(userBalance[msg.sender] == 0, "User already deposited");
        IERC20(stakingToken).transferFrom(msg.sender, address (this), tokenAmount_);
        userBalance[msg.sender] += tokenAmount_;
        elapsePeriod[msg.sender] = block.timestamp;
        emit e_depositTokens(msg.sender, tokenAmount_);
    }

    function withdrawTokens()external{
        uint256 userBalance_ = userBalance[msg.sender];
        userBalance[msg.sender] = 0;
        IERC20(stakingToken).transfer(msg.sender, userBalance_);
        emit e_withdrawTokens(msg.sender, userBalance_);
    }

    function claimRewards()external{
      require(userBalance[msg.sender] == fixedStakingAmount, "Not staking");
      uint256 elapsePeriod_ = block.timestamp - elapsePeriod[msg.sender]; 
      require(elapsePeriod_ >= stakingPeriod, "Need to wait");
      elapsePeriod[msg.sender] = block.timestamp;
      (bool success,) = msg.sender.call{value: rewardPerPeriod}("");
      require(success,"Transfer failed");
    }

    receive()external payable onlyOwner{
        emit e_ethSend(msg.value);
    }

    // Internal functions



}