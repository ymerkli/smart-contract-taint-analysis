pragma solidity ^0.5.0;

// Tainted
contract Contract {
  function check(address x) public returns(bool) {
    return (msg.sender == x);
  }

  function foo(address z) public {
    require(check(z));
    selfdestruct(msg.sender);
  }
}
