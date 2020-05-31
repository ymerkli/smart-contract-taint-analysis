pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address payable owner;
  int x;
  int y;

  function taintX(int a) public {
    x = a;
  }

  function kill() public payable {
    y = x;
    int z = y;
    require(msg.sender == owner || z < 10);
    selfdestruct(owner);
  }
}
