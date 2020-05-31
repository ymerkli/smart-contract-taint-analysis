pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address owner;
  bool guard;

  function taintOwner() public {
    owner = msg.sender;
  }

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
