pragma solidity ^0.5.0;

// Tainted
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
    require(check(b));
    a = msg.sender;
  }

  function bar(address x) public {
    bool check_1 = check(x);
    bool check_2 = check(a);
    require(check_1 || check_2);
    selfdestruct(msg.sender);
  }
}
