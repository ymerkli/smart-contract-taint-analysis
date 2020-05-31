pragma solidity ^0.5.0;

// Safe
contract Contract {
  address owner;
  bool guard;

  function makeGuard() public {
    guard = msg.sender == owner;
  }

  function bar() public {
    makeGuard();
    require(guard);
    selfdestruct(msg.sender);
  }
}
