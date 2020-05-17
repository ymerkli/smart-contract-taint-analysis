pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address payable owner;

  function kill() public payable {
    uint256 a = 0;
    a = a + msg.value;

    require(msg.sender == address(a));
    selfdestruct(owner);
  }
}
