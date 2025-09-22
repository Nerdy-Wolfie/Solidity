//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe{

    using PriceConverter for uint256;//All uint256 are attached to the PriceConverter library .Hence all uint256 have access to the getConversionRate function
    address[] public funders;//address of the funders
    mapping(address funder => uint256 amount)public addressToAmountFunded;// newer in solidity,we can name the types in our mapping
    
    uint256 public constant MINIMUM_USD = 5e18;//constant variables naming convention : all caps and underscore
    address public immutable i_owner;//immutability naming convention: i _ variable name .Immutable 439 gas ,If you remove immutable 2574 gas

    constructor(){
        i_owner = msg.sender;
    }

    function fund() public payable{
        
        require(msg.value.getConversionRate() >= MINIMUM_USD ,"didn't send enough ETH");//msg.value is a uint256 so it can call the getConvesionRate funvtion and it will be passed as the first input parameter in the function  ie uint256 ethAmount
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;//additional contribution

        //What is a revert ?A revert undoes any action that has been done and sends the remaining gas back.
    }

    function withdraw() public onlyOwner{
    
        // = means set ,== means equal to
        //for loop
        //[0 ,1 ,2 ,3 ] elements
        // 1  2  3  4 indexes
        //for(/*starting index , ending index , step amount*/)
        //0 , 10 , 1
        //0 1 2 3 4 5 6 7 8 9 10

        //3 ,12 ,2
        //3 5 7 9 
        for(uint256 funderIndex =0 ; funderIndex < funders.length ; funderIndex = funderIndex ++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //reset the array
        funders = new address[](0);//the new keyword resets the funders array to a zero-sized , blank address array.
        //actually withdraw the funds
        
        //transfer
        //msg.sender is of type address
        //payable(msg.sender) is of type payable adddress
        //payable(msg.sender.transfer(address(this).balance));//transfer automatically revert if the transaction fails
        
        //send
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);//send will only revert if we add the require statement 
        //require(sendSuccess , "Send failed");
        
        //call
        (bool callSuccess , ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess ,"Call failed");
        
        
    }
    modifier onlyOwner(){
    //require(msg.sender == i_owner ,"Sender is not the owner");
    if(msg.sender != i_owner){revert NotOwner();}
    _;
    }

    //What happens if someone sends this contract ETH without calling the fund function?They get directed to the fund() function .

    receive() external payable{
        fund();
    }

    fallback() external payable{
        fund();
    }


}