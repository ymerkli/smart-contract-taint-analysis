pragma solidity ^0.5.0;

// the contract is vulnerable
// the output of your analyzer should be Tainted
contract Contract {
  address owner;
  function foo() public {
    address x = address(0x0);
    if(msg.sender == address(0xDEAD)) {
      x = address(0xBEEF);
    }
    require(x == owner);      // not a guard
    selfdestruct(msg.sender); // vulnerable
  }
}
