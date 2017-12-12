pragma solidity ^0.4.14;

import "library/string.sol";
import "requestHandler.sol";
import "rayToken.sol";
import "library/stringCasting.sol";

contract RayNetwork{
    using strings for *;
    using stringcast for string;
    
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
        bytes memory sig = hexStrToBytes(sigs);

        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        //string memory pre = new string(prefix.length + 1)
        /*bytes memory num = bytes32ToBytes32String(6);
        uint len = prefix.length;
        for (uint i = 0; i < num.length; i++) prefix[len++] = num[i];*/
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
    
    function hexStrToBytes(string hex_str) pure
    private returns (bytes)
    {
        //Check hex string is valid
        if (bytes(hex_str)[0]!='0' ||
            bytes(hex_str)[1]!='x' ||
            bytes(hex_str).length%2!=0 ||
            bytes(hex_str).length<4)
            {
                revert();
            }

        bytes memory bytes_array = new bytes((bytes(hex_str).length-2)/2);

        for (uint i=2;i<bytes(hex_str).length;i+=2)
        {
            uint tetrad1=16;
            uint tetrad2=16;

            //left digit
            if (uint(bytes(hex_str)[i])>=48 &&uint(bytes(hex_str)[i])<=57)
                tetrad1=uint(bytes(hex_str)[i])-48;

            //right digit
            if (uint(bytes(hex_str)[i+1])>=48 &&uint(bytes(hex_str)[i+1])<=57)
                tetrad2=uint(bytes(hex_str)[i+1])-48;

            //left A->F
            if (uint(bytes(hex_str)[i])>=65 &&uint(bytes(hex_str)[i])<=70)
                tetrad1=uint(bytes(hex_str)[i])-65+10;

            //right A->F
            if (uint(bytes(hex_str)[i+1])>=65 &&uint(bytes(hex_str)[i+1])<=70)
                tetrad2=uint(bytes(hex_str)[i+1])-65+10;

            //left a->f
            if (uint(bytes(hex_str)[i])>=97 &&uint(bytes(hex_str)[i])<=102)
                tetrad1=uint(bytes(hex_str)[i])-97+10;

            //right a->f
            if (uint(bytes(hex_str)[i+1])>=97 &&uint(bytes(hex_str)[i+1])<=102)
                tetrad2=uint(bytes(hex_str)[i+1])-97+10;

            //Check all symbols are allowed
            if (tetrad1==16 || tetrad2==16)
                revert();

            bytes_array[i/2-1]=byte(16*tetrad1+tetrad2);
        }

        return bytes_array;
    }
    
    function toAsciiString(address x) pure private returns (string) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            byte b = byte(uint8(uint(x) / (2**(8*(19 - i)))));
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }
    
    function char(byte b) pure private returns (byte c) {
        if (b < 10) return byte(uint8(b) + 0x30);
        else return byte(uint8(b) + 0x57);
    }
    
    function toString(address x) pure private returns (string) {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++)
            b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
        return string(b);
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
