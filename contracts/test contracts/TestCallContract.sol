pragma solidity ^0.4.14;

contract callMe{
    uint public called = 0;
    
    function f(uint b){
        called+=1;
    }
}