contract Contract {
  address payable owner;
  function maybeSanitize(int x) public {
    if(x < 5) {
      return;                      // evade guard by returning early
    }
    require(msg.sender == owner);  // guard
  }
  function foo(int x) public {
    maybeSanitize(x);              // guard, but can be evaded
    selfdestruct(msg.sender);      // tainted
  }
}
