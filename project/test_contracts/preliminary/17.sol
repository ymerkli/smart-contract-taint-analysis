pragma solidity ^0.5.0;

// the contract is vulnerable
// the output of your analyzer should be Tainted
contract Contract {
  int y;
  address payable owner;
  address payable admin;

  function foo(int x) public {
    y = x + x;  // y becomes untrusted
  }

  function bar() public {
    bool b = (msg.sender == owner || y < 10);
    if (b) { // not a guard
      selfdestruct(owner);  // vulnerable
    } else { // not a guard
      selfdestruct(admin);  // vulnerable
    }
  }
}
