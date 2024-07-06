// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract SimpleDAO {
    address public owner; // DAO'nun sahibi olan adres
    uint256 public membershipFee; // Üyelik ücreti

    // Teklif durumlarını belirten enum
    enum ProposalStatus { Pending, Approved, Rejected }

    // Üyeleri temsil eden struct
    struct Member {
        bool isMember; // Üye olup olmadığını belirten bool değişkeni
    }

    // Teklifleri temsil eden struct
    struct Proposal {
        string description; // Teklifin açıklaması
        uint256 deadline; // Teklifin oylama süresinin bitiş zamanı
        uint256 yesVotes; // Evet oylarının sayısı
        uint256 noVotes; // Hayır oylarının sayısı
        ProposalStatus status; // Teklifin durumu
        mapping(address => bool) voted; // Üyelerin oylama yapıp yapmadığını takip eden mapping
    }

    mapping(address => Member) public members; // Üyeleri takip eden mapping
    Proposal[] public proposals; // Teklifleri depolayan dizi

    // Sadece sahibi tarafından erişilebilen fonksiyonlar için modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Sadece üyeler tarafından erişilebilen fonksiyonlar için modifier
    modifier onlyMember() {
        require(members[msg.sender].isMember, "Not a member");
        _;
    }

    // Etkinlikler (Events)
    event MembershipJoined(address indexed member); // Yeni üye katıldığında tetiklenir
    event ProposalCreated(uint256 indexed proposalId, string description); // Yeni teklif oluşturulduğunda tetiklenir
    event Voted(uint256 indexed proposalId, bool vote, address indexed voter); // Oylama yapıldığında tetiklenir

    // Constructor: sözleşme dağıtıldığında çalıştırılır
    constructor(uint256 _membershipFee) {
        owner = msg.sender; // Sahip olarak sözleşmeyi dağıtan adres belirlenir
        membershipFee = _membershipFee; // Üyelik ücreti belirlenir
    }

    // Üyelik fonksiyonu
    function joinMembership() external payable {
        require(!members[msg.sender].isMember, "Already a member"); // Üye olmadığını doğrula
        require(msg.value == membershipFee, "Incorrect membership fee"); // Doğru üyelik ücretini gönderdiğini doğrula

        members[msg.sender] = Member(true); // Üye olarak kaydet
        emit MembershipJoined(msg.sender); // Etkinlik tetikle
    }

    // Teklif oluşturma fonksiyonu
    function createProposal(string calldata description, uint256 duration) external onlyMember {
        Proposal storage newProposal = proposals.push(); // Yeni teklif oluştur ve diziye ekle
        newProposal.description = description; // Teklif açıklamasını ayarla
        newProposal.deadline = block.timestamp + duration; // Teklif süresini ayarla
        newProposal.status = ProposalStatus.Pending; // Teklif durumunu beklemede olarak ayarla

        emit ProposalCreated(proposals.length - 1, description); // Etkinlik tetikle
    }

    // Oylama fonksiyonu
    function voteOnProposal(uint256 proposalId, bool supportProposal) external onlyMember {
        Proposal storage proposal = proposals[proposalId]; // İlgili teklifi al
        require(block.timestamp < proposal.deadline, "Voting period over"); // Oylama süresinin bitmediğini doğrula
        require(!proposal.voted[msg.sender], "Already voted"); // Daha önce oy kullanılmadığını doğrula

        proposal.voted[msg.sender] = true; // Oy kullanıldığını kaydet

        if (supportProposal) {
            proposal.yesVotes++; // Evet oylarını artır
        } else {
            proposal.noVotes++; // Hayır oylarını artır
        }

        emit Voted(proposalId, supportProposal, msg.sender); // Etkinlik tetikle
    }

    // Teklifi finalize etme fonksiyonu
    function finalizeProposal(uint256 proposalId) external onlyOwner {
        Proposal storage proposal = proposals[proposalId]; // İlgili teklifi al
        require(block.timestamp >= proposal.deadline, "Voting period not over"); // Oylama süresinin bittiğini doğrula
        require(proposal.status == ProposalStatus.Pending, "Proposal already finalized"); // Teklifin beklemede olduğunu doğrula

        if (proposal.yesVotes > proposal.noVotes) {
            proposal.status = ProposalStatus.Approved; // Evet oyları fazla ise teklif onaylanır
        } else {
            proposal.status = ProposalStatus.Rejected; // Hayır oyları fazla ise teklif reddedilir
        }
    }

    // Belirli bir teklifi görüntüleme fonksiyonu
    function getProposal(uint256 proposalId) external view returns (
        string memory description,
        uint256 deadline,
        uint256 yesVotes,
        uint256 noVotes,
        ProposalStatus status
    ) {
        Proposal storage proposal = proposals[proposalId]; // İlgili teklifi al
        return (
            proposal.description,
            proposal.deadline,
            proposal.yesVotes,
            proposal.noVotes,
            proposal.status
        ); // Teklifin detaylarını döndür
    }

    // Fonları çekme fonksiyonu
    function withdrawFunds() external onlyOwner {
        uint256 balance = address(this).balance; // Sözleşme bakiyesini al
        (bool success, ) = owner.call{value: balance}(""); // Sahibe fonları gönder
        require(success, "Withdrawal failed"); // İşlemin başarılı olduğunu doğrula
    }
}
