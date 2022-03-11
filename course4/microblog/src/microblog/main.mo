import Time "mo:base/Time";
import List "mo:base/List";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";

actor {
    public type Message = { postTime:Time.Time; text:Text};

    public type Microblog = actor {
        follow: shared(Principal) -> async ();
        follows: shared query () -> async [Principal];
        post: shared(Text) -> async ();
        posts: shared query (Time.Time) -> async [Message];
        timeline: shared (Time.Time) -> async [Message];
    };

    stable var postList = List.nil<Message>();
    stable var followList = List.nil<Principal>();

    public shared (mes) func post(text:Text) : async () {
        assert(Principal.toText(mes.caller) == "2al2t-2jbuy-tn5re-ay3mw-aimky-hqdgv-3rjgx-eepq2-yjkeb-bvxrl-hae");
        let msg:Message = {postTime = Time.now(); text};
        postList := List.push<Message>(msg, postList);
        
    };

    public query func posts(time: Time.Time): async [Message] {
        List.toArray<Message>(List.filter<Message>(postList, func (msg: Message) {
            msg.postTime >= time;
        }));
        
    };
    

    public func follow(id:Principal) {
        let bingo = List.find<Principal>(followList, func (checkId:Principal) {
            checkId == id;
        });
        switch(bingo) {
            case (null) {
                followList := List.push<Principal>(id, followList);
            };
            case (?bingo) {

            };
        };
    };

    public func follows(): async [Principal] {
        List.toArray<Principal>(followList);
    };

    public func timeline(since: Time.Time): async [Message] {
        var all: List.List<Message> = List.nil();
        if (List.isNil(followList)) {
            return [];
        };
        for (id in Iter.fromList(followList)) {
            let canister: Microblog = actor(Principal.toText(id));
            let msgs = await canister.posts(since);
            for (msg in Iter.fromArray(msgs)) {
                all := List.push(msg, all);
            };
        };
        

        return List.toArray(all);
    }
};
