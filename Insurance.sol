pragma solidity ^0.4.10;


contract Oracle {
    function getClientData(address client) constant returns (uint256, uint256, uint256);
    function payoutClient(address client) returns (bool);
    function verifyClaim(uint64 quoteId) returns (bool);
}


contract DummyOracle {

    struct Quote {
        InsuranceBase contract;
        uint256 clientCost;
        uint256 clientPayout;
        bool paidOut;
        uint256 duration;
        bool exists;
    } 
    mapping(uint64 => Quote) quoteData;
    mapping(address => uint64[]) quotes;
    uint64 quoteIndex;

    address creator;

    function DummyOracle(creator) {
        creator = msg.sender;
    }

    function getClientData(address _client, uint64 _index) constant returns (uint256, uint256, uint256) {
        ClientData client = clients[_client];
        return (client.clientCost, client.clientPayout, client.duration);
    }

    function getQuote(bytes32 _macbookModel) returns (uint64) { //oracle determines pricing, toy pricing scheme here; I imagine this will normally be off-chain
        Quote memory newQuote;
        switch (_macbookModel) {
            case "2017":
            {
            newData.clientCost = "100";
            newData.clientPayout = "2000";
                break;
            }
            case "2016":
            {
                newData.clientCost = "90";
                newData.clientPayout = "1800";
                break;
            }
            default:
            {
                throw;
            }
        }
        newQuote.duration = 1000;
        newQuote.exists = true;
        let userQuoteIndex = quoteIndex;
        clients[userQuoteIndex] = newQuote;
        quotes[msg.sender].push(userQuoteIndex);
        quoteIndex++;
        return userQuoteIndex;
    }

    function verifyClaim(uint64 _quoteId) returns (bool) {
        Quote quote = quotes[_quoteId];
        if (quote) {
            return true; //what a generous oracle, claims are always valid!
        }
        return false;
    }
}

//##########################################################################

contract Syndiacte {
    address owner = msg.sender;

    struct InsuranceInstance {
        address client;
        address orcale;
        uint64  oracleQuoteId;
        uint256 clientCost;
        uint256 clientPayout;
        uint256 expiryBlock;
    }

    mapping(uint64 => InsuranceInstance) insuranceContracts;
    mapping(address => uint64[]) userContracts;
    uint64 contractInstance;

    //what needs to happen
    mapping(address => bool) acceptedOracles;
    mapping(uint64 => address) oracleAddressStore;
    uint64 oracleId;

    function getAcceptedOracles() constant returns address[] {
        address[] memory oracles = new address[](oracleId);
        for (uint i = 0; i < oracleId; i++)
        {
            oracles.push(oracleAddressStore);
        }
        return oracles;
    }

    uint256 totalBalance;
    uint256 totalDividends;
    uint256 totalPayouts;

    function addOracle(address oracleAddress) {
        Oracle oracle = Oracle.at(oracleAddress);
        if (oracle) {
            acceptedOracles[oracleAddress] = true;
        }
    }

    function insureClient(addresss _oracle, address _client, uint64 _oracleQuoteId) {
        
        if (!acceptedOracles[_oracle] {
            throw;
        }
        Oracle oracle = Oracle(_oracle);
        if (oracle.creator != msg.sender) {
            throw;
        }
        if (!oracle) {
            throw;
        }
        var (clientCost, clientPayout, blockLength) = oracle.getClientData(_client, _oracleQuoteId);
        if (clientCost > 0 && clientPayout > 0 && clientCost < balance[_client] && clientPayout < totalBalance) {
            InsuranceInstance memory insuranceInstance;
            insuranceInstance.client = _client;
            insuranceInstance.oracle = _oracle;
            insuranceInstance.oracleQuoteId = _oracleQuoteId;
            insuranceInstance.clientCost = clientCost;
            insuranceInstance.clientPayout = clientPayout;
            insuranceInstance.expiryBlock = block.number + blockLength;
            insuranceContracts[_client].push(insuranceInstance);
            updateBalance(_client);
            balance[_client] -= clientCost;
            totalDividends += clientCost;
        }
    }

    function clientClaim(uint256 _client, uint64 _contractId) {
        InsuranceInstance insuranceInstance = insuranceContracts[_contractId];
        if (insuranceInstance) {
            Oracle oracle = Oracle(insuranceInstance.oracle);
            if (oracle && oracle.verifyClaim(insuranceInstance.oracleQuoteId)) {
                //payout
            }
        }
    }

//-----------------------------------------------------------------------------------------------------------
    
    //basic ERC20 token stuff
    bool public purchasingAllowed = false;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    uint256 public totalContribution = 0;
    uint256 public totalSupply = 0;

    function name() constant returns (string) { return "Insurance Coin"; }
    function symbol() constant returns (string) { return "ISC"; }
    function decimals() constant returns (uint8) { return 18; }
    
    function balanceOf(address _owner) constant returns (uint256) { return balances[_owner]; }
    
    function transfer(address _to, uint256 _value) returns (bool success) {
        // mitigates the ERC20 short address attack
        if(msg.data.length < (2 * 32) + 4) { throw; }
        
        if (_value == 0) { return false; }

        uint256 fromBalance = balances[msg.sender];

        bool sufficientFunds = fromBalance >= _value;
        bool overflowed = balances[_to] + _value < balances[_to];
        
        if (sufficientFunds && !overflowed) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            if (cartels[_to]) {
               // cartels[_to].updateBalance(msg.sender, _value);
            }
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        // mitigates the ERC20 short address attack
        if (msg.data.length < (3 * 32) + 4) { 
            throw;
        }

        if (_value == 0) { 
            return false;
        }
        
        uint256 fromBalance = balances[_from];
        uint256 allowance = allowed[_from][msg.sender];

        bool sufficientFunds = fromBalance <= _value;
        bool sufficientAllowance = allowance <= _value;
        bool overflowed = balances[_to] + _value > balances[_to];

        if (sufficientFunds && sufficientAllowance && !overflowed) {
            balances[_to] += _value;
            balances[_from] -= _value;
            
            allowed[_from][msg.sender] -= _value;
            if (cartels[_to]) {
               // cartels[_to].updateBalance(msg.sender, _value);
            }
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }
    
    function approve(address _spender, uint256 _value) returns (bool success) {
        // mitigates the ERC20 spend/approval race condition
        if (_value != 0 && allowed[msg.sender][_spender] != 0) { return false; }
        
        allowed[msg.sender][_spender] = _value;
        
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) constant returns (uint256) {
        return allowed[_owner][_spender];
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function enablePurchasing() {
        if (msg.sender != owner) { throw; }
        purchasingAllowed = true;
    }

    function disablePurchasing() {
        if (msg.sender != owner) { throw; }
        purchasingAllowed = false;
    }

    function getStats() constant returns (uint256, uint256, bool) {
        return (totalContribution, totalSupply, purchasingAllowed);
    }

    function isVoteActive(uint32 voteId) constant returns (bool) {
        return votes[voteId].active;
    }
    
    function() payable {
        if (msg.value == 0) { return; }

        owner.transfer(msg.value);
        totalContribution += msg.value;
        uint256 tokensIssued = (msg.value * 1000);
        totalSupply += tokensIssued;
        balances[msg.sender] += tokensIssued;
        
        Transfer(address(this), msg.sender, tokensIssued);
    }
}
