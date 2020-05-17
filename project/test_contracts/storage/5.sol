pragma solidity ^0.5.0;

// Safe
contract Contract {
  address payable owner;
  uint storedVar;

  function load() public returns(uint) {
    return storedVar;
  }

  function loadAndKill() public {
      require(msg.sender == address(load()));
      selfdestruct(owner);
  }

  function kill() public payable {
    if(msg.value == 5) {
      storedVar = 5;
    } else {
      storedVar = 5;
    }
    loadAndKill();
  }
}
