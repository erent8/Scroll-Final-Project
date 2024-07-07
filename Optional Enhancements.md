
### Token Tabanlı Oylama:
```solidity
// SimpleDAO sözleşmesine ekleyin
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleDAO {
    IERC20 public governanceToken;
    
    constructor(address _governanceTokenAddress) {
        governanceToken = IERC20(_governanceTokenAddress);
    }
    
    function vote(uint256 proposalId, bool support) public {
        uint256 votingPower = governanceToken.balanceOf(msg.sender);
        require(votingPower > 0, "No voting power");
        
        // Oylama mantığını güncelleyin
        if (support) {
            proposals[proposalId].yesVotes += votingPower;
        } else {
            proposals[proposalId].noVotes += votingPower;
        }
    }
}
```
### Teklif Türleri:
```solidity
solidityCopyenum ProposalType { Financial, RuleChange, General }

struct Proposal {
    ProposalType proposalType;
    string description;
    uint256 deadline;
    uint256 yesVotes;
    uint256 noVotes;
    // Diğer alanlar...
}

function createProposal(string memory _description, uint256 _votingPeriod, ProposalType _type) public {
    // Teklif oluşturma mantığı...
    proposals[proposalId].proposalType = _type;
}
```
### İkinci Dereceden Oylama (Quadratic Voting):
```solidity

solidityCopyfunction vote(uint256 proposalId, uint256 voteAmount) public {
    uint256 tokenBalance = governanceToken.balanceOf(msg.sender);
    require(tokenBalance >= voteAmount, "Insufficient tokens");
    
    uint256 votingPower = sqrt(voteAmount);
    
    // Oylama mantığı...
    proposals[proposalId].votes += votingPower;
    
    // Token'ları kilitle veya yak
    governanceToken.transferFrom(msg.sender, address(this), voteAmount);
}

function sqrt(uint256 x) internal pure returns (uint256 y) {
    uint256 z = (x + 1) / 2;
    y = x;
    while (z < y) {
        y = z;
        z = (x / z + z) / 2;
    }
}
```
Bu geliştirmeleri uygulamak için:

* Token Tabanlı Oylama: Önce bir yönetişim token'ı oluşturun veya mevcut bir ERC20 token'ını kullanın. Sözleşme constructor'ında token adresini belirtin.
* Teklif Türleri: Teklif yapısını güncelleyin ve teklif oluştururken tür belirtmeye izin verin. Farklı tür teklifler için özel işleme mantığı ekleyebilirsiniz.
* İkinci Dereceden Oylama: Oy verme fonksiyonunu güncelleyin. Kullanıcılar, harcamak istedikleri token miktarını belirtir, ancak oy gücü bu miktarın kareköküdür. Bu, büyük token sahiplerinin etkisini azaltır.
