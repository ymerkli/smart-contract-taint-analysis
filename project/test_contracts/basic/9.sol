pragma solidity ^0.5.0;

// Safe
contract Contract {
  address payable owner;

  function foo(uint256 x) public returns(uint256) {
    return 1;
  }

  function kill() public payable {
    uint256 a = msg.value;

    if(msg.value == 1) {
      a = foo(msg.value);
    } else {
      a = foo(msg.value);
    }
    require(msg.sender == address(a));
    selfdestruct(owner);
  }
}
