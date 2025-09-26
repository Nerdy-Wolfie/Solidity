// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract Lottery{
    //entities that will be participating:manager , players , winner
    address public manager;
    address payable[] public players;//payable so that the players are ableto send and receive ETH .[]Dynamic array because there can be several players
    address payable public winner;//payable so that they can receive lottery reward

    constructor(){//constructor is a special function in solidity that runs only once , when the contract is first deployed to the blockchain and can never be called again.Only one constructor in each smart contract ,you can set up token supply and manager=msg.sender in the same constructor.
        manager = msg.sender;//a global variable in solidity that always represents the address of whoever is calling the function or deploying the contract.the left side of = is “where to store the value,” and the right side is “what value to store.”
    }

    function participate()public payable{
        require(msg.value == 1 ether , "Please pay  ether only");//condition check
        players.push(payable(msg.sender));//because msg.sender is a normal address and it needs to be changed into a payable address.Now msg.sender will be in a position to send and receive ether .Here msg.sender is the address of the player who is calling participate().So here, msg.sender = the player’s wallet.You’re pushing their address into the players list.

    }

    function getBalance()public view returns(uint){
        require(manager == msg.sender , "You are not the manager");//you’re checking that the caller of getBalance() is the same address stored in manager
        return address(this).balance;//this refers to the current contract;address(this) gets the contract's address on the blockchain;.balance asks 'how much ether is stored in this address right now?'
    }

    function random() internal view returns(uint){//this is just a beginner example this is not how you should generate a random number in real smart contracts .You shoukd use a oracle
        return uint(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, players.length)));
    }

    function pickWinner() public{
        require(manager == msg.sender , "You are not the manager");
        require(players.length >= 3 , "Players are less than 3");

        uint r=random();
        uint index = r%players.length;
        winner = players[index];
        winner.transfer(getBalance());//whatever balance is in the address is transferred to the winner's address.
        players = new address payable[](0);//initializes the player array back to 0 so that restart our lottery

    }

    }