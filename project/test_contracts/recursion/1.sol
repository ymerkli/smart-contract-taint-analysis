pragma solidity ^0.5.0;

// Tainted
contract Contract {
  address payable owner;

  function fibonacci(uint n) public returns(uint) {
    if(n <= 1) {
      return 1;
    }
    return fibonacci(n-1) + fibonacci(n-2);
  }

  function kill(uint x) public {
    require(msg.sender == address(fibonacci(x)));
    selfdestruct(owner);
  }
}
