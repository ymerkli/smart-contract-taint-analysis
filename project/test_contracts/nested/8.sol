pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address payable owner;

  function identity1(uint i) public returns(uint) {
    return identity2(i);
  }

  function identity2(uint i) public returns(uint) {
    return identity3(i);
  }

  function identity3(uint i) public returns(uint) {
    return identity4(i);
  }

  function identity4(uint i) public returns(uint) {
    return 0;
  }

  function kill(uint x) public {
    require(msg.sender == address(identity1(x)));
    selfdestruct(owner);
  }
}
