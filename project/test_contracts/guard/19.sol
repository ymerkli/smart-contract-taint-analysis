pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address payable owner;
  int z;
  bool guard;

  function bar(int x) public {
    z = x;
    require(msg.sender == owner);
  }

  function foo(int b) public {
    z = b + b;
    guard = (msg.sender != owner || z < 10);
    if(guard) {
      // ...
    }
    else {
      // ...
    }
    selfdestruct(owner);
  }
}
