pragma solidity ^0.5.0;

// the contract is vulnerable
// the output of your analyzer should be Tainted
contract Contract {
  address owner;
  address a;
  address b;

  function check(address x) public returns(bool) {
    return check_impl(x);
  }

  function check_impl(address x) public returns(bool) {
    return (msg.sender == x);
  }

  function set_b(address x) public {
    b = x;
  }

  function foo() public {
    require(check(b));         // not a guard
    a = msg.sender;
  }

  function bar() public {
    require(check(a));             // not a guard
    selfdestruct(msg.sender); // vulnerable
  }
}
