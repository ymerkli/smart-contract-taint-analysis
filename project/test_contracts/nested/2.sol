pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address payable owner;

  function maybeTaint(int x) public returns(address) {
    if(x < 5) {
      return address(0x01);
    }
    return msg.sender;
  }

  function foo(int x) public {
    address y = maybeTaint(x);
    require(msg.sender == y);
    selfdestruct(owner);
  }
}
