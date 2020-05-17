pragma solidity ^0.5.0;

// the contract is vulnerable
// the output of your analyzer should be Tainted
contract Contract {
  address payable user;
  address payable owner;

  function registerUser() public {
    user = msg.sender;
  }

  function kill() public {
    require(msg.sender == user);
    selfdestruct(owner);
  }
}
