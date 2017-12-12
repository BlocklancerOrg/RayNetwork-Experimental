pragma solidity ^0.4.8;

contract RequestHandler{
    function getMainAccount(address who) constant public returns (address);
}

contract Jobs{
    
    struct job{
        uint256 price;
        address client;
        string plain;
        string proof;
        bid[] bids;
    }
    
    struct bid{
        string plain;
        string proof;
    }
    
    job Job;
    
    address public requestHandler;
    address public master;
    
    job[] public jobs;
    
    function Jobs() public{
        master = msg.sender;
    }
    
    function setRequestHandler(address a) public{
        require(msg.sender == master);
        requestHandler = a;
    }
    
    function addJob(uint256 price,string plain, string proof) public{
        //address user;
        //user = RequestHandler(requestHandler).getMainAccount(msg.sender);
        //require(user != 0);
        
        job storage job0 = Job;
        job0.client = msg.sender;
        job0.plain = plain;
        job0.proof = proof;
        job0.price = price;
        
        jobs.push(job0);
    }
    
    function addBid(uint256 id,string plain, string proof) public{
        address user;
        user = RequestHandler(requestHandler).getMainAccount(msg.sender);
        require(user != 0);
        
        bid memory bid0 = bid(plain,proof);
        jobs[id].bids.push(bid0);
    }
    
    function selectBid(uint256 idJob, uint256 idBid) constant public returns(string, string, string, string){
        return (jobs[idJob].plain, jobs[idJob].proof, jobs[idJob].bids[idBid].plain, jobs[idJob].bids[idBid].proof);
    }
    
    function getJob(uint idJob) constant public returns(string,string){
        return (jobs[idJob].plain, jobs[idJob].proof);
    }
    
}