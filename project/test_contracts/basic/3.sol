pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address payable owner;

  function unsafeOwnerChange(uint256 x) public {
    uint256 a = uint(owner);
    a = a + x;
    owner = address(a);
  }

  function kill(uint256 x) public {
    unsafeOwnerChange(x);
    require(msg.sender == owner);
    selfdestruct(owner);
  }
}
