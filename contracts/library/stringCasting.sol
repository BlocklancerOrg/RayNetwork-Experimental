pragma solidity ^0.4.14;

library stringcast{
    
    function _toLower(string str) pure internal returns (string) {
		bytes memory bStr = bytes(str);
		bytes memory bLower = new bytes(bStr.length);
		for (uint i = 0; i < bStr.length; i++) {
			// Uppercase character...
			if ((bStr[i] >= 65) && (bStr[i] <= 90)) {
				// So we add 32 to make it lowercase
				bLower[i] = bytes1(int(bStr[i]) + 32);
			} else {
				bLower[i] = bStr[i];
			}
		}
		return string(bLower);
    }
    
     function toAddress(string self) pure internal returns (address){
        self = _toLower(self);
        
        bytes memory tmp = bytes(self);
        
        uint160 addr = 0;
        uint160 b;
        uint160 b2;
        
        for (uint i=2; i<2+2*20; i+=2){
            
            addr *= 256;
            
            b = uint160(tmp[i]);
            b2 = uint160(tmp[i+1]);
            
            if ((b >= 97)&&(b <= 102)) b -= 87;
            else if ((b >= 48)&&(b <= 57)) b -= 48;
            
            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
            
            addr += (b*16+b2);
            
        }
        
        return address(addr);
    }
    
    function stringToAddress(string str) pure internal returns (address){
        str = _toLower(str);
        
        bytes memory tmp = bytes(str);
        
        uint160 addr = 0;
        uint160 b;
        uint160 b2;
        
        for (uint i=2; i<2+2*20; i+=2){
            
            addr *= 256;
            
            b = uint160(tmp[i]);
            b2 = uint160(tmp[i+1]);
            
            if ((b >= 97)&&(b <= 102)) b -= 87;
            else if ((b >= 48)&&(b <= 57)) b -= 48;
            
            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
            
            addr += (b*16+b2);
            
        }
        
        return address(addr);
    }
    
    function toUint(string self) constant internal returns (uint result) {
        bytes memory b = bytes(self);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }
    
}