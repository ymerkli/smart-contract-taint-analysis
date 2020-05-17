pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address payable owner;

  function maybeSanitize(int x) public {
    if(x < 10) {
      if(x < 5) {
        //...
      }
      require(msg.sender == owner);
      return;
    }
    return;
  }

  function foo(int x) public {
    maybeSanitize(x);
    selfdestruct(msg.sender);
  }
}
