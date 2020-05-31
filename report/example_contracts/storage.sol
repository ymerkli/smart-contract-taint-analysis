contract Contract {
  address payable user; address payable owner;
  function taintUser() public {
    user = msg.sender;           // user field gets hard tainted
  }
  function kill(int x) public {  // user field is weak tainted at start of kill
    owner = user;                // owner field gets weak tainted by user field
    address a = owner;           // a gets weak tainted by owner
    require(msg.sender == a);    // a is weak tainted
    selfdestruct(owner);         // tainted
  }
}
