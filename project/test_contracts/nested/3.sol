pragma solidity ^0.5.0;

// Safe
contract Contract {
  address payable owner;

  function foo(uint256 x) public returns(uint256) {
    return x;
  }

  function kill() public payable {
    uint256 a = msg.value;

    a = foo(a) * foo(a);
    uint256 b = foo(a) + foo(a);
    b = 1;
    b = foo(b);

    require(msg.sender == address(b));
    selfdestruct(owner);
  }
}
