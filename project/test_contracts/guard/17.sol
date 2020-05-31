pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address owner;
  bool guard;

  function taintOwner() public {
    owner = msg.sender;
  }

  function makeGuard() public {
    guard = msg.sender == owner;
  }

  function bar() public {
    makeGuard();
    require(guard);
    selfdestruct(msg.sender);
  }
}
