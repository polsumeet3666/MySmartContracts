pragma solidity ^0.5.0;

// smart contract for simple application like splitwise
contract Splitwise {
    
    struct User {
        string name;
        int balance;
        address userAddress;
    }
    
    struct Expense {
        string title;
        int amount;
        address payer;
        address[] payee;
        mapping(address => bool) aggrement;
    }
    
    // map of users
    mapping(address => User) public userMap;
    
    // list of expenses
    Expense[] public expenseList;
    
    // constructor
    constructor(string memory _name) public {
        createUser(_name,msg.sender);
    }
    
    /**
    * create user
    * @param _name user name
    * @param _userAddress user's address
    */
    function createUser(string memory _name,address _userAddress) public {
        
        userMap[_userAddress] = User({
            name:_name,
            userAddress:_userAddress,
            balance:0
        });
        
    }
    
    /**
    * get user details
    * @param _address user's address
    */
    function getUserDetails(address _address) public view returns (string memory){
        require(userMap[_address].userAddress == _address,"Error: User Not Present.");
        return userMap[_address].name;
    }
    
    
    /**
    * create Expense
    * @param _amount amount spend
    * @param _title amount paid for item
    * @param _payee list of user in expense
    */
    function createExpense(int _amount,string memory _title,address[] memory _payee) public {
       
        require(_amount > 0,"Error: Amount must be greater than zero");
        Expense memory exp = Expense({
            title:_title,
            payee:_payee,
            amount:_amount,
            payer:msg.sender
          
        });
       expenseList.push(exp);
    }
    
    
    /**
     * display user's balance
     * switch to respective account before calling this function
     * balance is displayed using msg.sender
     */
    function getBalance() public view returns (string memory,int){
        return (userMap[msg.sender].name,
        userMap[msg.sender].balance);
    }
    
    /**
     * modifier to check if current user is part of payee
     * */
    modifier isValidPayee(uint id) {
        require(expenseList.length>0,"Error: Expense list is empty");
        Expense storage exp = expenseList[id];
        bool result = false;
        for(uint i=0;i<exp.payee.length;i++){
            if (exp.payee[i] == msg.sender){
                result = true;
                break;
            }
        }
        require(result == true,"User not in payee list");
        _;
    }
    
    /**
     * update aggrement
     * @param _agree true or false
     * */
     function updateAgreement(uint i,bool _agree) isValidPayee(i) public payable {
        require(expenseList.length>0,"Error: Expense list is empty");
        expenseList[i].aggrement[msg.sender]=_agree;
        updateBalance(i); 
     }

    /**
     * get aggrement count
     * @param id expense id 
     * */
     function getAgreementCount(uint id) public view returns (int){
         require(expenseList.length>0,"Error: Expense list is empty");
         Expense storage exp = expenseList[id];
         int count = 0;
         if (exp.aggrement[exp.payer]==true){
             count++;
         }
         for(uint i=0;i<exp.payee.length;i++){
            if (exp.aggrement[exp.payee[i]]== true){
                count++;
            }   
         }
         
         return count;
     }
     
     /**
      * updateBalance
      * @param id expenseid
      * */
      function updateBalance(uint id) internal {
          int count = getAgreementCount(id);
          int share = expenseList[id].amount/count;
          
          userMap[expenseList[id].payer].balance=share;
          Expense storage exp = expenseList[id];
          for(uint i=0;i<exp.payee.length;i++){
              userMap[exp.payee[i]].balance= -share;
          }
      }
    
    /**
     * add money in wallet
     * */
     function addMoney(int _amount) public payable{
         userMap[msg.sender].balance = userMap[msg.sender].balance + _amount;
     }
} // contract ends
