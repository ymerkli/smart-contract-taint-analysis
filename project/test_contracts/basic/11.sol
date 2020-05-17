pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address payable owner;

  function double(uint256 x) public returns(uint256) {
    return x * 2;
  }

  function kill() public payable {
    uint256 a = msg.value;
    uint256 b = double(a);

    require(msg.sender == address(b));
    selfdestruct(owner);
  }
}
