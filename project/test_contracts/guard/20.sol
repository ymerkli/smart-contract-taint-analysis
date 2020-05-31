pragma solidity ^0.5.0;

// Safe
contract Contract {
  address owner;

  function bar() public {
    bool guard = msg.sender == owner;
    require(guard == true);
    selfdestruct(msg.sender);
  }
}
