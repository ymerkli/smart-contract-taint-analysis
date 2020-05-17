pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address payable owner;

  function mixParameters12(uint a, uint b, uint c) public returns (uint) {
      return a + b;
  }

  function mixParameters23(uint a, uint b, uint c) public returns (uint) {
      return b + c;
  }

  function mixItUpTainted() public payable returns(uint) {
      uint tmp1 = mixParameters12(msg.value, msg.value, msg.value);
      uint tmp2 = mixParameters23(msg.value, msg.value, msg.value);

      uint tmp3 = mixParameters12(msg.value, 2, 3);
      uint tmp4 = mixParameters12(tmp3, 4, msg.value);
      uint tmp5 = mixParameters12(tmp3, tmp4, msg.value);

      return tmp5;
  }

  function kill() public {
    uint mixed = mixItUpTainted();
    require(msg.sender == address(mixed));
    selfdestruct(owner);
  }
}
