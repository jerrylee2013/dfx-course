import Dao "dao";
import Principal "mo:base/Principal";

actor {
    
    public type VoteResult = {
        yesCount: Nat;
        noCount: Nat;
        proposalResult: Text;
    };
    public type User = actor {
        voteRestrictProposal: shared(Principal, Bool) -> async VoteResult;
        voteUnrestrictProposal: shared(Principal, Bool) -> async VoteResult;
    };

    public func voteRestrictProposal(dao: Principal, myOppion: Bool) : async VoteResult{
        let daoActor : Dao.Dao = actor(Principal.toText(dao));
        await daoActor.vote_restrict_proposal(myOppion);
    };

    public func voteUnrestrictProposal(dao: Principal, myOppion: Bool) : async VoteResult {
        let daoActor : Dao.Dao = actor(Principal.toText(dao));
        await daoActor.vote_unrestrict_proposal(myOppion);
    };
}
