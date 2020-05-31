pragma solidity ^0.5.0;

// Tainted
contract Contract {

  function bar(address x) public {
    bool guard = msg.sender == x;
    require(guard == true);
    selfdestruct(msg.sender);
  }
}
