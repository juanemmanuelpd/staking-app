# Staking App
## Overview 🪙
A staking token based in ERC-20 protocol. Compiled and tested in Foundry.
## Features 📃
* Create your own token ERC-20.
* Deposit your tokens to staking and withdraws it when the period ends.
* Claim rewards for staking.
## Technical details ⚙️
* Framework CLI -> Foundry.
* Forge version -> 1.1.0-stable.
* Solidity compiler version -> 0.8.24.
## Deploying the contract 🛠️
1. Clone the GitHub repository.
2. Open Visual Studio Code (you should already have Foundry installed).
3. Select "File" > "Open Folder", select the cloned repository folder.
4. In the project navigation bar, open the "stakingApp.sol" file located in the "src" folder.
5. In the toolbar above, select "Terminal" > "New Terminal".
6. Select the "Git bash" terminal (previously installed).
7. Run the `forge build` command to compile the script.
8. In the project navigation bar, open the "stakingAppTest.t.sol" file located in the "test" folder.
9. Run the command `forge test --match-test` followed by the name of a test function to test it and verify the smart contract functions are working correctly. For example, run `forge test --match-test testStakingTokenCorrectlyDeployed -vvvv` to test the `testStakingTokenCorrectlyDeployed` function.
10. Run `forge coverage` to generate a code coverage report, which allows you to verify which parts of the "stakingApp.sol" and "stakingToken.sol" scripts code (in the "src" folder) are executed by the tests. This helps identify areas outside the coverage that could be exposed to errors/vulnerabilities.
## Functions (Staking Token) 💻
* `mint()` -> Mints tokens for can stake it.
## Functions (Staking App) 💻
* `modifyStakingPeriod()` -> Modify the time to lock your tokens and receive rewards.
* `depositTokens()` -> Deposit a definite tokens to staking.
* `withdrawTokens()` -> Withdraw all yours tokens in staking.
* `claimRewards()` -> Claim the rewards for staking in the definite time.
* `receive()` -> The admin enter to the smart contract the tokens that will be using to rewards the users for staking.
## Testing functions (Unit testing) ⌨️
* `testStakingTokenMintsCorrectly()` ->  
* `testStakingTokenCorrectlyDeployed()` ->
* `testStakingAppCorrectlyDeployed()` ->
* `testShouldRevertIfNotOwner()` ->
* `testShouldModifyStakingPeriod()` ->
* `testContractReceivesEthCorrectly()` ->
* `testIncorrectAmountShouldRevert()` ->
* `testDepositTokenCorrectly()` ->
* `testUserCanNotDepositMoreThanOnce()` ->
* `testCanOnlyWithdraw0WithoutDeposit()` ->
* `testWithdrawTokensCorrectly()` ->
* `testCanNotClaimIfNotStaking()` ->
* `testCanNotClaimIfNotElapsedTime()` ->
* `testShouldRevertIfNotEth()` ->
* `testCanClaimRewardsCorrectly()` ->

CODE IS LAW!

