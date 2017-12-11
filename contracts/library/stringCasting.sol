pragma solidity ^0.4.14;

library stringCasting{
    
    function _toLower(string str) pure private returns (string) {
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
    
    function parseAddr(string self) pure returns (address){
        string memory _a = _toLower(self);
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i=2; i<2+2*20; i+=2){
            iaddr *= 256;
            b1 = uint160(tmp[i]);
            b2 = uint160(tmp[i+1]);
            if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;
            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
            iaddr += (b1*16+b2);
        }
        return address(iaddr);
    }
    
    function stringToAddress(string str) pure returns (address){
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
    
}