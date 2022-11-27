// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/1 - Reentrancy.sol";

contract CounterTest is Test {
    ReentrancyVuln public vulnContract;
    ExploitReentrancy public exploiter;

    function setUp() public {        
        vulnContract = new ReentrancyVuln();
        exploiter = new ExploitReentrancy();

        vm.deal(address(0x7), 1 ether);
        vm.prank(address(0x7));
        vulnContract.giveEth{value: 1 ether}();

        vm.deal(address(exploiter), 1 ether);
        vm.prank(address(exploiter));
        vulnContract.giveEth{value: 1 ether}();        

    }

    function testExploit() public {
        console.log("Address of exploiter", address(exploiter));
        exploiter.withdrawEthFromVulnContract(address(vulnContract));
        console.log(address(exploiter).balance);
    }
}
