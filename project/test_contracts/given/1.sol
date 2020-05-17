pragma solidity ^0.5.0;

// the contract is vulnerable
// the output of your analyzer should be Tainted
contract Contract {
  address owner;
  function foo(address x) public {
    require(x == owner);        // not a guard
    selfdestruct(msg.sender);   // vulnerable 
  }
}
