pragma solidity ^0.5.0;

contract A {
    uint state = 0;

    function test1(uint i) public returns (uint) {
        uint a = 5;
        uint p = test3(a);

        return p;
    }

//    function test2(uint i) public returns (uint) {
//        uint q =test3(i);
//        return q;
//    }
//
    function test3(uint i) public returns (uint) {
        return i;
    }
}