pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address payable user1;
  address payable user2;
  address payable user3;
  address payable user4;
  address payable owner;

  function registerUser1() public {
    user1 = msg.sender;
  }

  function registerUser2() public {
    user2 = user1;
  }

  function registerUser3() public {
    user3 = user2;
  }

  function registerUser4() public {
    user4 = user3;
  }

  function kill() public {
    require(msg.sender == user4);
    selfdestruct(owner);
  }
}
