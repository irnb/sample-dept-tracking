// SPDX-License-Identifier: UNKNOWN
pragma solidity 0.8.20;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol";


/// @title Simple Lending Protocol
/// @author IRNB
/// @dev this is simple liquidity pool for interview
contract SLP is ERC20, Ownable2Step {
    /* Contract Architecture
    this is simple lending protocol for interview

    the user can Borrow the MTK token by depositing ETH as collateral

    Accounting Model:
    - ETH is the only collateral
    - Fixed interest rate
    - Borrowing limit rate

    by using the deposit function, the user can deposit ETH to the contract
    by using the borrow function, the user can borrow MTK token the maximum amount of borrowing is calculated by this formula:
        borrowingAmount = (ethBalance * borrowingLimitRate / 100) - currentBorrowing
        (the balance of MTK token is the amount of borrowing of the user in my implementation)
        (in other words this token is dept tracker)
    by using the repay function, the user can repay MTK token and the interest in the form of ether is reduced 
    from the ETH balance of the user

    by using the withdraw function, the user can withdraw ETH from the contract
        the user can withdraw ETH only if the ETH balance is greater than the required collateral
        the required collateral is calculated by this formula:
            requiredCollateral = (currentBorrowing + interest) * 100 / borrowingLimitRate

    the interest is calculated by this formula:
        interest = currentBorrowing * fixedInterestRate / 100

    *** 
        The algorithm of the contract is very simple and it is not suitable for real world usage and 
        I try my best in 90 minutes to implement it 
    ***
    
    */


    //State variables
    uint256 fixedInterestRate = 10;
    uint256 borrowingLimitRate = 50;
    mapping(address => uint256) public ethBalance;


    //Events
    event Deposit(address indexed _from, uint256 _amount);
    event Borrow(address indexed _from, uint256 _amount);
    event Repay(address indexed _from, uint256 _amount);
    event Withdraw(address indexed _from, uint256 _amount);

    // Constructor
    constructor () ERC20("MockToken", "MTK") Ownable(msg.sender){
        
    }

    // External functions
    function deposit() external payable {
        ethBalance[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function borrow (uint256 _amount) external {
        uint256 currentBorrowing = getBorrowingAmount(msg.sender);
        uint256 borrowingLimit = getBorrowingLimit(msg.sender);

        require(currentBorrowing + _amount <= borrowingLimit, "Borrowing limit reached");

        _mint(msg.sender, _amount);
        emit Borrow(msg.sender, _amount);
    }

    function repay (uint256 _amount) external {
        _burn(msg.sender, _amount);

        uint256 releasedEth = ((_amount * 100) / borrowingLimitRate);
        uint256 calculatedInterest = (releasedEth * fixedInterestRate) / 100;

        ethBalance[msg.sender] -= calculatedInterest;

        emit Repay(msg.sender, _amount);

    }

    function withdraw (uint256 _amount) external {
        uint256 currentEthBalance = ethBalance[msg.sender];
        uint256 requiredEthCollateral = getRequiredEthCollateral(msg.sender);

        require(currentEthBalance - _amount >= requiredEthCollateral, "Not enough collateral");

        ethBalance[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
        emit Withdraw(msg.sender, _amount);
    }

    function changeFixedInterestRate (uint256 _newFixedInterestRate) external onlyOwner {
        fixedInterestRate = _newFixedInterestRate;
    }

    function changeBorrowingLimitRate (uint256 _newBorrowingLimitRate) external onlyOwner {
        borrowingLimitRate = _newBorrowingLimitRate;
    }

    // Public functions
    function getEthBalance(address _address) public view returns (uint256) {
        return ethBalance[_address];
    }

    function getBorrowingLimit(address _address) public view returns (uint256) {
        uint256 currentEthBalance = ethBalance[_address];
        return (currentEthBalance * borrowingLimitRate) / 100;
    }

    function getBorrowingAmount(address _address) public view returns (uint256) {
        return balanceOf(_address);
    }

    function getUnpaidAmount(address _address) public view returns (uint256) {
        uint256 currentBorrowing = balanceOf(_address);
        uint256 interest = (currentBorrowing * fixedInterestRate) / 100;
        return currentBorrowing + interest;
    }

    function getRequiredEthCollateral(address _address) public view returns (uint256) {
        uint256 currentUnpaidAmount = getUnpaidAmount(_address);
        return (currentUnpaidAmount * 100) / borrowingLimitRate;
    }

}
