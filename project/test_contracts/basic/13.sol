pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address payable owner;

  function kill(address x) public {
    selfdestruct(owner);
    require(msg.sender > x);
  }
}
