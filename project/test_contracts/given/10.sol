pragma solidity ^0.5.0;

// the contract is vulnerable
// the output of your analyzer should be Tainted
contract Contract {
  address owner;
  int y;
  function foo(int x) public {
    y = y + x;
    y = y - x;  // y is untrusted
  }
  function bar() public {
    require(msg.sender == owner && y == 10);
    selfdestruct(msg.sender);
  }
}
