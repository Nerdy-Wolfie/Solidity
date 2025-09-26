//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

contract EventContract{
    struct Event{
        address organizer;
        string name;//name of the event
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemaining;
    }
    mapping(uint=>Event) public events;//details of the event
    mapping(address=>mapping(uint=>uint)) public tickets;
    uint public nextId;//why is it separate from the others?

    function createEvent(string calldata name,uint date,uint price,uint ticketCount) public{
        require(block.timestamp<date , "You cannot create an event for past date");//ensures only future evemts are created
        require(ticketCount>0 ,"Ticket count must be greater than 0");
        events[nextId]=Event(msg.sender,name,date,price,ticketCount,ticketCount);
        nextId++;//so that the next event has a different Id
    }

    function buyTicket(uint id,uint quantity) public payable{
        require(events[id].date!=0,"Event does not exist");//because we are just starting initially event id and date =0 as per the initial value of uint data type
        require(events[id].date>block.timestamp,"Event has ended");//means event has not ended
        Event storage _event=events[id];//I don't like this step where we create _events .Seems unnecessary to me .
        require(msg.value==(_event.price*quantity),"Ether is not enough");
        require(_event.ticketRemaining>=quantity,"Not enough tickets left");
        _event.ticketRemaining-=quantity;//subtracts ticket/s that have been bought
        tickets[msg.sender][id]+=quantity;
    }
    //watch this dude's mapping lectures
    function transferTicket(uint id,uint quantity,address to) public{
        require(events[id].date!=0,"Event does not exist");//because we are just starting initially event id and date =0 as per the initial value of uint data type
        require(events[id].date>block.timestamp,"Event has ended");//means event has not ended
        require(tickets[msg.sender][id]>=quantity,"You do not have tickets to transfer");
        tickets[msg.sender][id]-=quantity;
        tickets[to][id]+=quantity;
    }
}
//when creating event we input date as unix epoch time+3600 so event runs for an hour