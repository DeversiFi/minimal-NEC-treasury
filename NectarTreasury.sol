pragma solidity ^0.6.0;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

interface BurnableToken {
    function burnAndRetrieve(uint256 _tokensToBurn) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function totalSupply() external view returns (uint256);
}

contract NectarTreasury {
    using SafeMath for uint256;
    
    address necAddress;
    address necDAOAddress;

    constructor(address _token, address _DAO) public {
        necAddress = _token;
        necDAOAddress = _DAO;
    }
    
    modifier onlyDAO {
        require(msg.sender == necDAOAddress); 
        _;
    }
    
    function necToken() public view returns (BurnableToken) {
        return BurnableToken(necAddress);
    }
    
    function calculateEthPerNec(uint256 necAmount) public view returns (uint256) {
        return treasurySize().mul(necAmount).div(necToken().totalSupply());
    }
    
    function treasurySize() public view returns (uint256) {
        return address(this).balance;
    }
    
    function burnTokensAndClaimeShareOfTreasury(uint256 necAmount) external {
        require(
            necToken().transferFrom(msg.sender, address(this), necAmount),
            "NEC transferFrom failed"
        );
        uint ethToSend = calculateEthPerNec(necAmount);
        require(ethToSend > 0, "No ether to pay out");
        necToken().burnAndRetrieve(necAmount);
        msg.sender.transfer(ethToSend);
    }
    
    function transferTreasuryFundsToDAO(uint256 ethAmount) onlyDAO public {
        msg.sender.transfer(ethAmount);
    }
}
