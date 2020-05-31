pragma solidity ^0.5.0;

// the contract is safe
// the output of your analyzer should be Safe
contract Contract {
  address payable owner;
  address payable admin;
  function foo() public {
    if(msg.sender == owner) { // guard
      selfdestruct(owner);    // safe
    } else {                  // guard
      selfdestruct(admin);    // safe
    }
  }
  function bar() public {
    if(msg.sender == owner) { // guard
      // ...
    } else {                  // guard
      // ...
    }
    selfdestruct(admin);      // safe
  }
}
