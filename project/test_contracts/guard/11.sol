pragma solidity ^0.5.0;

// Safe
contract Contract {
  address owner;
  bool guard;

  function foo() public {
    return;
  }

  function bar() public {
    guard = msg.sender == owner;
    foo();
    require(guard);
    selfdestruct(msg.sender);
  }
}
