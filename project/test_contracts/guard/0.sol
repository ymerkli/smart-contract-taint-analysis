pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address payable owner;

  function kill(int x) public {
    if(x < 5) {
      require(msg.sender == owner);
    } else {
      selfdestruct(owner);
    }
  }
}
