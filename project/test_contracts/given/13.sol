pragma solidity ^0.5.0;

// the contract is vulnerable
// the output of your analyzer should be Tainted
contract Contract {
  address payable owner;
  function foo(int x) public {
    if(x < 5) {                 // not guard
      if(msg.sender == owner) { // guard
        // ...
      } else {                  // guard
        // ...
      }
    }
    selfdestruct(owner);   // unsafe
  }
}
