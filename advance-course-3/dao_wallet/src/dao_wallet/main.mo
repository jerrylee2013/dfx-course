import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import IC "./ic";
import List "mo:base/List";
import TrieMap "mo:base/TrieMap";
import Cycles "mo:base/ExperimentalCycles";
import Dao "dao";
actor class DaoWallet() = self {
  // type Dao = Dao.Dao;
  // public type DaoWallet = actor {
  //   add_user: shared (Principal) -> async ();
  //   // remove_user: shared (Principal) -> async();

  //   create_dao: shared (managedCanisterId: Principal) -> async (Principal);
  //   set_min_vote_count: shared (count: Nat)  -> async ();
  //   get_min_vote_count: shared query () -> async Nat;
  //   create_canister: shared () -> async Principal;
  //   install_canister: shared (Principal, IC.wasm_module) -> async();
  //   start_canister: shared (Principal) -> async();
  //   stop_canistr: shared (Principal) -> async();
  //   uninstall_canister: shared (Principal) -> async();
  //   delete_canister: shared (Principal) -> async();
  //   // execute_restrict_proposal: shared ()
  // };
  public type TwoSize = {
    cans: Nat;
    users: Nat;
  };
  stable var canisters = List.nil<Principal>();
  stable var daoUsers = List.nil<Principal>();
  // List.fromArray<Principal>([Principal.fromText("ryjl3-tyaaa-aaaaa-aaaba-cai"),
  // Principal.fromText("r7inp-6aaaa-aaaaa-aaabq-cai"),
  // Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai")
  // ]);
  var daoes = TrieMap.TrieMap<Principal,Principal>(func(k1:Principal, k2:Principal) {
    Principal.equal(k1,k2)
  }, func(k: Principal) {Principal.hash(k)});
  var minVoteCount:Nat = 0;

  public shared func add_user(uId: Principal) : async () {
    let bingo = List.find<Principal>(daoUsers, func (u:Principal) {
            Principal.equal(u, uId);
    });
    switch(bingo) {
        case (null) {
          // let user = {
          //   userId = uId;
          //   var isActive:Nat = 1;
          // };
          daoUsers := List.push<Principal>(uId, daoUsers);
        };
        case (?bingo) {

        };
    };
  };
  // public shared func remove_user(uId: Principal) : async () {
  //   var bingo = List.find<User>(daoUsers, func (u:User) {
  //           u.userId == uId;
  //   });
  //   switch(bingo) {
  //       case (null) {
        
  //       };
  //       case (?bingo) {
  //         bingo.isActive := 0;
  //       };
  //   };
  // };

  public func dump_size() : async TwoSize {
    var cs:Nat = 0;
    var us:Nat = 0;

    if (not List.isNil<Principal>(canisters)) {
      cs := List.size<Principal>(canisters);
    };
    if (not List.isNil<Principal>(daoUsers)) {
      us := List.size<Principal>(daoUsers);
    };

    return {
      cans = cs;
      users = us;
    };
  };

  public func create_dao(managedCanisterId: Principal) : async (?Principal) {
    assert(minVoteCount > 0 and not List.isNil<Principal>(daoUsers) and not List.isNil<Principal>(canisters) and minVoteCount <= List.size<Principal>(daoUsers) and List.size<Principal>(canisters) > 0);
    // check if the canister exits
    let canister = List.find<Principal>(canisters, func (can:Principal) {
        Principal.equal(can, managedCanisterId);
      });

    switch(canister) {
      case null {
        return null;
      };
      case (?canister) {
        // check if the dao has already been created
        let dao:?Principal = daoes.get(canister);

        switch(dao) {

          case null {
            Cycles.add(1_000_000_000_000);
            let can = await Dao.Dao(managedCanisterId, minVoteCount, List.toArray<Principal>(daoUsers));
        
            let newDao:Principal = Principal.fromActor(can);
            daoes.put(canister, newDao);
            // let ic : IC.Self = actor("aaaaa-aa");
            // let settings = {
            //   freezing_threshold = null;
            //   controllers = ?[newDao];
            //   memory_allocation = null;
            //   compute_allocation = null;
            // };
            // await ic.update_settings({canister_id = canister; settings = settings});

            return ?newDao;
          };
          case (?dao) {
            return ?dao;
          }
        }
      }
    }
  };

  public func set_min_vote_count(count:Nat) : async() {
    assert(count > 0 and count <= List.size<Principal>(daoUsers));
    minVoteCount := count;
  };

  public query func get_min_vote_count() : async Nat {
    minVoteCount;
  };

  public func create_canister() : async Principal {
    let settings = {
      freezing_threshold = null;
      controllers = ?[Principal.fromActor(self)];
      memory_allocation = null;
      compute_allocation = null;
    };
    let ic : IC.Self = actor("aaaaa-aa");
    Cycles.add(1_000_000_000_000);
    let result = await ic.create_canister({settings = ?settings});
    canisters := List.push<Principal>(result.canister_id, canisters);
    result.canister_id
  };

  public shared (mes) func install_canister(id: Principal, wasm: IC.wasm_module) : async () {
    let ic : IC.Self = actor("aaaaa-aa");
    await ic.install_code({
      canister_id=id;
      mode=#install;
      arg=[];
      wasm_module=wasm;
    });

  };

  public shared (mes) func start_canister(id: Principal) : async () {
    let ic : IC.Self = actor("aaaaa-aa");
    await ic.start_canister({canister_id=id;});
  };

  public shared (mes) func stop_canister(id: Principal) : async () {
    let ic : IC.Self = actor("aaaaa-aa");
    await ic.stop_canister({canister_id=id;});
  };

  public shared (mes) func uninstall_canister(id: Principal) : async () {
    let ic : IC.Self = actor("aaaaa-aa");
    await ic.uninstall_code({canister_id=id;});
  };

  public shared (mes) func delete_canister(id: Principal) : async() {
    let ic : IC.Self = actor("aaaaa-aa");
    await ic.delete_canister({canister_id=id;});
  };
  
};
