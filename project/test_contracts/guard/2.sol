pragma solidity ^0.5.0;

// Safe
contract Contract {
  address payable owner;

  function kill(uint x) public payable {
    if(x < 5) {
      if(msg.sender == owner) {
        // ...
      } else {
        selfdestruct(owner);
      }
    }
  }
}
