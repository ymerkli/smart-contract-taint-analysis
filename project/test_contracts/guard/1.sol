pragma solidity ^0.5.0;

// Safe
contract Contract {
  address payable owner;

  function kill() public payable {
    uint tmp = 1;
    if(msg.value > 5) {
      tmp = tmp + 2;
    }
    require(msg.sender == address(tmp));
    selfdestruct(owner);
  }
}
