// License
// SPDX-License-Identifier: MIT

// Solidity compiler version
pragma solidity 0.8.24;

// Libreries
import "forge-std/Test.sol";
import "../src/stakingToken.sol";
import "../src/stakingApp.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

// Contract
contract stakingAppTest is Test{

    stakingToken stakingToken_t;
    stakingApp stakingApp_t;

    // Staking Token parameters
    string name_ = "Staking Token";
    string symbol_ = "STK";

    // Staking App parameters
    address owner = vm.addr(1);
    address randomUser = vm.addr(2);
    uint256 stakingPeriod_ = 1000000000000;
    uint256 fixedStakingAmount_ = 10;
    uint256 rewardPerPeriod_ = 1 ether;
    

    function setUp() external{
        stakingToken_t = new stakingToken(name_, symbol_);
        stakingApp_t = new stakingApp(address(stakingToken_t), owner, stakingPeriod_, fixedStakingAmount_, rewardPerPeriod_);
    }

    function testStakingTokenCorrectlyDeployed() external view{
        assert(address(stakingToken_t) != address(0));
    }

      function testStakingAppCorrectlyDeployed() external view{
        assert(address(stakingApp_t) != address(0));    
    }

    function testShouldRevertIfNotOwner() external{
        uint256 newStakingPeriod_= 1;
        vm.expectRevert();
        stakingApp_t.modifyStakingPeriod(newStakingPeriod_);
    }

    function testShouldModifyStakingPeriod() external{
        vm.startPrank(owner);
        uint256 newStakingPeriod_= 1;
        uint256 stakingPeriodBefore_ = stakingApp_t.stakingPeriod();
        stakingApp_t.modifyStakingPeriod(newStakingPeriod_);
        uint256 stakingPeriodAfter_ = stakingApp_t.stakingPeriod();
        assert(stakingPeriodBefore_ != newStakingPeriod_);
        assert(stakingPeriodAfter_ == newStakingPeriod_);
        vm.stopPrank();
    }

    function testContractReceivesEthCorrectly() external{
        vm.startPrank(owner);
        vm.deal(owner, 1 ether);
        uint256 etherValue = 1 ether;
        uint256 balanceBefore_ = address(stakingApp_t).balance;
        (bool success,) = address(stakingApp_t).call{value: etherValue}("");
        uint256 balanceAfter = address(stakingApp_t).balance;
        require(success, "Transfer failed");
        assert(balanceAfter - balanceBefore_ == etherValue);
        vm.stopPrank();
    }

    // Deposit function tests
    function testIncorrectAmountShouldRevert() external{
        vm.startPrank(randomUser);
        uint256 depositAmount = 1;
        vm.expectRevert("Incorrect amount");
        stakingApp_t.depositTokens(depositAmount);
        vm.stopPrank();
    }

    function testDepositTokenCorrectly() external{
        vm.startPrank(randomUser);
        uint256 tokenAmount = stakingApp_t.fixedStakingAmount();
        stakingToken_t.mint(tokenAmount);
        uint256 userBalanceBefore = stakingApp_t.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp_t.elapsePeriod(randomUser);
        IERC20(stakingToken_t).approve(address(stakingApp_t), tokenAmount);
        stakingApp_t.depositTokens(tokenAmount);
        uint256 userBalanceAfter = stakingApp_t.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp_t.elapsePeriod(randomUser);
        assert(userBalanceAfter - userBalanceBefore == tokenAmount);  
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);
        vm.stopPrank();
    }


    function testUserCanNotDepositMoreThanOnce() external{
        vm.startPrank(randomUser);
        uint256 tokenAmount = stakingApp_t.fixedStakingAmount();
        stakingToken_t.mint(tokenAmount);
        uint256 userBalanceBefore = stakingApp_t.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp_t.elapsePeriod(randomUser);
        IERC20(stakingToken_t).approve(address(stakingApp_t), tokenAmount);
        stakingApp_t.depositTokens(tokenAmount);
        uint256 userBalanceAfter = stakingApp_t.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp_t.elapsePeriod(randomUser);
        assert(userBalanceAfter - userBalanceBefore == tokenAmount);  
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);

        stakingToken_t.mint(tokenAmount);
        IERC20(stakingToken_t).approve(address(stakingApp_t), tokenAmount);
        vm.expectRevert("User already deposited");
        stakingApp_t.depositTokens(tokenAmount);

        vm.stopPrank();
    }

    // Withdraw functions test

    function testCanOnlyWithdraw0WithoutDeposit() external{ 
        vm.startPrank(randomUser);
        uint256 userBalanceBefore = stakingApp_t.userBalance(randomUser);
        stakingApp_t.withdrawTokens();
        uint256 userBalanceAfter = stakingApp_t.userBalance(randomUser);
        assert(userBalanceAfter == userBalanceBefore);
        vm.stopPrank();
    }

    function testWithdrawTokensCorrectly() external{
        vm.startPrank(randomUser);

        uint256 tokenAmount = stakingApp_t.fixedStakingAmount();
        stakingToken_t.mint(tokenAmount);
        uint256 userBalanceBefore = stakingApp_t.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp_t.elapsePeriod(randomUser);
        IERC20(stakingToken_t).approve(address(stakingApp_t), tokenAmount);
        stakingApp_t.depositTokens(tokenAmount);
        uint256 userBalanceAfter = stakingApp_t.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp_t.elapsePeriod(randomUser);
        assert(userBalanceAfter - userBalanceBefore == tokenAmount);  
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);

        uint256 userBalanceBefore2 = IERC20(stakingToken_t).balanceOf(randomUser); 
        uint256 userBalanceInMapping = stakingApp_t.userBalance(randomUser);
        stakingApp_t.withdrawTokens();
        uint256 userBalanceAfter2 = IERC20(stakingToken_t).balanceOf(randomUser);
        assert(userBalanceAfter2 == userBalanceBefore2 + userBalanceInMapping);

        vm.stopPrank();
    }

    // Claim rewards functions tests
    function testCanNotClaimIfNotStaking() external{
        vm.startPrank(randomUser);
        vm.expectRevert("Not staking");
        stakingApp_t.claimRewards();
        vm.stopPrank();
    }

    function testCanNotClaimIfNotElapsedTime() external{
        vm.startPrank(randomUser);
       
        uint256 tokenAmount = stakingApp_t.fixedStakingAmount();
        stakingToken_t.mint(tokenAmount);
        uint256 userBalanceBefore = stakingApp_t.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp_t.elapsePeriod(randomUser);
        IERC20(stakingToken_t).approve(address(stakingApp_t), tokenAmount);
        stakingApp_t.depositTokens(tokenAmount);
        uint256 userBalanceAfter = stakingApp_t.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp_t.elapsePeriod(randomUser);
        assert(userBalanceAfter - userBalanceBefore == tokenAmount);  
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);

        vm.expectRevert("Need to wait");
        stakingApp_t.claimRewards();

        vm.stopPrank();
    }

    function testShouldRevertIfNotEth() external{
        vm.startPrank(randomUser);
       
        uint256 tokenAmount = stakingApp_t.fixedStakingAmount();
        stakingToken_t.mint(tokenAmount);
        uint256 userBalanceBefore = stakingApp_t.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp_t.elapsePeriod(randomUser);
        IERC20(stakingToken_t).approve(address(stakingApp_t), tokenAmount);
        stakingApp_t.depositTokens(tokenAmount);
        uint256 userBalanceAfter = stakingApp_t.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp_t.elapsePeriod(randomUser);
        assert(userBalanceAfter - userBalanceBefore == tokenAmount);  
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);

        vm.warp(block.timestamp + stakingPeriod_);
        vm.expectRevert("Transfer failed");
        stakingApp_t.claimRewards();

        vm.stopPrank();
    }

    function testCanClaimRewardsCorrectly() external{
        vm.startPrank(randomUser); 
        uint256 tokenAmount = stakingApp_t.fixedStakingAmount();
        stakingToken_t.mint(tokenAmount);
        uint256 userBalanceBefore = stakingApp_t.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp_t.elapsePeriod(randomUser);
        IERC20(stakingToken_t).approve(address(stakingApp_t), tokenAmount);
        stakingApp_t.depositTokens(tokenAmount);
        uint256 userBalanceAfter = stakingApp_t.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp_t.elapsePeriod(randomUser);
        assert(userBalanceAfter - userBalanceBefore == tokenAmount);  
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);
        vm.stopPrank();

        vm.startPrank(owner);
        uint256 etherAmount = 100000 ether;
        vm.deal(owner, etherAmount);
        (bool success,) = address(stakingApp_t).call{value: etherAmount}("");
        require(success, "Test transfer failed");
        vm.stopPrank();

        vm.startPrank(randomUser);
        vm.warp(block.timestamp + stakingPeriod_);
        uint256 etherAmountBefore = address(randomUser).balance;
        stakingApp_t.claimRewards();
        uint256 etherAmountAfter = address(randomUser).balance;
        uint256 elapsedPeriod = stakingApp_t.elapsePeriod(randomUser);


        assert(etherAmountAfter - etherAmountBefore == rewardPerPeriod_);
        assert(elapsedPeriod == block.timestamp);


        vm.stopPrank();
    }

}