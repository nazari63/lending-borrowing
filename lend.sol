// Minor update: Comment added for GitHub contributions
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract LendingAndBorrowing {
    address public owner;
    IERC20 public token;

    uint256 public interestRate = 5; // بهره ۵ درصد
    mapping(address => uint256) public lentAmount;
    mapping(address => uint256) public borrowedAmount;
    mapping(address => uint256) public borrowInterest;

    event Lended(address indexed lender, uint256 amount);
    event Borrowed(address indexed borrower, uint256 amount, uint256 interest);
    event Repaid(address indexed borrower, uint256 amount, uint256 interest);

    constructor(address _token) {
        owner = msg.sender;
        token = IERC20(_token);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this");
        _;
    }

    // قرض دادن توکن‌ها
    function lend(uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        require(token.balanceOf(msg.sender) >= amount, "Insufficient balance to lend");

        lentAmount[msg.sender] += amount;

        // انتقال توکن‌ها به قرارداد
        token.transferFrom(msg.sender, address(this), amount);

        emit Lended(msg.sender, amount);
    }

    // قرض گرفتن توکن‌ها
    function borrow(uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        require(token.balanceOf(address(this)) >= amount, "Insufficient balance in contract");

        uint256 interest = (amount * interestRate) / 100;

        borrowedAmount[msg.sender] += amount;
        borrowInterest[msg.sender] += interest;

        // انتقال توکن‌ها به کاربر
        token.transfer(msg.sender, amount);

        emit Borrowed(msg.sender, amount, interest);
    }

    // بازپرداخت قرض و بهره
    function repay(uint256 amount) public {
        uint256 totalRepayment = borrowedAmount[msg.sender] + borrowInterest[msg.sender];
        require(amount >= totalRepayment, "Repayment amount is less than the total debt");

        borrowedAmount[msg.sender] = 0;
        borrowInterest[msg.sender] = 0;

        // انتقال توکن‌ها به قرارداد
        token.transferFrom(msg.sender, address(this), amount);

        emit Repaid(msg.sender, amount, totalRepayment);
    }

    // مشاهده موجودی قرض‌دهی یک کاربر
    function getLentAmount(address user) public view returns (uint256) {
        return lentAmount[user];
    }

    // مشاهده موجودی قرض‌گیری یک کاربر
    function getBorrowedAmount(address user) public view returns (uint256) {
        return borrowedAmount[user];
    }

    // مشاهده بهره قرض یک کاربر
    function getBorrowInterest(address user) public view returns (uint256) {
        return borrowInterest[user];
    }

    // تغییر نرخ بهره (فقط برای مالک)
    function setInterestRate(uint256 rate) public onlyOwner {
        interestRate = rate;
    }
}
