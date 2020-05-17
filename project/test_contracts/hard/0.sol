pragma solidity ^0.5.0;

// Safe
contract Contract {
  address payable owner;

  function mixParameters12(uint a, uint b, uint c) public returns (uint) {
      return a + b;
  }

  function mixParameters23(uint a, uint b, uint c) public returns (uint) {
      return b + c;
  }

  function mixItUpSafe() public payable returns(uint) {
      uint tmp1 = mixParameters12(msg.value, msg.value, msg.value);
      uint tmp2 = mixParameters23(msg.value, msg.value, msg.value);

      uint tmp3 = mixParameters23(msg.value, 2, 3);
      uint tmp4 = mixParameters12(tmp3, 4, msg.value);
      uint tmp5 = mixParameters12(tmp3, tmp4, msg.value);

      return tmp5;
  }

  function kill() public {
    uint mixed = mixItUpSafe();
    require(msg.sender == address(mixed));
    selfdestruct(owner);
  }
}
