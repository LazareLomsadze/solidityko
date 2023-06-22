pragma solidity ^0.8.0;

contract TicketBookingSystem {
    address public owner;
    uint public ticketPrice;
    uint public totalTickets;
    uint public availableTickets;
    mapping(address => uint) public ticketCount;

    event TicketPurchased(address buyer, uint quantity);

    constructor(uint _ticketPrice, uint _totalTickets) {
        owner = msg.sender;
        ticketPrice = _ticketPrice;
        totalTickets = _totalTickets;
        availableTickets = _totalTickets;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    function purchaseTickets(uint quantity) external payable {
        require(quantity > 0, "Number of tickets must be greater than zero");
        require(availableTickets >= quantity, "Not enough tickets available");
        require(msg.value >= ticketPrice * quantity, "Insufficient funds");

        ticketCount[msg.sender] += quantity;
        availableTickets -= quantity;

        emit TicketPurchased(msg.sender, quantity);
    }

    function refundTickets(uint quantity) external {
        require(ticketCount[msg.sender] >= quantity, "You do not have enough tickets to refund");

        ticketCount[msg.sender] -= quantity;
        availableTickets += quantity;

        payable(msg.sender).transfer(ticketPrice * quantity);
    }

    function withdrawFunds() external onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        payable(owner).transfer(balance);
    }
}
