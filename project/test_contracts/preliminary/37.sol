pragma solidity ^0.5.0;

// the contract is vulnerable
// the output of your analyzer should be Tainted
contract Contract {
  address a;
  address b;
  address c;

  function set1(address x) public {
    set2(x);
  }

  function set2(address x) public {
    set3(x);
  }

  function set3(address x) public {
    set4(x);
  }

  function set4(address x) public {
    a = x;
    b = x;
  }

  function foo(address x) public {
    set1(x);
    require(msg.sender == a); // not a guard
    selfdestruct(msg.sender); // vulnerable
  }
}
