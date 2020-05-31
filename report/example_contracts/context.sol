contract Contract {
  address owner;
  function check(address x) public returns(bool) {
    return (msg.sender == x);      // x can be safe or tainted -> dep. on context
  }
  function foo() public {
    require(check(owner));         // owner is safe (constant)
    selfdestruct(msg.sender);      // safe
  }
  function bar(address x) public {
    require(check(x));             // x is tainted (function argument)
    selfdestruct(msg.sender);      // tainted
  }
}
