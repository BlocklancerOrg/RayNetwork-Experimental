pragma solidity ^0.4.14;

contract Handler{
    event test(
        bytes4 a
    );
    address owner;
    
    address requestHandler;
    address profile;
    
    function Handler(address sender) public{
        owner = sender;
        requestHandler = msg.sender;
    }
    
    function invoke(address toCall, string func, string message, string proof) public{
        //require(msg.sender == requestHandler);

        bool ret = toCall.call(bytes4(keccak256(func)),5, message, proof);
    }
    function get(string func) constant returns(bytes4){
        return bytes4(keccak256(func));
    }
}