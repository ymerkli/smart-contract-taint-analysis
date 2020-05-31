pragma solidity ^0.5.0;

// the contract is safe 
// the output of your analyzer should be Safe
contract Contract {
  address x;
  address y;
  address payable owner;

  function set_y() public {
    y = msg.sender;
  }

  function foo() public {
    require(msg.sender == owner); // guard
    x = y;
    selfdestruct(owner); // safe
  }

  function bar() public {
    require(msg.sender == x); // guard
    selfdestruct(owner); // safe
  }
}