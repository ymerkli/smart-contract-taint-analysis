pragma solidity ^0.5.0;

// Safe
contract Contract {
  address payable owner;

  function safeOwnerChange() public {
    uint256 a = uint(owner);
    a = a + 1;
    owner = address(a);
  }

  function kill() public {
    safeOwnerChange();
    require(msg.sender == owner);
    selfdestruct(owner);
  }
}
