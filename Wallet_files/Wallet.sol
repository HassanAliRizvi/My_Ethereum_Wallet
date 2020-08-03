pragma solidity ^0.6.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol";
import "./Allowance.sol";

contract Wallet is Allowance{
    
    using SafeMath for uint; 

    struct Payment {
        uint timestamp;
        uint amount; 
    }
    
    struct Balance {
        uint totalBalance;
        uint numPayments;
        mapping(uint => Payment) payments;
    }
    
    mapping (address => Balance) balanceReceived;
    
    event MoneyReceived(address indexed _from, uint _Amount);
    event MoneySent(address indexed _beneficiary, uint _Amount);
    
    bool public paused;
    
    function sendMoney() public payable{
        balanceReceived[msg.sender].totalBalance += msg.value;
        Payment memory payment = Payment(msg.value, now);
        balanceReceived[msg.sender].payments[balanceReceived[msg.sender].numPayments] = payment;
        balanceReceived[msg.sender].numPayments++;
    }
    
    
    function withdrawMoney(address payable _to, uint _amount) public ownerOrAllowed(_amount){
        require(_amount <= address(this).balance, "Contract doesn't own enough money");
        if(!isOwner()) {
            reduceAllowance(msg.sender, _amount);
        }
        emit MoneySent(_to, _amount);
        _to.transfer(_amount);
    }

    receive() external payable {
        emit MoneyReceived(msg.sender, msg.value);
    }
    
    function pauseContract(bool _paused) public view {
        _paused = paused;
    }
    
}