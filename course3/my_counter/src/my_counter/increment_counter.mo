// Create a simple Counter actor.
import Text "mo:base/Text";
import Nat "mo:base/Nat";
actor Counter {

    public type HeaderField = (Text, Text);

    public type HttpRequest = {
        body: Blob;
        headers: [HeaderField];
        method: Text;
        url: Text;
    };

    public type HttpResponse = {
        body: Blob;
        headers: [HeaderField];
        status_code: Nat16;
        streaming_strategy: ?StreamingStrategy;
    };

    public type Key = Text;
    public type Path = Text;
    public type ChunkId = Nat;
    public type SetAssetContentArguments = {
        key: Key;
        sha256:  ?[Nat8];
        chunk_ids: [ChunkId];
        content_encoding: Text;
    };

    public type StreamingCallbackHttpResponse = {
        token: ?StreamingCallbackToken;
        body: [Nat8];
    };

    public type StreamingCallbackToken = {
        key: Text;
        sha256: ?[Nat8];
        index: Nat;
        content_encoding: Text;
    };

    public type StreamingStrategy = {
        #Callback : {
            token: StreamingCallbackToken;
            callback: shared query StreamingCallbackToken -> async StreamingCallbackHttpResponse;
        };
    };


  stable var currentValue : Nat = 0;

  // Increment the counter with the increment function.
  public func increment() : async () {
    currentValue += 1;
  };

  // Read the counter value with a get function.
  public query func get() : async Nat {
    currentValue
  };

  // Write an arbitrary value with a set function.
  public func set(n: Nat) : async () {
    currentValue := n;
  };


    public shared query func http_request(request: HttpRequest): async HttpResponse {
        {
            body = Text.encodeUtf8("<html><body><p>The current value is <em>" # Nat.toText(currentValue) # "</em> </body> </html>");
            headers = [];
            streaming_strategy = null;
            status_code = 200;
        }
    };

}