import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Nat "mo:base/Nat";

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
    Debug.print(debug_show("left", left, "right", right));
    if (left < right) {
        let partitionIndex = partition(arr, left, right);
        Debug.print(debug_show("partitionIndex", partitionIndex));
        if (partitionIndex > 0 and left < partitionIndex - 1) {
            doQuicksort(arr, left, partitionIndex-1);
        };
        doQuicksort(arr, partitionIndex+1, right);
    }
};

func quicksort(arr: [Int]): [Int] {
    var originalArray: [var Int] = Array.thaw<Int>(arr);

    doQuicksort(originalArray, 0, arr.size() - 1);
        
    let result = Array.freeze<Int>(originalArray);
};

Debug.print(debug_show(quicksort([66,55,33,88,72])));


