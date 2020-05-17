pragma solidity ^0.5.0;

// the contract is vulnerable
// the output of your analyzer should be Tainted
contract Contract {
  address owner;
  address x;
  function foo1(address y) public {
    x = y;
  }
  function foo2() public {
    require(msg.sender == owner); // not a guard
    owner = x;
  }
  function foo3() public {
    require(msg.sender == owner); // not a guard
    selfdestruct(msg.sender);     // vulnerable
  }
}
