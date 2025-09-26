// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract CrowdFunding{

    struct Request{
        string description;//description of this particular request
        address payable recipient;
        uint value;//amount we want to raise
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;//address for number of voters
    }
    mapping(address=>uint) public contributors;
    mapping(uint=>Request) public requests;
    uint public numRequests;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    constructor(uint _target, uint _deadline){
        target = _target;//_target is temporary and only exists for the duration of the constructor.target is permanent in the blockchain
        deadline = block.timestamp+_deadline;//500 sec + 60 sec = 560 sec. block.timestamp is the exact time it takes to deploy the contract ._deadline is how long you want the campaign to last .
        minimumContribution = 100 wei;
        manager = msg.sender;
    }

    modifier onlyManager(){
        require(msg.sender == manager, "You are not the manager");
        _;
    }
    function createRequest(string calldata _description , address payable _recipient , uint _value) public onlyManager{//'calldata' means the string comes from the function call and is read-only.it saves gas because we don't copy it into memory, we just read it directly.
    //string calldata _description,   // a short text about what this request is for
    //address payable _recipient,     // the person who should receive the funds if approved
    //uint _value                     // how much money the request is asking for              //onlyManager - only the manager can call this function

      Request storage newRequest = requests[numRequests];//// create a new blank Request at position `numRequests` in the requests mapping   `storage` means we are writing directly into blockchain storage, not a temporary copy
      numRequests++;// increase the count of requests so the next one will be stored in the next slot
      // fill in the details of the new Request
      newRequest.description=_description;// set its description
      newRequest.recipient=_recipient;// set who gets the funds
      newRequest.value=_value;// set how much they want
      newRequest.completed=false;// start as "not completed"
      newRequest.noOfVoters=0;// no one has voted yet
    }

    function contribution()public payable{
        require(block.timestamp<deadline,"Deadline has passed");
        require(msg.value>=minimumContribution,"Minimum Contribution required is 100 wei");

        if(contributors[msg.sender]==0){
            noOfContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;//if you contribute twice there is still one contributor
    }

    function getContractBalance() public view returns(uint){
        return address(this).balance;

    }

    function refund()public{
        require(block.timestamp>deadline && raisedAmount<target,"You are not eligible for refund");
        require(contributors[msg.sender]>0,"You are not a contributor");
        payable(msg.sender).transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }

    function voteRequest(uint _requestNo)public{
        require(contributors[msg.sender]>0,"You are not a contributor");// 1. Only contributors can vote
        Request storage thisRequest = requests[_requestNo];// 2. Pick the request you want to vote for (by number)
        require(thisRequest.voters[msg.sender]==false,"You have already voted");// 3. Make sure this contributor hasn't already voted on this request
        thisRequest.voters[msg.sender]=true;//4. Mark this contributor as having voted
        thisRequest.noOfVoters++;// 5. Increase the count of votes

    }

//number of contributors is 3 and 2 is already greate than half the number of contributors
    function makePayment(uint _requestNo) public onlyManager{
        require(raisedAmount>=target,"Target is not reached");// 1. Make sure the fundraising was successful
        Request storage thisRequest=requests[_requestNo];// 2. Pick the request to pay out
        require(thisRequest.completed==false,"The request has been completed");// 3. Make sure this request has not already been completed
        require(thisRequest.noOfVoters>noOfContributors/2,"Majority does not support this request");// 4. Make sure more than half of the contributors voted "yes"
        thisRequest.recipient.transfer(thisRequest.value);//Pay the money to the recipient
        thisRequest.completed=true;// 5. Mark it as completedS
    }


}