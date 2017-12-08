pragma solidity ^0.4.14;

contract Handler{
    address owner;
    
    address requestHandler;
    address profile;
    
    function Handler(address sender) public{
        owner = sender;
        requestHandler =msg.sender;
    }
    
    function invoke(address toCall, string func) public{
        require(msg.sender == requestHandler);
        
        bool ret = toCall.call(bytes4(keccak256(func)),5);
    }
}
