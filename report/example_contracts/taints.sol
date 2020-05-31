contract Contract {
  address payable owner;
  function foo(uint256 x) public returns(uint256) {
    return 1;                           // safe return value
  }
  function kill() public payable {
    uint256 a = msg.value;              // a is hard tainted
    a = foo(msg.value);                 // a is no longer tainted
    require(msg.sender == address(a));  // safe guard since a is not tainted
    selfdestruct(owner);                // safe
  }
}
