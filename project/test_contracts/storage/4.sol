pragma solidity ^0.5.0;

// Safe
contract Contract {
  address payable owner;

  function taintOwner() public {
    owner = msg.sender;
  }

  function untaintOwner() public {
    owner = address(0x01);
  }

  function kill() public {
    taintOwner();
    untaintOwner();
    require(msg.sender == owner);
    selfdestruct(owner);
  }
}
