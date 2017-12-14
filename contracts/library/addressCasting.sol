pragma solidity ^0.4.14;

library addresscast{

    function char(byte b) pure internal returns (byte c) {
        if (b < 10) return byte(uint8(b) + 0x30);
        else return byte(uint8(b) + 0x57);
    }
    
    function toString(address self) pure internal returns (bytes) {
        bytes memory str = new bytes(40);
        
        for (uint i = 0; i < 20; i++) {
            byte strb = byte(uint8(uint(self) / (2**(8*(19 - i)))));
            
            byte hi = byte(uint8(strb) / 16);
            byte lo = byte(uint8(strb) - 16 * uint8(hi));
            
            str[2*i] = char(hi);
            str[2*i+1] = char(lo);            
        }
        
        return str;
    }
    
}