pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address payable owner;

  function taintOwner() public {
    owner = msg.sender;
  }

  function untaintOwner() public {
    owner = address(0x01);
  }

  function kill(int x) public {
    if(x < 5) {
      taintOwner();
    }
    require(msg.sender == owner);
    selfdestruct(owner);
  }
}
