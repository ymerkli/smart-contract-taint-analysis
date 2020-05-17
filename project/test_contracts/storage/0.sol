pragma solidity ^0.5.0;

// Safe
contract Contract {
  address payable owner;

  function kill() public {
    owner = msg.sender;
    owner = address(0x01);
    require(msg.sender == owner);
    selfdestruct(owner);
  }
}
