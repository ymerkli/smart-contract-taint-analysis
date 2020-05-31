pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address owner;
  bool guard;

  function taintOwner() public {
    owner = msg.sender;
  }

  function bar() public {
    guard = msg.sender == owner;
    if(true) {
      // ...
    }
    require(guard);
    selfdestruct(msg.sender);
  }
}
