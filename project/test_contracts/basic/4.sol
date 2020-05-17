pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address payable owner;

  function multipleReturnValues() public returns(address, address) {
    return (msg.sender, address(0x01));
  }

  function kill() public {
    address tainted_return;
    address safe_return;
    (tainted_return, safe_return) = multipleReturnValues();
    require(msg.sender == tainted_return);
    selfdestruct(owner);
  }
}
