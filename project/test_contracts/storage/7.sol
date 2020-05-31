pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address payable owner;
  int a;
  int b;
  int c;
  int d;

  function taintA(int x) public {
    a = x;
  }
  function taintB() public {
    b = a;
  }
  function taintC() public {
    c = b;
  }
  function taintD() public {
    d = c;
  }

  function kill() public payable {
    int z = d;
    require(msg.sender == owner || z < 10);
    selfdestruct(owner);
  }
}
