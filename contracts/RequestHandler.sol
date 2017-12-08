pragma solidity ^0.4.14;

import "Handler.sol";

contract RequestHandler{
    
    address master; 
    address public rayNetwork;
    
    mapping(address => address) delegates;
    
    function RequestHandler() public{
        master = msg.sender;
        
        rayNetwork = msg.sender;
    }
    
    function setRayNetwork(address ray) public{
        require(msg.sender == master);
        
        rayNetwork = ray;
    }
    
    function getFunctionHash(string funcStr) pure public returns (bytes4){
        return bytes4(keccak256(funcStr));
    }
    
    function getOrCreateDelegate(address sender) public returns(address){
        if(delegates[sender] == 0){
            delegates[sender] = (new Handler(sender));
        }
        return delegates[sender];
    }
    
    function invoke(address sender, address toCall, string funcStr) public{
        require(msg.sender == rayNetwork);
        
        Handler(getOrCreateDelegate(sender)).invoke(toCall, funcStr);
    }
    
    function getDelegate(address who) constant public returns (address){
        return delegates[who];
    }
    
}