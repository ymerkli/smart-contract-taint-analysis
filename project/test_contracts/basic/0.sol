pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address payable owner;

  function kill(address x) public {
    require(msg.sender > x);
    selfdestruct(owner);
  }
}
