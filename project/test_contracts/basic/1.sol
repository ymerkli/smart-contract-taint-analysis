pragma solidity ^0.5.0;

// Safe
contract Contract {
  address payable owner;

  function kill() public {
    require(msg.sender == owner);
    selfdestruct(owner);
  }
}
