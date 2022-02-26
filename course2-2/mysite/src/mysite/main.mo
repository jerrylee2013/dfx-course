import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Array "mo:base/Array";

actor {
    func swap(arr: [var Int], i: Nat, j:Nat) {
        let temp = arr[j];
        arr[j] := arr[i];
        arr[i] := temp;
    };

    func partition(arr: [var Int], left: Nat, right: Nat) : Nat {
        var pivot = left;
        var index = pivot + 1;
        var i = index;
        while (i <= right) {
            if (arr[i] < arr[pivot]) {
                swap(arr, i, index);
                index := index + 1;
            };
            i := i + 1;
        };
        swap(arr, pivot, index - 1);
        index - 1;
    };

    func doQuicksort(arr: [var Int], left: Nat, right: Nat) {
        if (left < right) {
            let partitionIndex = partition(arr, left, right);
            if (partitionIndex > 0 and left < partitionIndex - 1) {
                doQuicksort(arr, left, partitionIndex-1);
            };
            doQuicksort(arr, partitionIndex+1, right);
        }
    };

    func quicksort(arr: [Int]): [Int] {
        if (arr.size() <= 1) {
            return arr;
        };
        var originalArray: [var Int] = Array.thaw<Int>(arr);

        doQuicksort(originalArray, 0, arr.size() - 1);
        
        let result = Array.freeze<Int>(originalArray);
    };

    public func qsort(arr: [Int]): async [Int] {
       quicksort(arr); 
    }
}

