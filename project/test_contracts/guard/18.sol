pragma solidity ^0.5.0;

// Tainted
contract Contract {
  int y;
  bool guard;
  address payable owner;
  address payable admin;

  function foo(int x) public {
    y = x + x;
  }

  function bar() public {
    guard = (msg.sender == owner || y < 10);
    if (guard) {
      selfdestruct(owner);
    } else {
      selfdestruct(admin);
    }
  }
}
