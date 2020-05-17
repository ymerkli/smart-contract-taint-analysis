pragma solidity ^0.5.0;

// Safe
contract Contract {
  address payable owner;
  address payable user;

  function maybeSanitize(int x) public {
    if(x < 5) {
      return;
    }
    require(msg.sender == owner);
    return;
  }

  function foo(int x) public {
    maybeSanitize(x);
    user=address(x);
    if(x == 3) {
      // ...
    }
    require(msg.sender == owner);
    selfdestruct(msg.sender);
  }

  function bar() public {
    require(msg.sender == user);
    selfdestruct(msg.sender);
  }
}
