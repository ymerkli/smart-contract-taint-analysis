pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address owner;
  bool guard;

  function bar() public {
    guard = msg.sender == owner;
    guard = true;
    require(guard);
    selfdestruct(msg.sender);
  }
}
