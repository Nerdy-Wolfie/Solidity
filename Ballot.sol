//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

contract Voting{
    struct VotingEvent{
        string name;
        uint noOfRegisteredVoters;//confirm if noOfVoters is equal to votes and remove one
        address Candidate1;
        address Candidate2;
        address Candidate3;
        address Candidate4;
    }

    uint public deadline;
    uint public noOfRegisteredVoters;//confirm if noOfVoters is equal to votes and remove one-people who were registered to vote
    uint public votes;//voted already
    uint public votingPrice;
    uint public numEvents;
    address public manager;


    //should we make winner callable by anyone but only after the event has ended?
    mapping(address=>uint) public Voter; //do we still need noOfVoters?

    modifier onlyManager(){
        require(msg.sender == manager, "You are not the manager");
        _;
    }
    function createVotingEvent(string calldata name ,uint noOfRegisteredVoters,address Candidate1,address Candidate2,address Candidate3,address Candidate4) public onlyManager{
        
       
    }

    function Vote()
}