pragma solidity ^0.5.0;

// Safe
contract Contract {
  address payable user1;
  address payable user2;
  address payable owner;

  function registerUser1() public {
    user1 = msg.sender;
    require(msg.sender == owner);
  }

  function registerUser2() public {
    user2 = user1;
  }

  function kill() public {
    require(msg.sender == user2);
    selfdestruct(owner);
  }
}
