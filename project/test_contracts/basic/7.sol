pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address payable owner;

  function kill() public {
    address x = msg.sender;
    address y = address(0x01);
    address z = address(0x02);
    address tmp;

    tmp = x;
    x = y;
    y = z;
    z = tmp;

    tmp = x;
    x = y;
    y = z;
    z = tmp;

    require(msg.sender == y);
    selfdestruct(owner);
  }
}
