pragma solidity ^0.5.0;

// Safe
contract Contract {
  address payable owner;

  function taint(uint a, uint b, uint c) public returns (uint, uint) {
    return (a + b, 5);
  }

  function main() public payable {
    uint256 a = msg.value;
    uint256 b = msg.value;
    uint256 r1;
    uint256 r2;
    (r1, r2) = taint(a, 4, 6);
    b = r2;
    (r1, r2) = taint(b, b, a);

    require(msg.sender == address(r1));
    selfdestruct(owner);
  }
}
