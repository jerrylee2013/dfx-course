# dao_wallet

本库为ic进阶课程第三课作业。主要功能包含如下：
main.mo对应的名为dao_wallet的canister，主网部署的canisterid是h4v2w-niaaa-aaaal-qa4iq-cai
其did接口规范如下：

type wasm_module = vec nat8;
type TwoSize = 
 record {
   cans: nat;
   users: nat;
 };
type DaoWallet = 
 service {
   add_user: (principal) -> ();
   create_canister: () -> (principal);
   create_dao: (principal) -> (opt principal);
   delete_canister: (principal) -> ();
   dump_size: () -> (TwoSize);
   get_min_vote_count: () -> (nat) query;
   install_canister: (principal, wasm_module) -> ();
   set_min_vote_count: (nat) -> ();
   start_canister: (principal) -> ();
   stop_canister: (principal) -> ();
   uninstall_canister: (principal) -> ();
 };
service : () -> DaoWallet

其中create_canister，install_canister，start_canister，stop_canister，uninstall_canister，delete_canister封装了ic management对canister的全生命周期的管理。
代码中附带了hello.wasm，它对应的是ic的hello world版canister，可用于调试install_canister，生成后可调用greet('you')查看结果。

而add_user是给dao组织增加用户(目前没有删除用户的接口)
set_min_vote_count是指定dao中，投票通过的最小数量（不能超过dao的用户数)
get_min_vote_count是查看当前最低票数的设置。
dump_size返回一个两个数据，cans是当前通过dao_wallet创建的canister数量；users返回当前dao组织的用户总数。
create_dao将对指定的canister生产一个Dao的canister，对应代码dao.mo（由于课程不要求执行提案，目前dao生成后，对应canister的controller没有修改)。
创建dao时，将采用dao_wallet维护的用户组以及min_vote_count作为参数进行初始化。

Dao的接口如下

 public type Dao = actor {
     // 开启限制提案  
     start_restrict_proposal: shared () -> async();
     // 开启解除限制的提案
     start_unrestrict_proposal: shared () -> async();

     // 对限制提案投票，oppion为true为赞成票，false为反对票
     vote_restrict_proposal: shared (oppion: Bool) -> async VoteResult;
     // 对接触限制提案投票，oppion为true为赞成票，false为反对票
     vote_unrestrict_proposal: shared (oppion: Bool) -> async VoteResult;

     // 获取当前限制提案的投票结果
     get_restrict_proposal_result: shared query () -> async VoteResult;
     // 获取当前解除限制提案的投票结果
     get_unrestrict_proposal_result: shared query () -> async VoteResult;
     // 获取当前dao所管控的canister
     get_managered_canister: shared query () -> async Principal;
};

目前已在主网生成一个dao，id为hjsl3-maaaa-aaaal-qa4la-cai

为模拟投票，分别部署了user1(hvwrk-3aaaa-aaaal-qa4ja-cai),user2(hsxx6-wyaaa-aaaal-qa4jq-cai),user3(hhqgt-xqaaa-aaaal-qa4ka-cai)

User的canister接口如下：
public type VoteResult = {
    yesCount: Nat; // 赞成票数
    noCount: Nat; // 反对票数
    proposalResult: Text;
};
    public type User = actor {
        // 对指定dao的限制提案投票
        voteRestrictProposal: shared(Principal, Bool) -> async VoteResult;
        // 对指定dao的解除限制提案投票
        voteUnrestrictProposal: shared(Principal, Bool) -> async VoteResult;
    };