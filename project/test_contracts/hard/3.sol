pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address payable owner;

  function swapAllAndMix23(uint a, uint b, uint c) public returns (uint, uint, uint) {
    uint mixed = mixParameters(b, c);
    uint a1;
    uint b1;

    swapParameters(a, b);
    swapParameters(b, c);
    swapParameters(a, c);
    mixParameters(a, c);
    mixParameters(a, b);

    (b1, a1) = swapParameters(mixed, a);

    return (c, a1, b1);
  }

  function mixParameters(uint a, uint b) public returns (uint) {
    return a * b;
  }

  function swapParameters(uint a, uint b) public returns (uint, uint) {
    uint a1;
    uint b1;

    a1 = b + 5;
    b1 = a + 5;

    return (a1 - 5, b1 - 5);
  }

  function kill() public payable {
    swapAllAndMix23(msg.value, msg.value, msg.value);

    (uint a, uint b, uint c) = swapAllAndMix23(4, msg.value, 5);

    require(msg.sender == address(b));
    selfdestruct(owner);
  }
}
