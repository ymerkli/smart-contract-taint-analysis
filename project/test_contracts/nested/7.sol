pragma solidity ^0.5.0;

// Tainted
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

  function foo2(uint256 x, uint256 y) public returns(uint256) {
    uint256 g = x;
    uint256 h = y;
    return foo(h, g);
  }

  function kill() public payable {
    uint256 a = msg.value;
    uint256 b = 15;

    b = foo2(b, a);
    a = foo2(a, b);

    require(msg.sender == address(b));
    selfdestruct(owner);
  }
}
