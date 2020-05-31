pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address owner;

  function bar(bool x) public {
    bool guard = msg.sender == owner;
    require(guard == x);
    selfdestruct(msg.sender);
  }
}
