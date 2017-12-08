//--------------------------------------------------------------//
//-------------------- RAY NETWORK TOKEN -----------------------//
//--------------------------------------------------------------//

pragma solidity ^0.4.14;

contract ERC20Interface {
     // Get the total token supply
     function totalSupply() constant public returns (uint256 totalSupply);
  
     // Get the account balance of another account with address _owner
     function balanceOf(address _owner) constant public returns (uint256 balance);
  
     // Send _value amount of tokens to address _to
     function transfer(address _to, uint256 _value) public returns (bool success);
  
     // Send _value amount of tokens from address _from to address _to
     function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
  
     // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
     // If this function is called again it overwrites the current allowance with _value.
     // this function is required for some DEX functionality
     function approve(address _spender, uint256 _value) public returns (bool success);
  
     // Returns the amount which _spender is still allowed to withdraw from _owner
     function allowance(address _owner, address _spender) constant public returns (uint256 remaining);
  
     // Triggered when tokens are transferred.
     event Transfer(address indexed _from, address indexed _to, uint256 _value);
  
     // Triggered whenever approve(address _spender, uint256 _value) is called.
     event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/// Ray Network Token (RAY)
contract RayNetworkToken is ERC20Interface {
    string public constant name = "Ray Network Token";
    string public constant symbol = "RAY";
    uint8 public constant decimals = 18;  // 18 decimal places, the same as ETH.
    
    mapping(address => mapping (address => uint256)) allowed;

    bool allowTransfer=true;
    bool buyable=true;

    // Receives ETH and its own RAY endowment.
    address public master;
    
    address rayNetwork;

    // The current total token supply.
    uint256 totalTokens;
    
    uint exchangeRate=10000;

    mapping (address => uint256) balances;

    function BlocklancerToken() public {
        master = msg.sender;
    }

    /// allows to transfer token to another address
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(allowTransfer);

        var senderBalance = balances[msg.sender];
        //only allow if the balance of the sender is more than he want's to send
        if (senderBalance >= _value && _value > 0) {
            //reduce the sender balance by the amount he sends
            senderBalance -= _value;
            balances[msg.sender] = senderBalance;
            
            //increase the balance of the receiver by the amount we reduced the balance of the sender
            balances[_to] += _value;
            
            Transfer(msg.sender, _to, _value);
            return true;
        }
        //transfer failed
        return false;
    }
    
    /// allows to transfer token to another address
    function spend(address _from, uint256 _value) public returns (bool success) {
        require(msg.sender == rayNetwork);

        var senderBalance = balances[_from];
        //only allow if the balance of the sender is more than he want's to send
        if (senderBalance >= _value && _value > 0) {
            //reduce the sender balance by the amount he sends
            senderBalance -= _value;
            totalTokens -= _value;
            balances[_from] = senderBalance;
            
            Transfer(_from, rayNetwork, _value);
            return true;
        }
        //transfer failed
        return false;
    }

    //returns the total amount of RAY in circulation
    //get displayed on the website whilst the crowd funding
    function totalSupply() constant public returns (uint256 totalSupply) {
        return totalTokens;
    }
    
    //retruns the balance of the owner address
    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }
    
    function setTransfer(bool r) public{
        require(msg.sender == master);
        allowTransfer=r;
    }
    
    function setRayNetwork(address ray) public{
        require(msg.sender == master);
        rayNetwork = ray;
    }
    
    function setBuyable(bool r) public{
        require(msg.sender == master);
        buyable=r;
    }
	
	function addToken(address invest,uint256 value) public{
		require(msg.sender == master);
		balances[invest]+=value;
		totalTokens+=value;
	}
    
    //return the current exchange rate -> RAY per Ether
    function getExchangeRate() constant public returns(uint){
		return exchangeRate;
    }

    //when someone send ether to this contract
    function() payable external {
        //not possible if the funding has ended
        require(buyable);

        require(msg.value > 0);

        //calculate the amount of RAY the sender receives
        var numTokens = msg.value * getExchangeRate();
        totalTokens += numTokens;

        // increase the amount of token the sender holds
        balances[msg.sender] += numTokens;

        // Log token creation
        Transfer(0, msg.sender, numTokens);
    }

	
    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
     // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
     // fees in sub-currencies; the command should fail unless the _from account has
     // deliberately authorized the sender of the message via some mechanism; we propose
     // these standardized APIs for approval:
     function transferFrom(address _from,address _to,uint256 _amount) public returns (bool success) {
         require(allowTransfer);
         if (balances[_from] >= _amount
             && allowed[_from][msg.sender] >= _amount
             && _amount > 0
             && balances[_to] + _amount > balances[_to]) {
             balances[_from] -= _amount;
             allowed[_from][msg.sender] -= _amount;
             balances[_to] += _amount;
             Transfer(_from, _to, _amount);
             return true;
         } else {
             return false;
         }
     }
  
     // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
     // If this function is called again it overwrites the current allowance with _value.
     function approve(address _spender, uint256 _amount) public returns (bool success) {
         require(allowTransfer);
         allowed[msg.sender][_spender] = _amount;
         Approval(msg.sender, _spender, _amount);
         return true;
     }
  
     function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
         return allowed[_owner][_spender];
     }
}