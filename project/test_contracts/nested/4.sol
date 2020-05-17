pragma solidity ^0.5.0;

// Safe
contract Contract {
  address payable owner;

  function foo(uint256 x, uint256 y) public returns(uint256) {
    uint256 z = y;
    if(z == 1) {
      z = 1;
    } else {
      z = 1;
    }
    return 2 * x * z;
  }

  function kill() public payable {
    uint256 a = msg.value;
    uint256 b = 15;

    a = foo(b, a);
    b = foo(a, b);

    require(msg.sender == address(b));
    selfdestruct(owner);
  }
}
