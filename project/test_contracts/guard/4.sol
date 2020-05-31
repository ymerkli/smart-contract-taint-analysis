pragma solidity ^0.5.0;

// Safe
contract Contract {
  address a;
  address b;

  function bar(address x) public {
    require(msg.sender == a || msg.sender == b);
    selfdestruct(msg.sender);
  }
}
