// SPDX-License-Identifier: UNKNOWN 
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/SLP.sol";

contract SLPTest is Test {
    SLP public slp;

    function setUp() public {
        slp = new SLP();
    }

    function testDeposit() public {
        address anvilTestAddress9 = 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720;
        vm.startPrank(anvilTestAddress9);
        uint256 newBalance = 100 ether;
        vm.deal(anvilTestAddress9, newBalance);
        slp.deposit{value: 50 ether}();

        assertEq(slp.ethBalance(address(anvilTestAddress9)), 50 ether);
    }

    // in this sample code for interview i just write test for happy path but in real world we should write test for all possible path
    // for example we should write test for when the user want to borrow more than the borrowing limit 
    // and check them with using the fuzzing test and testFail options in the forge-std
    function testBorrow() public {
        address anvilTestAddress9 = 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720;
        vm.startPrank(anvilTestAddress9);
        uint256 newBalance = 100 ether;
        vm.deal(anvilTestAddress9, newBalance);
        slp.deposit{value: 50 ether}();
        
        // Borrowing MTK token (this ether keyword is used to decimal conversion)
        slp.borrow(25 ether);

        // check the MTK token balance (this ether keyword is used to decimal conversion)
        assertEq(slp.balanceOf(anvilTestAddress9), 25 ether);

        assertEq(slp.getRequiredEthCollateral(anvilTestAddress9), 55 ether);
    }

    function testRepay() public {
        address anvilTestAddress9 = 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720;
        vm.startPrank(anvilTestAddress9);
        uint256 newBalance = 100 ether;
        vm.deal(anvilTestAddress9, newBalance);
        slp.deposit{value: 50 ether}();
        
        // Borrowing MTK token (this ether keyword is used to decimal conversion)
        slp.borrow(25 ether);

        // Repay MTK token (this ether keyword is used to decimal conversion)
        slp.repay(25 ether);

        // check the MTK token balance (this ether keyword is used to decimal conversion)
        assertEq(slp.balanceOf(anvilTestAddress9), 0 ether);

        assertEq(slp.getRequiredEthCollateral(anvilTestAddress9), 0 ether);
    }

    function testWithdraw() public {
        address anvilTestAddress9 = 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720;
        vm.startPrank(anvilTestAddress9);
        uint256 newBalance = 100 ether;
        vm.deal(anvilTestAddress9, newBalance);
        slp.deposit{value: 50 ether}();
        
        // Borrowing MTK token (this ether keyword is used to decimal conversion)
        slp.borrow(25 ether);

        // Repay MTK token (this ether keyword is used to decimal conversion)
        slp.repay(25 ether);

        // Withdraw ETH (this ether keyword is used to decimal conversion)
        slp.withdraw(45 ether);

        assertEq(slp.ethBalance(anvilTestAddress9), 0 ether);
    }


}

