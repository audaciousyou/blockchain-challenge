pragma solidity ^0.4.18;
// We have to specify what version of compiler this code will compile with

// Candidates used when compiling the contract
// ["0x55C187fB0150Fa0299f02f61182178112ed6395f", "0x53f8c702DB6e97A2d96a9D6AC39e493cB1D2A41a","0x3a4511cFFab155cd688Faa15cA92972fe909FE60"]

contract Voting {
  
  // Events
  event voteStarted(address[] _candidateList);
  event voteCast(address _voterAddress, address _candidateAddress, uint _fundsPledged, uint _totalVotesForCandidate, uint _totalFundsRaised);
  event voteEnded(address _winningCandidateAddress, uint _winningCandidateVotes, uint _fundsToWinner, uint _fundsToPool, address _poolAddress);
  
  // Variables
  address owner;
  address[] public candidateList;
  bool votingActive;
  mapping (address => uint) votesReceived;
  mapping (address => uint) fundsPledged;

  // Constructor function
  function Voting(address[] candidateAddresses) public {
    owner = msg.sender; 
    candidateList = candidateAddresses;
    votingActive = true;
    emit voteStarted(candidateList);
  }

  // This function returns the total votes a candidate has received so far
  function totalVotesAndFunds(address candidate) view public returns (uint, uint) {
    require(validCandidate(candidate));
    return (votesReceived[candidate], fundsPledged[candidate]);
  }
  
  // This function increments the vote count for the specified candidate. This
  // is equivalent to casting a vote
  function voteForCandidate(address candidateAddress) public payable {
    require(validCandidate(candidateAddress));
    require(votingActive);
    votesReceived[candidateAddress] += 1;
    fundsPledged[candidateAddress] += msg.value;
    emit voteCast(msg.sender, candidateAddress, msg.value,votesReceived[candidateAddress],fundsPledged[candidateAddress]);
  }

  // This function checks that a given address is a valid candidate
  function validCandidate(address candidate) view private returns (bool) {
    for(uint i = 0; i < candidateList.length; i++) {
      if (candidateList[i] == candidate) {
        return true;
      }
    }
    return false;
  }
  
  // This function ends the voting and transfers out funds as required
  function endVote(address fundPool) public {
    require(msg.sender == owner);
    uint highestVotes = 0;
    address winningAddress;
    
    for(uint i = 0; i < candidateList.length; i++) {
        if (votesReceived[candidateList[i]] >= highestVotes) {
          winningAddress = candidateList[i];
          highestVotes = votesReceived[winningAddress];
        }
    }
    
    uint fundsToWinner = fundsPledged[winningAddress];
      
    winningAddress.transfer(fundsToWinner);
      
    uint fundsToPool = this.balance;
      
    fundPool.transfer(this.balance);
    votingActive = false;
      
    emit voteEnded(winningAddress,highestVotes,fundsToWinner, fundsToPool,fundPool);
  }
}