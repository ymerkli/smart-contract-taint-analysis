pragma solidity ^0.5.0;

// the contract is vulnerable
// the output of your analyzer should be Tainted
contract Contract {
  address payable owner;
  int z;

  function bar(int x) public {
    z = x;
    require(msg.sender == owner); // guard
  }

  function foo(int b) public {
    z = b + b; // z becomes unsafe
    bool a = (msg.sender != owner || z < 10);
    if(a) { // not a guard
    }
    else { // not a guard
    }
    selfdestruct(owner); // vulnerable
  }
}