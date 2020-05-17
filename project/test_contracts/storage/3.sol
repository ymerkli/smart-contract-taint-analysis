pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address payable user;
  address payable owner;

  function taintUser() public {
    user = msg.sender;
  }

  function kill(int x) public {
    if(x < 5) {
      taintUser();
      owner = user;
    }
    require(msg.sender == owner);
    selfdestruct(owner);
  }
}
