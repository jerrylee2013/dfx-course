import Buffer "mo:base/Buffer";
import List "mo:base/List";
import Principal "mo:base/Principal";

shared(msg) actor class Dao(managedCanisterId: Principal, min: Nat, members: [Principal]) {

    public type Vote = {
        yes: Bool;
        voter: Principal;
    };

    public type VoteResult = {
        yesCount: Nat;
        noCount: Nat;
        proposalResult: Text;
    };

    // public type Dao = actor {
        
    //     start_restrict_proposal: shared () -> async();
    //     start_unrestrict_proposal: shared () -> async();

    //     vote_restrict_proposal: shared (oppion: Bool) -> async VoteResult;
    //     vote_unrestrict_proposal: shared (oppion: Bool) -> async VoteResult;

    //     get_restrict_proposal_result: shared query () -> async VoteResult;
    //     get_unrestrict_proposal_result: shared query () -> async VoteResult;
    //     get_managered_canister: shared query () -> async Principal;
    // };

    let MIN_VOTE_COUNT :Nat = min;
    
    let MEMBERS: [Principal] = members;
    let UNDER_CONTROL : Principal = managedCanisterId;

    var restrictProposalOpen: Bool = false;
    var unrestrictProposalOpen: Bool = false;

    var restrictVoteHistory = List.nil<Vote>();
    var unrestrictVoteHistory = List.nil<Vote>();

    

  private func generateRestrictProposalResult() : VoteResult {
      var yCount: Nat = 0;
      var nCount: Nat = 0;
      var result: Text = "Not start yet!";
      if (List.size<Vote>(restrictVoteHistory) > 0) {
         let yList = List.filter<Vote>(restrictVoteHistory, func (vote: Vote) {
             vote.yes == true;
         });
         let nList = List.filter<Vote>(restrictVoteHistory, func (vote: Vote) {
             vote.yes != true;
         });
         yCount := List.size<Vote>(yList);
         nCount := List.size<Vote>(nList);

        if (yCount == MIN_VOTE_COUNT) {
            result := "restrict proposal passed!";
            if (restrictProposalOpen) {
                restrictProposalOpen := false;
            }
        } else {
            if (yCount == 0 and nCount == 0 and restrictProposalOpen) {
                result := "vote is in progress";
            } else {
                if ((MEMBERS.size() - nCount + yCount) < MIN_VOTE_COUNT) {
                    result := "restrict proposal failed!";
                    if (restrictProposalOpen) {
                        restrictProposalOpen := false;
                    }
                } else {
                    result := "vote is in progress";
                };
            };
        };
      };

      return {
            yesCount = yCount;
            noCount = nCount;
            proposalResult = result;
          };
      
  };

  private func generateUnrestrictProposalResult() : VoteResult {
      var yCount: Nat = 0;
      var nCount: Nat = 0;
      var result: Text = "Not start yet!";
      if (List.size<Vote>(unrestrictVoteHistory) > 0) {
         let yList = List.filter<Vote>(unrestrictVoteHistory, func (vote: Vote) {
             vote.yes == true;
         });
         let nList = List.filter<Vote>(unrestrictVoteHistory, func (vote: Vote) {
             vote.yes != true;
         });
         yCount := List.size<Vote>(yList);
         nCount := List.size<Vote>(nList);

        if (yCount == MIN_VOTE_COUNT) {
            result := "unrestrict proposal passed!";
            if (unrestrictProposalOpen) {
                unrestrictProposalOpen :=  false;
            }
        } else {
            if (yCount == 0 and nCount == 0 and unrestrictProposalOpen) {
                result := "vote is in progress";
            } else {
                if ((MEMBERS.size() - nCount + yCount) < MIN_VOTE_COUNT) {
                    result := "unrestrict proposal failed!";
                    if (unrestrictProposalOpen) {
                        unrestrictProposalOpen :=  false;
                    }
                } else {
                    result := "vote is in progress";
                };
            };
        };
      };

      return {
            yesCount = yCount;
            noCount = nCount;
            proposalResult = result;
          };
      
      
  };


  public func start_restrict_proposal() : async () {
      assert(not restrictProposalOpen and not unrestrictProposalOpen);
      restrictProposalOpen := true;
      restrictVoteHistory := List.nil<Vote>();
  };

  public func start_unrestrict_proposal() : async() {
      assert(not unrestrictProposalOpen and not restrictProposalOpen);
      unrestrictProposalOpen := true;
      unrestrictVoteHistory := List.nil<Vote>();
  };

  public query func get_managered_canister() : async Principal {
      UNDER_CONTROL
  };

  public query func  get_restrict_proposal_result() : async VoteResult {
      generateRestrictProposalResult();
  };

  public query func get_unrestrict_proposal_result() : async VoteResult {
      generateUnrestrictProposalResult();
  };

  public shared (msg) func vote_restrict_proposal(oppion:Bool) : async VoteResult {
      assert(restrictProposalOpen);
      let v = List.find<Vote>(restrictVoteHistory, func (vote:Vote) {
        Principal.equal(vote.voter, msg.caller)
      });
      switch(v) {
          case null {
              let vote:Vote = {yes=oppion; voter=msg.caller;};
              restrictVoteHistory:= List.push<Vote>(vote, restrictVoteHistory);
          };
          case (?v) {

          };
      };
      generateRestrictProposalResult();
  };

  public shared (msg) func vote_unrestrict_proposal(oppion:Bool) : async VoteResult {
      assert(unrestrictProposalOpen);
      let v = List.find<Vote>(unrestrictVoteHistory, func (vote:Vote) {
        Principal.equal(vote.voter, msg.caller)
      });
      switch(v) {
          case null {
              let vote:Vote = {yes=oppion; voter=msg.caller;};
              unrestrictVoteHistory:= List.push<Vote>(vote, unrestrictVoteHistory);
          };
          case (?v) {

          };
      };
      generateUnrestrictProposalResult();
  }

}