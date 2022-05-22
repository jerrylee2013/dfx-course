import Principal "mo:base/Principal";
import IC "./ic";
import List "mo:base/List";

actor class () = self {
  public type User = {
    userId: Principal;
    var isActive: Nat;
  };

  public type DaoWallet = actor {
    add_user: shared (Principal) -> async ();
    remove_user: shared (Principal) -> async();
    create_canister: shared () -> async Principal;
    install_canister: shared (Principal, IC.wasm_module) -> async();
    start_canister: shared (Principal) -> async();
    stop_canistr: shared (Principal) -> async();
    uninstall_canister: shared (Principal) -> async();
    delete_canister: shared (Principal) -> async();
  };

  stable var daoUsers = List.nil<User>();
  stable var canisters = List.nil<Principal>();

  public shared func add_user(uId: Principal) : async () {
    let bingo = List.find<User>(daoUsers, func (u:User) {
            u.userId == uId;
    });
    switch(bingo) {
        case (null) {
          let user = {
            userId = uId;
            var isActive:Nat = 1;
          };
          daoUsers := List.push<User>(user, daoUsers);
        };
        case (?bingo) {

        };
    };
  };
  public shared func remove_user(uId: Principal) : async () {
    var bingo = List.find<User>(daoUsers, func (u:User) {
            u.userId == uId;
    });
    switch(bingo) {
        case (null) {
        
        };
        case (?bingo) {
          bingo.isActive := 0;
        };
    };
  };

  public func create_canister() : async Principal {
    let settings = {
      freezing_threshold = null;
      controllers = ?[Principal.fromActor(self)];
      memory_allocation = null;
      compute_allocation = null;
    };
    let ic : IC.Self = actor("aaaaa-aa");
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
