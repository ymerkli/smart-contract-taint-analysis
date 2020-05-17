pragma solidity ^0.5.0;

// Tainted
contract TestContract {
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

  function swapAllAndMix23_1(uint a, uint b, uint c) public returns (uint, uint, uint) {
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

  function swapAllAndMix23_2(uint a, uint b, uint c) public returns (uint, uint, uint) {
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

  function swapAllAndMix23_3(uint a, uint b, uint c) public returns (uint, uint, uint) {
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

  function mixParameters_1(uint a, uint b) public returns (uint) {
    return a * b;
  }

  function swapParameters_1(uint a, uint b) public returns (uint, uint) {
    uint a1;
    uint b1;

    a1 = b + 5;
    b1 = a + 5;

    return (a1 - 5, b1 - 5);
  }

  function mixParameters_2(uint a, uint b) public returns (uint) {
    return a * b;
  }

  function swapParameters_2(uint a, uint b) public returns (uint, uint) {
    uint a1;
    uint b1;

    a1 = b + 5;
    b1 = a + 5;

    return (a1 - 5, b1 - 5);
  }

  function mixParameters_3(uint a, uint b) public returns (uint) {
    return a * b;
  }

  function swapParameters_3(uint a, uint b) public returns (uint, uint) {
    uint a1;
    uint b1;

    a1 = b + 5;
    b1 = a + 5;

    return (a1 - 5, b1 - 5);
  }

  function mixParameters_4(uint a, uint b) public returns (uint) {
    return a * b;
  }

  function swapParameters_4(uint a, uint b) public returns (uint, uint) {
    uint a1;
    uint b1;

    a1 = b + 5;
    b1 = a + 5;

    return (a1 - 5, b1 - 5);
  }

  function kill() public payable {
    swapAllAndMix23(msg.value, msg.value, msg.value);

    (uint a, uint b, uint c) = swapAllAndMix23(4, msg.value, 5);

    require(msg.sender == address(a));
    selfdestruct(owner);
  }

  function kill_1() public payable {
    swapAllAndMix23(msg.value, msg.value, msg.value);

    (uint a, uint b, uint c) = swapAllAndMix23(4, msg.value, 5);

    require(msg.sender == address(a));
    selfdestruct(owner);
  }

  function kill_2() public payable {
    swapAllAndMix23(msg.value, msg.value, msg.value);

    (uint a, uint b, uint c) = swapAllAndMix23(4, msg.value, 5);

    require(msg.sender == address(b));
    selfdestruct(owner);
  }
}
