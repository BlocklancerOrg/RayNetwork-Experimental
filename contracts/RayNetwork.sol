pragma solidity ^0.4.14;

import "library/string.sol";
import "requestHandler.sol";
import "rayToken.sol";
import "library/stringCasting.sol";
import "library/addressCasting.sol";

contract RayNetwork{
    using strings for *;
    using stringcast for string;
    using addresscast for address;
    
    address public master;
    address public requestHandler;
    
    mapping(address => mapping(uint => bool) ) used_datetime;
    
    function RayNetwork(address req) public{
        master = msg.sender;
        
        if(req != 0x0)
            requestHandler = req;
        else
            requestHandler = new RequestHandler();
    }
    
    function setRequestHandler(address _to) public{
        require(msg.sender == master);
        requestHandler = _to;
    }
    
    function bytes32ToBytes32String (uint dat) pure private returns (bytes) {
        bytes32 data = bytes32(dat);
        bytes memory bytesString = new bytes(32);
        for (uint j=0; j<32; j++) {
            byte char = byte(bytes32(uint(data) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[j] = char;
            }
        }
        return bytesString;
    }
    
    function recover(string message, string sigs,string lenStr) pure private returns (address) {
        bytes memory sig = sigs.toBytes();

        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        bytes32 hash = keccak256(prefix,lenStr, message);    
            
        bytes32 r;
        bytes32 s;
        uint8 v;
    
        //Check the signature length
        if (sig.length != 65) {
          return (address(0));
        }
    
        // Divide the signature in r, s and v variables
        assembly {
          r := mload(add(sig, 32))
          s := mload(add(sig, 64))
          v := byte(0, mload(add(sig, 96)))
        }
    
        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
          v += 27;
        }
    
        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
          return (address(0));
        } else {
          return ecrecover(hash, v, r, s);
        }
    }
    
    function execute(string message, string proof) external{
        var s = message.toSlice();
        var delim = ";".toSlice();
        var parts = new string[](s.count(delim) + 1);
        
        for(uint i = 0; i < parts.length; i++) {
            parts[i] = s.split(delim).toString();
        }
        
        handleExecute(parts[0], parts[1], parts[2], parts[3], parts[4], parts[6], parts[5], message, proof);
    }
    
    function handleExecute(string aSender, string functionCall, string callContract, string timeInv, string identify, string messageSize, string rayToSpend, string message, string proof) private{   
        require(keccak256(identify) == keccak256("RayNetwork"));
        //require(bytes(parts[3].length <7);
        
        uint time = timeInv.toUint();
        
        uint256 raySpend = rayToSpend.toUint();
        
        require(time < block.timestamp);
        require(time > block.timestamp - (10 * 1 days));
        
        address shouldBe = aSender.toAddress();
        
        require(used_datetime[shouldBe][time] == false);
        
        used_datetime[shouldBe][time] = true;
        
        address inv = callContract.toAddress();
        
        require(shouldBe == recover(message,proof,messageSize));
        
        RequestHandler(requestHandler).invoke(shouldBe,inv,functionCall,message,proof);
    
    }
    
    function executeTest(string message, string proof) constant public returns(address,address,address,uint){
        var s = message.toSlice();
        var delim = ";".toSlice();
        var parts = new string[](s.count(delim) + 1);
        
        for(uint i = 0; i < parts.length; i++) {
            parts[i] = s.split(delim).toString();
        }
        
        address sss = recover(message,proof,parts[6]);
        
        address shouldBe = parts[0].toAddress();
        address inv = parts[2].toAddress();
        
        uint time = parts[3].toUint();
        //if(shouldBe == recover(message,proof)){
            //RequestHandler(requestHandler).invoke(shouldBe,inv,parts[1]);
        //}
        return (inv,shouldBe,sss,time);
    
    }
    
    function Validate(string message, string proof) constant public returns(address){
        var s = message.toSlice();
        var delim = ";".toSlice();
        var parts = new string[](s.count(delim) + 1);
        
        for(uint i = 0; i < parts.length; i++) {
            parts[i] = s.split(delim).toString();
        }
        
        return recover(message,proof,parts[6]);
    }
    
    function Recover(string message, string proof) constant public returns(address){
        return recover(message,proof,"145");
    }
    
}
