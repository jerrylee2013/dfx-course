import List "mo:base/List";
import Option "mo:base/Option";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import TextLoggers "TextLogger";

import Logger "mo:ic-logger/Logger";

shared(msg) actor class ExpandableTextLogger()  {
  type TextLogger = TextLoggers.TextLogger;
  let ENTRY_SIZE: Nat = 3;
  stable var next_log_position : Nat = 0;
  var logger_history : Buffer.Buffer<TextLogger> = Buffer.Buffer<TextLogger>(100);

  public func append(msgs: [Text]) : async () {
    assert(msgs.size() > 0);
    if (logger_history.size() == 0) {
      let logger = await TextLoggers.TextLogger(next_log_position);
      logger_history.add(logger);
    };
    let logToAppend  = Buffer.Buffer<Text>(ENTRY_SIZE);
    for (log in Iter.fromArray(msgs)) {
      if (Nat.rem(next_log_position, ENTRY_SIZE) == 0) {
        if (logToAppend.size() > 0) {
          await logger_history.get(logger_history.size() - 1).append(logToAppend.toArray());
          logToAppend.clear();
          let newLogger = await TextLoggers.TextLogger(next_log_position);
          logger_history.add(newLogger);
        };
      };
      logToAppend.add(log);
      next_log_position := next_log_position + 1;
    };
    if (logToAppend.size() > 0) {
       await logger_history.get(logger_history.size() - 1).append(logToAppend.toArray());
    };
  };

  public func view(from: Nat, to:  Nat) : async Logger.View<Text> {
    assert(to >= from and to < next_log_position and (next_log_position > 0));
      let startLoggerIndex: Nat = Nat.div(from, ENTRY_SIZE);
      let endLoggerIndex: Nat = Nat.div(to, ENTRY_SIZE);
      var loggerIndex : Nat  = startLoggerIndex;
      var startOffset : Nat = from;
      var endOffset : Nat = (loggerIndex + 1) * ENTRY_SIZE - 1;
      if (endOffset > to) {
        endOffset := to;
      };

      let histories: [TextLogger] = logger_history.toArray();
      var resultList: Buffer.Buffer<Text> = Buffer.Buffer(100);
      loop {
        let logger = histories[loggerIndex];
        let blockResult: Logger.View<Text> = await logger.view(startOffset, endOffset);
        var i : Nat = 0;
        while (i < blockResult.messages.size())  {
          resultList.add(blockResult.messages[i]);
          i := i +1;
        };

        loggerIndex := loggerIndex + 1;
        startOffset := endOffset + 1;
        endOffset := endOffset + ENTRY_SIZE;
        if (endOffset > to) {
          endOffset := to;
        }
      } while (loggerIndex <= endLoggerIndex);
      
      return {
        start_index = from;
        messages = resultList.toArray();
      };
    
  };
};
