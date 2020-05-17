pragma solidity ^0.5.0;

// Safe
contract Contract {
  address payable owner;

  function kill() public payable {
    uint a = msg.value;
    uint b = a + 5;
    uint c = 0;

    uint d = msg.value;

    d += a;
    d = 5;

    uint e = msg.value;
    uint f = a + 5;
    uint g = 0;

    uint h = msg.value;

    h += e;
    h = 5;

    uint i = msg.value;
    uint j = a + 5;
    uint k = 0;

    uint l = msg.value;

    d += a;
    d = 5;

    uint m = msg.value;
    uint n = a + 5;
    uint o = 0;

    uint p = msg.value;

    d += a;
    d = 5;

    uint q = msg.value;
    uint r = a + 5;
    uint s = 0;

    uint t = msg.value;

    d += a;
    d = 5;
    uint u = msg.value;
    uint v = a + 5;
    uint w = 0;

    uint x = msg.value;

    d += a;
    d = 5;

    uint y = msg.value;
    uint z = a + 5;
    uint A = 0;

    uint B = msg.value;

    d += a;
    d = 5;

    require(msg.sender == address(d));
    selfdestruct(owner);
  }
}
