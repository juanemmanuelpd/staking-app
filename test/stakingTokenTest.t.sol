// License
// SPDX-License-Identifier: MIT

// Solidity compiler version
pragma solidity 0.8.24;

// Libreries
import "forge-std/Test.sol";
import "../src/stakingToken.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


// Contract
contract stakingTokenTest is Test{

    // Variables
    stakingToken stakingTokenTesting;
    string name_ = "Staking Token";
    string symbol_ = "STK";
    address randomUser = vm.addr(1);

    // Functions
    function setUp() public{
        stakingTokenTesting = new stakingToken(name_, symbol_);
    }

    function testStakingTokenMintsCorrectly() public{
        vm.startPrank(randomUser);
        uint256 amount_ = 1 ether;
        uint256 balanceBefore_ = IERC20(address (stakingTokenTesting)).balanceOf(randomUser);
        stakingTokenTesting.mint(amount_);
        uint256 balanceAfter_ = IERC20(address (stakingTokenTesting)).balanceOf(randomUser);
        assert(balanceAfter_ - balanceBefore_ == amount_);
        vm.stopPrank();
    }
}