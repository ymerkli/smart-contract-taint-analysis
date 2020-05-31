pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address owner;
  bool guard;

  function makeGuard() public {
    guard = msg.sender == owner;
  }

  function unmakeGuard() public {
    guard = true;
  }

  function bar() public {
    makeGuard();
    unmakeGuard();
    require(guard);
    selfdestruct(msg.sender);
  }
}
