pragma solidity ^0.5.0;

// the contract is safe
// the output of your analyzer should be Safe
contract Contract {
  address owner;
  address a;

  function set_a1(address x) public {
    set_a2(x);
  }

  function set_a2(address x) public {
    a = x;
  }

  function foo(address x) public {
    set_a1(owner);
    set_a1(x);
    set_a1(owner);
    require(msg.sender == a); // guard
    selfdestruct(msg.sender); // safe
  }
}
