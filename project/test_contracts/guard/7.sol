pragma solidity ^0.5.0;

// Safe
contract Contract {
  address owner;
  bool guard;

  function bar() public {
    guard = msg.sender == owner;
    require(guard);
    selfdestruct(msg.sender);
  }
}
