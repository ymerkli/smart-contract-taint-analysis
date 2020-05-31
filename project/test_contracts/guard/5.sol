pragma solidity ^0.5.0;

// Safe
contract Contract {
  address a;
  address b;
  address c;

  function bar(address x) public {
    bool check_1 = msg.sender == a;
    bool check_2 = msg.sender == b;
    bool check_3 = check_2 || msg.sender == c;
    require(check_1 || check_3);
    selfdestruct(msg.sender);
  }
}
