pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address payable owner;

  function maybeSanitize(int x) public {
    if(x < 5) {
      return;
    }
    require(msg.sender == owner);
    return;
  }

  function foo(int x) public {
    maybeSanitize(x);
    selfdestruct(msg.sender);
  }
}
