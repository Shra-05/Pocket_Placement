// Attaches animated visuals to intuition challenges (matched by problem title).
// Run from the pocket_placement_backend folder:  node seedVisuals.js
// Safe to re-run. It only sets intuitionChallenges.<n>.visual and never touches
// questions, options or feedback. Problems that are not in the database are skipped.
//
// Tree values use HEAP layout: the children of index i are 2i+1 and 2i+2,
// and null means "no node here". Step fields (hl / ok / bad / tags / aux / out)
// are explained at the top of lib/features/dsa_world/widgets/challenge_visual.dart.

try {
  require("./src/dns-fix");
} catch (e) {
  require("dns").setServers(["8.8.8.8", "8.8.4.4"]);
}

const DB_NAME = "Pocket_Placement_DSA";
const COLLECTION = "dsaproblems";

const N = null;
const T = (values, steps, extra = {}) => ({ type: "tree", values, steps, ...extra });
const A = (values, steps) => ({ type: "array", values, steps });
const s = (caption, o = {}) => ({ caption, ...o });
const q = (items) => ({ label: "queue", items });

// Reused trees
const LEVEL_TREE = [3, 9, 20, N, N, 15, 7];
const BST7 = [4, 2, 6, 1, 3, 5, 7];

const visuals = {
  // ===============================================================
  // BATCH 1: Arrays (problems 1 to 8)
  // ===============================================================

  // ---------------------------------------------------------------
  "Two Sum": [
    A([2, 11, 15, 7], [
      s("Target is 9. Brute force: pair the first number with each number after it.", {
        hl: [0, 1], ptrs: { i: 0, j: 1 }, tags: { 1: "2+11=13" },
      }),
      s("Next pair: 2 and 15 is 17. Still not 9.", {
        bad: [1], hl: [0, 2], ptrs: { i: 0, j: 2 }, tags: { 2: "2+15=17" },
      }),
      s("Next pair: 2 and 7 is 9. Found it, after three checks.", {
        bad: [1, 2], ok: [0, 3], ptrs: { i: 0, j: 3 }, tags: { 3: "2+7=9" },
      }),
      s("Every number gets paired with every number after it. What happens to the work as the array grows?", {
        hl: [0, 1, 2, 3],
      }),
    ]),
    A([3, 2, 4], [
      s("Target is 6. At 3 we need another 3. Nothing is remembered yet.", {
        hl: [0], ptrs: { i: 0 }, aux: { label: "seen", items: [] },
      }),
      s("There is no other 3. Remember 3 (at index 0) and move on.", {
        hl: [0], ptrs: { i: 0 }, aux: { label: "seen", items: ["3→0"] },
      }),
      s("At 2 we need 4. Have we seen 4? No. Remember 2.", {
        hl: [1], ptrs: { i: 1 }, aux: { label: "seen", items: ["3→0", "2→1"] },
      }),
      s("At 4 we need 2. We remembered 2 earlier, and it was one lookup away.", {
        ok: [1], hl: [2], ptrs: { i: 2 }, aux: { label: "seen", items: ["3→0", "2→1"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Best Time to Buy and Sell Stock": [
    A([7, 1, 5, 3, 6, 4], [
      s("These are prices by day. We buy on one day and sell on a later day.", {}),
      s("Day 0 costs 7. The lowest price so far is 7.", {
        hl: [0], ptrs: { day: 0 }, tags: { 0: "low 7" },
      }),
      s("Day 1 costs 1. That is cheaper, so it becomes the lowest so far.", {
        hl: [1], ptrs: { day: 1 }, tags: { 1: "low 1" },
      }),
      s("Day 2 costs 5. Selling here after buying at 1 earns 4.", {
        ok: [1], hl: [2], ptrs: { day: 2 }, tags: { 1: "buy", 2: "+4" },
      }),
      s("Day 4 costs 6. Selling here earns 5. What did we have to remember to know this?", {
        ok: [1], hl: [4], ptrs: { day: 4 }, tags: { 1: "buy", 4: "+5" },
      }),
    ]),
    A([3, 8, 1, 2], [
      s("The highest price here is 8 and the lowest is 1.", { hl: [1, 2] }),
      s("But 8 comes before 1. We must buy first and sell later.", {
        bad: [1, 2], tags: { 1: "day 1", 2: "day 2" },
      }),
      s("Buy at 1, sell at 2: that earns only 1.", {
        ok: [2], hl: [3], tags: { 2: "buy", 3: "sell" },
      }),
      s("Buy at 3, sell at 8 earns 5. Is the best deal always lowest to highest?", {
        ok: [0, 1], tags: { 0: "buy", 1: "sell" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Contains Duplicate": [
    A([1, 2, 3, 1], [
      s("Walk through once. We keep every number we have seen in a set.", {
        ptrs: { i: 0 }, aux: { label: "seen", items: [] },
      }),
      s("At 1: not seen before. Add it.", {
        hl: [0], ptrs: { i: 0 }, aux: { label: "seen", items: ["1"] },
      }),
      s("At 2: not seen. Add it.", {
        ok: [0], hl: [1], ptrs: { i: 1 }, aux: { label: "seen", items: ["1", "2"] },
      }),
      s("At 3: not seen. Add it.", {
        ok: [0, 1], hl: [2], ptrs: { i: 2 }, aux: { label: "seen", items: ["1", "2", "3"] },
      }),
      s("At 1 again: have we seen it? Look at the set.", {
        ok: [0, 1, 2], hl: [3], ptrs: { i: 3 }, aux: { label: "seen", items: ["1", "2", "3"] },
      }),
    ]),
    A([3, 1, 2, 1], [
      s("Two 1s hide in this array, far apart.", { hl: [1, 3] }),
      s("Comparing only neighbors, the pairs are (3,1), (1,2), (2,1). None match.", {
        bad: [0, 1, 2], ptrs: { a: 0, b: 1 },
      }),
      s("Now sort the array. Equal numbers end up side by side.", {
        values: [1, 1, 2, 3], hl: [0, 1],
      }),
      s("Look along the sorted row. What would a duplicate look like here?", {
        values: [1, 1, 2, 3],
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Product of Array Except Self": [
    A([1, 2, 3, 4], [
      s("For each spot we want the product of every other number.", {
        hl: [2], tags: { 2: "skip me" },
      }),
      s("Everything to the left of 3 is 1 and 2. Their product is 2.", {
        ok: [0, 1], hl: [2], tags: { 2: "left 2" },
      }),
      s("Everything to the right of 3 is just 4. Its product is 4.", {
        ok: [3], hl: [2], tags: { 2: "right 4" },
      }),
      s("Left times right is 2 × 4 = 8. How can we get both sides for every spot without redoing the work?", {
        ok: [0, 1, 3], hl: [2], tags: { 2: "2 × 4" },
      }),
    ]),
    A([1, 2, 3, 4], [
      s("Pass 1, left to right: each spot stores the product of the numbers before it.", {
        hl: [0], ptrs: { i: 0 }, aux: { label: "left", items: ["1"] },
      }),
      s("Before 2 there is only 1.", {
        ok: [0], hl: [1], ptrs: { i: 1 }, aux: { label: "left", items: ["1", "1"] },
      }),
      s("Before 3 we have 1 × 2 = 2.", {
        ok: [0, 1], hl: [2], ptrs: { i: 2 }, aux: { label: "left", items: ["1", "1", "2"] },
      }),
      s("Before 4 we have 1 × 2 × 3 = 6.", {
        ok: [0, 1, 2], hl: [3], ptrs: { i: 3 },
        aux: { label: "left", items: ["1", "1", "2", "6"] },
      }),
      s("The numbers on the right are still missing. What must a second pass carry along?", {
        ok: [0, 1, 2, 3], aux: { label: "left", items: ["1", "1", "2", "6"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Maximum Subarray": [
    A([-2, 1, -3, 4, -1, 2, 1, -5, 4], [
      s("Keep a running sum as we walk. At -2 the sum is -2.", {
        hl: [0], ptrs: { i: 0 }, tags: { 0: "sum -2" },
      }),
      s("Carrying -2 into 1 would give -1, worse than 1 alone. Start fresh at 1.", {
        bad: [0], hl: [1], ptrs: { i: 1 }, tags: { 1: "fresh 1" },
      }),
      s("At -3 the sum drops to -2. Carrying that forward only hurts.", {
        ok: [1], bad: [2], ptrs: { i: 2 }, tags: { 2: "sum -2" },
      }),
      s("Now at 4, should we carry that -2 along, or start over?", {
        hl: [3], ptrs: { i: 3 }, tags: { 3: "carry -2?" },
      }),
    ]),
    A([-2, 1, -3, 4, -1, 2, 1, -5, 4], [
      s("Start the window at 4. The window sum is 4.", {
        hl: [3], tags: { 3: "4" }, out: "best 4",
      }),
      s("Add -1. The window is now 3. It dipped, but the best stays 4.", {
        ok: [3], hl: [4], tags: { 4: "3" }, out: "best 4",
      }),
      s("Add 2, then 1. The window grows to 5, then 6.", {
        ok: [3, 4, 5, 6], tags: { 5: "5", 6: "6" }, out: "best 6",
      }),
      s("Add -5. The window falls to 1. Does the best sum fall too?", {
        ok: [3, 4, 5, 6], bad: [7], tags: { 7: "1" }, out: "best 6",
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Move Zeroes": [
    A([0, 1, 0, 3, 12], [
      s("Two pointers start at the front: one reads, one marks where the next non-zero goes.", {
        ptrs: { read: 0, write: 0 },
      }),
      s("0 is a zero. Reader moves on, writer stays.", {
        bad: [0], ptrs: { read: 1, write: 0 },
      }),
      s("1 is not zero, so it swaps into the writer's spot. Writer moves forward.", {
        values: [1, 0, 0, 3, 12], ok: [0], hl: [1], ptrs: { read: 1, write: 1 },
      }),
      s("Reader skips the zero and finds 3. It swaps into the writer's spot.", {
        values: [1, 3, 0, 0, 12], ok: [0, 1], ptrs: { read: 3, write: 2 },
      }),
      s("12 swaps in the same way. Look at where the zeros ended up.", {
        values: [1, 3, 12, 0, 0], ok: [0, 1, 2], hl: [3, 4], ptrs: { read: 4, write: 3 },
      }),
    ]),
    A([0, 1, 0, 3, 12], [
      s("The non-zero numbers 1, 3, 12 appear in this order.", {
        hl: [1, 3, 4], tags: { 1: "1st", 3: "2nd", 4: "3rd" },
      }),
      s("After moving zeroes, they must still appear in that same order.", {
        values: [1, 3, 12, 0, 0], ok: [0, 1, 2], tags: { 0: "1st", 1: "2nd", 2: "3rd" },
      }),
      s("Try something else: swap the first zero with the last number.", {
        values: [12, 1, 0, 3, 0], bad: [0], tags: { 0: "12 first" },
      }),
      s("Now 12 comes before 1 and 3. Does the order still match what we need?", {
        values: [12, 1, 0, 3, 0], bad: [0, 1, 3],
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Merge Sorted Array": [
    A([1, 2, 3, 0, 0, 0], [
      s("The first array has empty room at the end (the 0s). The second array waits on the side.", {
        hl: [3, 4, 5], aux: { label: "nums2", items: ["2", "5", "6"] },
      }),
      s("Suppose we start filling from the front. The first spot holds a 1.", {
        hl: [0], ptrs: { write: 0 }, tags: { 0: "in use" },
        aux: { label: "nums2", items: ["2", "5", "6"] },
      }),
      s("Writing there would erase a number we still need.", {
        bad: [0], ptrs: { write: 0 }, aux: { label: "nums2", items: ["2", "5", "6"] },
      }),
      s("The back of the array is free. Which end should we fill first, and with which number?", {
        hl: [5], tags: { 5: "free" }, aux: { label: "nums2", items: ["2", "5", "6"] },
      }),
    ]),
    A([1, 2, 3, 0, 0, 0], [
      s("Compare the last real number of each list: 3 and 6.", {
        hl: [2], ptrs: { a: 2 }, aux: { label: "nums2", items: ["2", "5", "6"] },
      }),
      s("6 is bigger. It belongs in the very last spot.", {
        values: [1, 2, 3, 0, 0, 6], ok: [5], aux: { label: "nums2", items: ["2", "5"] },
      }),
      s("Compare 3 and 5. 5 is bigger, so it takes the next spot from the back.", {
        values: [1, 2, 3, 0, 5, 6], ok: [4, 5], hl: [2], ptrs: { a: 2 },
        aux: { label: "nums2", items: ["2"] },
      }),
      s("Compare 3 and 2. Which one goes into the next free spot?", {
        values: [1, 2, 3, 0, 5, 6], ok: [4, 5], hl: [2, 3], ptrs: { a: 2 },
        aux: { label: "nums2", items: ["2"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Rotate Array": [
    A([1, 2, 3, 4, 5, 6, 7], [
      s("Rotate right by 3: every number moves 3 places to the right.", { hl: [0] }),
      s("1 at index 0 lands at index 3.", {
        ok: [0], hl: [3], tags: { 0: "from", 3: "to" },
      }),
      s("5 at index 4 would land at index 7, but the array ends at index 6.", {
        bad: [4], tags: { 4: "4+3=7" },
      }),
      s("It wraps around to the front, index 0. How can we find the landing spot for any index?", {
        ok: [4], hl: [0], tags: { 4: "from", 0: "to" },
      }),
    ]),
    A([1, 2, 3, 4, 5, 6, 7], [
      s("We start with 1 to 7. The goal is 5 6 7 1 2 3 4.", {}),
      s("Flip the whole array. The last 3 numbers are now in front, but backwards.", {
        values: [7, 6, 5, 4, 3, 2, 1], hl: [0, 1, 2],
      }),
      s("Flip just the first 3 numbers.", {
        values: [5, 6, 7, 4, 3, 2, 1], ok: [0, 1, 2], hl: [3, 4, 5, 6],
      }),
      s("Flip the remaining 4 numbers.", {
        values: [5, 6, 7, 1, 2, 3, 4], ok: [0, 1, 2, 3, 4, 5, 6],
      }),
      s("Why did three flips do the job of a rotation?", {
        values: [5, 6, 7, 1, 2, 3, 4],
      }),
    ]),
  ],

  // ===============================================================
  // BATCH 2: Arrays and Strings (problems 9 to 16)
  // ===============================================================

  // ---------------------------------------------------------------
  "Majority Element": [
    A([2, 2, 1, 1, 1, 2, 2], [
      s("Think of each number as a vote. Different numbers cancel each other out.", {
        aux: { label: "candidate", items: [] },
      }),
      s("2 and 2 are the same, so the candidate 2 gains strength.", {
        hl: [0, 1], ptrs: { i: 1 }, aux: { label: "candidate", items: ["2", "count 2"] },
      }),
      s("A 1 arrives. One vote for 1 cancels one vote for 2.", {
        ok: [0], bad: [1, 2], ptrs: { i: 2 }, aux: { label: "candidate", items: ["2", "count 1"] },
      }),
      s("Another 1 cancels the last 2. The count drops to zero.", {
        bad: [0, 1, 2, 3], ptrs: { i: 3 }, aux: { label: "candidate", items: ["none", "count 0"] },
      }),
      s("At zero we start fresh with 1. Can a true majority ever be wiped out by all the others?", {
        hl: [4], ptrs: { i: 4 }, aux: { label: "candidate", items: ["1", "count 1"] },
      }),
    ]),
    A([3, 2, 3], [
      s("Count each number in a map as we walk. The array has 3 numbers.", {
        ptrs: { i: 0 }, aux: { label: "counts", items: [] },
      }),
      s("We see 3, so we write 3→1.", {
        hl: [0], ptrs: { i: 0 }, aux: { label: "counts", items: ["3→1"] },
      }),
      s("We see 2, so we write 2→1.", {
        ok: [0], hl: [1], ptrs: { i: 1 }, aux: { label: "counts", items: ["3→1", "2→1"] },
      }),
      s("We see 3 again, so 3 goes up to 2.", {
        hl: [2], ptrs: { i: 2 }, aux: { label: "counts", items: ["3→2", "2→1"] },
      }),
      s("Half of 3 numbers is 1.5. Which count is more than half?", {
        ok: [0, 2], aux: { label: "counts", items: ["3→2", "2→1"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Container With Most Water": [
    A([1, 8, 6, 2, 5, 4, 8, 3, 7], [
      s("Each number is a wall. Two walls and the gap between them form a container.", {
        hl: [0, 8], ptrs: { l: 0, r: 8 },
      }),
      s("Walls 1 and 7 are 8 apart. Water can only rise to the shorter wall, so 8 × 1 = 8.", {
        hl: [0, 8], ptrs: { l: 0, r: 8 }, tags: { 0: "short", 8: "7" },
      }),
      s("Pull the right wall in to 3. The gap is 7, but water still stops at the 1: area 7.", {
        hl: [0, 7], bad: [8], ptrs: { l: 0, r: 7 }, tags: { 0: "short", 7: "3" },
      }),
      s("Every step in costs us width. Which wall should move to have any chance of more water?", {
        hl: [0, 7], ptrs: { l: 0, r: 7 }, tags: { 0: "1", 7: "3" },
      }),
    ]),
    A([1, 8, 6, 2, 5, 4, 8, 3, 7], [
      s("Move the left wall off the short 1. Now the walls are 8 and 7.", {
        bad: [0], hl: [1, 8], ptrs: { l: 1, r: 8 }, tags: { 1: "8", 8: "7" },
      }),
      s("The shorter wall is 7 and the gap is 7, so the area is 7 × 7 = 49.", {
        bad: [0], ok: [1, 8], ptrs: { l: 1, r: 8 }, tags: { 1: "8", 8: "7" }, out: "best 49",
      }),
      s("The old wall of height 1 is behind us for good.", {
        bad: [0], ok: [1, 8], ptrs: { l: 1, r: 8 }, out: "best 49",
      }),
      s("Could any container that uses that wall ever beat 49?", {
        bad: [0], hl: [1, 8], ptrs: { l: 1, r: 8 }, tags: { 0: "max 8×1" }, out: "best 49",
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Valid Anagram": [
    A(["r", "a", "t"], [
      s("Count every letter of the first word, 'rat'.", {
        ptrs: { i: 0 }, aux: { label: "counts", items: [] },
      }),
      s("r is counted.", {
        hl: [0], ptrs: { i: 0 }, aux: { label: "counts", items: ["r:1"] },
      }),
      s("Then a.", {
        ok: [0], hl: [1], ptrs: { i: 1 }, aux: { label: "counts", items: ["r:1", "a:1"] },
      }),
      s("Then t. All three letters are counted.", {
        ok: [0, 1], hl: [2], ptrs: { i: 2 }, aux: { label: "counts", items: ["r:1", "a:1", "t:1"] },
      }),
      s("Now the second word is 'car'. We use up its letters from the counts.", {
        values: ["c", "a", "r"], hl: [0], ptrs: { i: 0 },
        aux: { label: "counts", items: ["r:1", "a:1", "t:1"] },
      }),
      s("The letter c was never counted. What does that say about the two words?", {
        values: ["c", "a", "r"], bad: [0], ptrs: { i: 0 },
        aux: { label: "counts", items: ["r:1", "a:1", "t:1"] },
      }),
    ]),
    A(["n", "a", "g", "a", "r", "a", "m"], [
      s("Two words are anagrams when they are built from the same letters.", {
        hl: [0, 1, 2, 3, 4, 5, 6],
      }),
      s("Sort the letters of 'nagaram' into alphabetical order.", {
        values: ["a", "a", "a", "g", "m", "n", "r"], hl: [0, 1, 2, 3, 4, 5, 6],
      }),
      s("Now sort 'anagram' as well. It gives exactly the same row.", {
        values: ["a", "a", "a", "g", "m", "n", "r"], ok: [0, 1, 2, 3, 4, 5, 6],
      }),
      s("Two rows came out identical. What does that tell us about the words?", {
        values: ["a", "a", "a", "g", "m", "n", "r"], ok: [0, 1, 2, 3, 4, 5, 6],
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Valid Palindrome": [
    A(["r", "a", "c", "e", "c", "a", "r"], [
      s("A palindrome reads the same from both ends. Put one pointer at each end.", {
        ptrs: { l: 0, r: 6 },
      }),
      s("r and r match. Both pointers step inward.", {
        ok: [0, 6], hl: [0, 6], ptrs: { l: 0, r: 6 },
      }),
      s("a and a match. Step inward again.", {
        ok: [0, 6], hl: [1, 5], ptrs: { l: 1, r: 5 },
      }),
      s("c and c match. One more step.", {
        ok: [0, 1, 5, 6], hl: [2, 4], ptrs: { l: 2, r: 4 },
      }),
      s("The pointers meet at e. Every pair matched. What can we say about the word?", {
        ok: [0, 1, 2, 4, 5, 6], hl: [3], ptrs: { l: 3, r: 3 },
      }),
    ]),
    A(["a", "!", "b", "b", "?", "a"], [
      s("Only letters and digits count. Start with a pointer at each end.", {
        ptrs: { l: 0, r: 5 },
      }),
      s("a and a match. Step inward.", {
        ok: [0, 5], hl: [0, 5], ptrs: { l: 0, r: 5 },
      }),
      s("The left pointer lands on !, which is not a letter. We skip it.", {
        ok: [0, 5], bad: [1], ptrs: { l: 1, r: 4 },
      }),
      s("The right pointer lands on ?. We skip that too.", {
        ok: [0, 5], bad: [1, 4], hl: [2], ptrs: { l: 2, r: 4 },
      }),
      s("Now b meets b. The skipped marks never entered the comparison.", {
        ok: [0, 5], bad: [1, 4], hl: [2, 3], ptrs: { l: 2, r: 3 },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Longest Substring Without Repeating Characters": [
    A(["a", "b", "c", "a", "b", "c", "b", "b"], [
      s("Slide a window along the string. Inside it, no letter may appear twice.", {
        hl: [0], ptrs: { l: 0, r: 0 }, aux: { label: "window", items: ["a"] },
      }),
      s("b is new, so the window grows.", {
        ok: [0], hl: [1], ptrs: { l: 0, r: 1 }, aux: { label: "window", items: ["a", "b"] },
      }),
      s("c is new too. The window holds 3 different letters.", {
        ok: [0, 1], hl: [2], ptrs: { l: 0, r: 2 }, aux: { label: "window", items: ["a", "b", "c"] },
      }),
      s("Next comes a, but the window already has an a. What should happen to the window?", {
        ok: [0, 1, 2], bad: [3], ptrs: { l: 0, r: 3 }, aux: { label: "window", items: ["a", "b", "c"] },
      }),
    ]),
    A(["a", "b", "c", "a", "b", "c", "b", "b"], [
      s("The new a at index 3 clashes with the old a at index 0.", {
        bad: [0, 3], ok: [1, 2], ptrs: { l: 0, r: 3 }, aux: { label: "window", items: ["a", "b", "c"] },
      }),
      s("We drop the old a from the left. The window is now b, c, a.", {
        bad: [0], ok: [1, 2, 3], ptrs: { l: 1, r: 3 }, aux: { label: "window", items: ["b", "c", "a"] },
      }),
      s("Next b at index 4 clashes with the old b at index 1.", {
        bad: [1, 4], ok: [2, 3], ptrs: { l: 1, r: 4 }, aux: { label: "window", items: ["b", "c", "a"] },
      }),
      s("We drop the old b. The window slides on, still free of repeats.", {
        bad: [1], ok: [2, 3, 4], ptrs: { l: 2, r: 4 }, aux: { label: "window", items: ["c", "a", "b"] },
      }),
      s("The window never restarts from scratch. Why is it safe to keep c and a?", {
        ok: [2, 3, 4], hl: [2, 3], ptrs: { l: 2, r: 4 }, aux: { label: "window", items: ["c", "a", "b"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Reverse String": [
    A(["h", "e", "l", "l", "o"], [
      s("Put one pointer at the front and one at the back.", {
        hl: [0, 4], ptrs: { l: 0, r: 4 },
      }),
      s("Swap the two letters. h and o trade places.", {
        values: ["o", "e", "l", "l", "h"], ok: [0, 4], ptrs: { l: 0, r: 4 },
      }),
      s("Both pointers step toward the middle.", {
        values: ["o", "e", "l", "l", "h"], ok: [0, 4], hl: [1, 3], ptrs: { l: 1, r: 3 },
      }),
      s("Swap again. e and l trade places.", {
        values: ["o", "l", "l", "e", "h"], ok: [0, 1, 3, 4], ptrs: { l: 1, r: 3 },
      }),
      s("The pointers now meet on the middle l. Does it need a swap?", {
        values: ["o", "l", "l", "e", "h"], ok: [0, 1, 3, 4], hl: [2], ptrs: { l: 2, r: 2 },
      }),
    ]),
    A(["h", "e", "l", "l", "o"], [
      s("Idea one: copy the letters backwards into a second array.", {
        hl: [4], aux: { label: "new array", items: ["o"] },
      }),
      s("We keep going from the back to the front.", {
        ok: [4], hl: [2, 3], aux: { label: "new array", items: ["o", "l", "l"] },
      }),
      s("The second array ends up as big as the word.", {
        ok: [0, 1, 2, 3, 4], aux: { label: "new array", items: ["o", "l", "l", "e", "h"] },
      }),
      s("Idea two: swap inside the same array. One spare slot holds a letter while two trade.", {
        hl: [0, 4], aux: { label: "spare slot", items: ["h"] },
      }),
      s("Which idea needs more memory as the word grows longer?", {
        hl: [0, 4], aux: { label: "spare slot", items: ["h"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "First Unique Character in a String": [
    A(["l", "e", "e", "t", "c", "o", "d", "e"], [
      s("First pass: count how many times each letter appears.", {
        ptrs: { i: 0 }, aux: { label: "counts", items: [] },
      }),
      s("After l, e, e the counts are l:1 and e:2.", {
        ok: [0, 1, 2], ptrs: { i: 2 }, aux: { label: "counts", items: ["l:1", "e:2"] },
      }),
      s("After the whole word, e has shown up 3 times. The others once.", {
        ok: [0, 1, 2, 3, 4, 5, 6, 7], ptrs: { i: 7 },
        aux: { label: "counts", items: ["l:1", "e:3", "t:1", "c:1", "o:1", "d:1"] },
      }),
      s("Second pass: read the word from the left and look up each count.", {
        hl: [0], ptrs: { i: 0 },
        aux: { label: "counts", items: ["l:1", "e:3", "t:1", "c:1", "o:1", "d:1"] },
      }),
      s("The first letter has a count of 1. Do we need to read any further?", {
        hl: [0], ptrs: { i: 0 }, tags: { 0: "count 1" },
        aux: { label: "counts", items: ["l:1", "e:3", "t:1", "c:1", "o:1", "d:1"] },
      }),
    ]),
    A(["a", "a", "b", "c", "c", "d"], [
      s("Two letters here appear only once: b and d.", {
        hl: [2, 5], tags: { 2: "once", 5: "once" },
      }),
      s("The counts tell us b:1 and d:1, but not which one comes first.", {
        hl: [2, 5], aux: { label: "counts", items: ["a:2", "b:1", "c:2", "d:1"] },
      }),
      s("So we read the word again from the left. a has a count of 2.", {
        bad: [0], ptrs: { i: 0 }, aux: { label: "counts", items: ["a:2", "b:1", "c:2", "d:1"] },
      }),
      s("The next a also has a count of 2, so we move on.", {
        bad: [0, 1], ptrs: { i: 1 }, aux: { label: "counts", items: ["a:2", "b:1", "c:2", "d:1"] },
      }),
      s("Then b, with a count of 1. Why did we read the string again instead of the counts?", {
        bad: [0, 1], hl: [2], ptrs: { i: 2 }, aux: { label: "counts", items: ["a:2", "b:1", "c:2", "d:1"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Group Anagrams": [
    A(["eat", "tea", "tan", "ate", "nat", "bat"], [
      s("Sort the letters inside each word to make a key. eat becomes aet.", {
        hl: [0], tags: { 0: "aet" },
      }),
      s("tea also sorts to aet.", {
        ok: [0], hl: [1], tags: { 0: "aet", 1: "aet" },
      }),
      s("tan sorts to ant, a different key.", {
        ok: [0, 1], hl: [2], tags: { 0: "aet", 1: "aet", 2: "ant" },
      }),
      s("ate sorts to aet again.", {
        ok: [0, 1], hl: [3], tags: { 0: "aet", 1: "aet", 2: "ant", 3: "aet" },
      }),
      s("Words with the same key belong together. What groups do you see?", {
        ok: [0, 1, 3], hl: [2, 4], tags: { 0: "aet", 1: "aet", 2: "ant", 3: "aet", 4: "ant", 5: "abt" },
      }),
    ]),
    A(["eat", "tea", "tan"], [
      s("Another kind of key: count each letter instead of sorting. eat has a1 e1 t1.", {
        hl: [0], tags: { 0: "a1e1t1" },
      }),
      s("tea has the same counts, so the same key.", {
        ok: [0], hl: [1], tags: { 0: "a1e1t1", 1: "a1e1t1" },
      }),
      s("tan has a1 n1 t1, a different key.", {
        ok: [0, 1], hl: [2], tags: { 0: "a1e1t1", 1: "a1e1t1", 2: "a1n1t1" },
      }),
      s("Both kinds of key group the same words. Which one is cheaper for very long words?", {
        ok: [0, 1], hl: [2], tags: { 0: "a1e1t1", 1: "a1e1t1", 2: "a1n1t1" },
      }),
    ]),
  ],

  // ===============================================================
  // BATCH 3: Strings and Binary Search (problems 17 to 24)
  // ===============================================================

  // ---------------------------------------------------------------
  "Longest Common Prefix": [
    A(["flower", "flow", "flight"], [
      s("Take the first word as our starting prefix.", {
        hl: [0], aux: { label: "prefix", items: ["flower"] },
      }),
      s("Compare with flow. They share only flow, so the prefix shrinks.", {
        ok: [0], hl: [1], aux: { label: "prefix", items: ["flow"] },
      }),
      s("Compare with flight. It shares only fl with our prefix.", {
        ok: [0, 1], hl: [2], aux: { label: "prefix", items: ["fl"] },
      }),
      s("With every new word the prefix could only shrink. Why can it never grow?", {
        ok: [0, 1, 2], aux: { label: "prefix", items: ["fl"] },
      }),
    ]),
    A(["flower", "flow", "flight"], [
      s("Another way: look at one letter position at a time, across all words.", {
        hl: [0, 1, 2],
      }),
      s("Position 1: f, f, f. All the same, so we keep going.", {
        ok: [0, 1, 2], tags: { 0: "f", 1: "f", 2: "f" }, aux: { label: "prefix", items: ["f"] },
      }),
      s("Position 2: l, l, l. Still all the same.", {
        ok: [0, 1, 2], tags: { 0: "l", 1: "l", 2: "l" }, aux: { label: "prefix", items: ["f", "l"] },
      }),
      s("Position 3: o, o, i. One word disagrees. Where does the shared part end?", {
        bad: [2], hl: [0, 1], tags: { 0: "o", 1: "o", 2: "i" },
        aux: { label: "prefix", items: ["f", "l"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Longest Palindromic Substring": [
    A(["b", "a", "b", "a", "d"], [
      s("A palindrome grows outward from its middle. Pick the middle letter a.", {
        hl: [1], ptrs: { l: 1, r: 1 },
      }),
      s("Step one place out on each side: b and b match.", {
        ok: [1], hl: [0, 2], ptrs: { l: 0, r: 2 },
      }),
      s("Stepping out again would leave the string, so this growth stops.", {
        ok: [0, 1, 2], ptrs: { l: 0, r: 2 },
      }),
      s("Every letter, and every gap between two letters, can be a middle. How many middles is that?", {
        hl: [0, 1, 2, 3, 4],
      }),
    ]),
    A(["c", "b", "b", "d"], [
      s("A palindrome like bb has no single middle letter.", {
        hl: [1, 2],
      }),
      s("Its middle sits in the gap between two letters. Start with the pair b, b.", {
        ok: [1, 2], ptrs: { l: 1, r: 2 },
      }),
      s("Step out one place on each side: c and d. Do they match?", {
        ok: [1, 2], hl: [0, 3], ptrs: { l: 0, r: 3 },
      }),
      s("They do not, so bb is as far as this middle goes. Why must we try gaps as middles too?", {
        ok: [1, 2], bad: [0, 3], ptrs: { l: 0, r: 3 },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "String to Integer (atoi)": [
    A([" ", "-", "4", "2", "a", "b", "c"], [
      s("Step 1: skip the spaces at the front.", {
        hl: [0], ptrs: { i: 0 },
      }),
      s("Step 2: read a sign if there is one. Here it is a minus.", {
        bad: [0], hl: [1], ptrs: { i: 1 }, aux: { label: "sign", items: ["-"] },
      }),
      s("Step 3: read digits, one at a time. First comes 4.", {
        bad: [0], ok: [1], hl: [2], ptrs: { i: 2 }, aux: { label: "number", items: ["4"] },
      }),
      s("Then 2. The number so far is 42.", {
        bad: [0], ok: [1, 2], hl: [3], ptrs: { i: 3 }, aux: { label: "number", items: ["4", "2"] },
      }),
      s("Next is a letter, not a digit. What should we do now?", {
        bad: [0], ok: [1, 2, 3], hl: [4], ptrs: { i: 4 }, aux: { label: "number", items: ["4", "2"] },
      }),
    ]),
    A(["2", "1", "4", "7", "4", "8", "3", "6", "4", "8"], [
      s("The answer must fit in a 32-bit box. The biggest allowed value is 2147483647.", {
        aux: { label: "limit", items: ["2147483647"] },
      }),
      s("We build the number digit by digit. After 9 digits it is 214748364.", {
        ok: [0, 1, 2, 3, 4, 5, 6, 7, 8], ptrs: { i: 8 },
        aux: { label: "so far", items: ["214748364"] },
      }),
      s("The next digit is 8. Adding it would make 2147483648, one more than the box allows.", {
        ok: [0, 1, 2, 3, 4, 5, 6, 7, 8], hl: [9], ptrs: { i: 9 }, tags: { 9: "too big" },
        aux: { label: "so far", items: ["214748364"] },
      }),
      s("We must notice this before we add the digit. How can we check ahead?", {
        ok: [0, 1, 2, 3, 4, 5, 6, 7, 8], bad: [9], ptrs: { i: 9 },
        aux: { label: "so far", items: ["214748364"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Isomorphic Strings": [
    A(["e", "g", "g"], [
      s("Each letter of egg must map to one letter of add.", {
        aux: { label: "map", items: [] },
      }),
      s("e maps to a.", {
        hl: [0], ptrs: { i: 0 }, aux: { label: "map", items: ["e→a"] },
      }),
      s("g maps to d.", {
        ok: [0], hl: [1], ptrs: { i: 1 }, aux: { label: "map", items: ["e→a", "g→d"] },
      }),
      s("g appears again. It must go to d again, and it does.", {
        ok: [0, 1], hl: [2], ptrs: { i: 2 }, aux: { label: "map", items: ["e→a", "g→d"] },
      }),
      s("The same letter always had the same partner. Is that check enough on its own?", {
        ok: [0, 1, 2], aux: { label: "map", items: ["e→a", "g→d"] },
      }),
    ]),
    A(["b", "a", "d", "c"], [
      s("Now badc against baba. Map the letters one by one.", {
        hl: [0], ptrs: { i: 0 }, aux: { label: "map", items: ["b→b"] },
      }),
      s("a maps to a.", {
        ok: [0], hl: [1], ptrs: { i: 1 }, aux: { label: "map", items: ["b→b", "a→a"] },
      }),
      s("d maps to b. d is new, so nothing seems wrong yet.", {
        ok: [0, 1], hl: [2], ptrs: { i: 2 }, aux: { label: "map", items: ["b→b", "a→a", "d→b"] },
      }),
      s("But b already maps to b. Now two different letters share the same partner.", {
        bad: [0, 2], ok: [1], ptrs: { i: 2 }, aux: { label: "map", items: ["b→b", "a→a", "d→b"] },
      }),
      s("Which direction of checking would have caught this?", {
        bad: [0, 2], aux: { label: "map", items: ["b→b", "a→a", "d→b"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Binary Search": [
    A([-1, 0, 3, 5, 9, 12], [
      s("The target is 12, and the array is sorted. Look at the middle: 3.", {
        hl: [2], ptrs: { lo: 0, mid: 2, hi: 5 },
      }),
      s("3 is smaller than 12. Everything left of it is even smaller, so that part can go.", {
        bad: [0, 1, 2], ptrs: { lo: 3, hi: 5 },
      }),
      s("The new middle is 9. Still smaller than 12.", {
        bad: [0, 1, 2], hl: [4], ptrs: { lo: 3, mid: 4, hi: 5 },
      }),
      s("Drop 9 and everything before it. Only one number is left.", {
        bad: [0, 1, 2, 3, 4], hl: [5], ptrs: { lo: 5, mid: 5, hi: 5 },
      }),
      s("12 found after 3 looks, out of 6 numbers. What if there were a million?", {
        bad: [0, 1, 2, 3, 4], ok: [5], ptrs: { lo: 5, mid: 5, hi: 5 },
      }),
    ]),
    A([-1, 0, 3, 5, 9, 12], [
      s("Now the target is 2, which is not in the array. Middle is 3.", {
        hl: [2], ptrs: { lo: 0, mid: 2, hi: 5 },
      }),
      s("3 is bigger than 2, so everything from 3 onward can go.", {
        bad: [2, 3, 4, 5], ptrs: { lo: 0, hi: 1 },
      }),
      s("The middle is now -1. It is smaller than 2, so it goes too.", {
        bad: [0, 2, 3, 4, 5], hl: [0], ptrs: { lo: 0, mid: 0, hi: 1 },
      }),
      s("Only 0 is left. It is smaller than 2 as well.", {
        bad: [0, 2, 3, 4, 5], hl: [1], ptrs: { lo: 1, mid: 1, hi: 1 },
      }),
      s("Drop 0 too. lo has passed hi, and nothing is left. What should the search report?", {
        bad: [0, 1, 2, 3, 4, 5], ptrs: { lo: 2, hi: 1 },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Search Insert Position": [
    A([1, 3, 5, 6], [
      s("Where would 2 fit in this sorted list? Check the middle: 3.", {
        hl: [1], ptrs: { lo: 0, mid: 1, hi: 3 },
      }),
      s("3 is bigger than 2, so 3 and everything after it are too big.", {
        bad: [1, 2, 3], ptrs: { lo: 0, hi: 0 },
      }),
      s("Only 1 is left, and it is smaller than 2.", {
        bad: [1, 2, 3], hl: [0], ptrs: { lo: 0, mid: 0, hi: 0 },
      }),
      s("The pointers have crossed. 2 is not here, but it must slide in between two numbers. Which two?", {
        bad: [1, 2, 3], hl: [0, 1], ptrs: { lo: 1, hi: 0 },
      }),
    ]),
    A([1, 3, 5, 6], [
      s("Now the target is 7, bigger than anything here. Middle is 3.", {
        hl: [1], ptrs: { lo: 0, mid: 1, hi: 3 },
      }),
      s("3 is smaller than 7, so 1 and 3 can go.", {
        bad: [0, 1], ptrs: { lo: 2, hi: 3 },
      }),
      s("The middle is 5, also smaller than 7. It goes too.", {
        bad: [0, 1, 2], hl: [2], ptrs: { lo: 3, mid: 2, hi: 3 },
      }),
      s("6 is smaller than 7 as well. Everything has been dropped.", {
        bad: [0, 1, 2, 3], hl: [3], ptrs: { lo: 3, mid: 3, hi: 3 },
      }),
      s("Every number was smaller than 7. Where should 7 be placed?", {
        bad: [0, 1, 2, 3], ptrs: { lo: 4, hi: 3 },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "First Bad Version": [
    A([1, 2, 3, 4, 5, 6, 7], [
      s("Seven versions. Once one version is bad, every later version is bad too.", {
        ptrs: { lo: 0, hi: 6 },
      }),
      s("Test the middle version, 4. It is good.", {
        hl: [3], ptrs: { lo: 0, mid: 3, hi: 6 }, tags: { 3: "good" },
      }),
      s("Since 4 is good, every version before it is good too. Those can go.", {
        bad: [0, 1, 2, 3], ptrs: { lo: 4, hi: 6 },
      }),
      s("New middle is version 6. It is bad.", {
        bad: [0, 1, 2, 3], hl: [5], ptrs: { lo: 4, mid: 5, hi: 6 }, tags: { 5: "bad" },
      }),
      s("Version 6 is bad. Is it the first bad one?", {
        bad: [0, 1, 2, 3], hl: [5], ptrs: { lo: 4, mid: 5, hi: 6 }, tags: { 5: "bad" },
      }),
    ]),
    A([1, 2, 3, 4, 5, 6, 7], [
      s("Version 6 is bad. The first bad one could be 6, or an earlier version.", {
        bad: [0, 1, 2, 3], hl: [5], ptrs: { lo: 4, mid: 5, hi: 6 }, tags: { 5: "bad" },
      }),
      s("Version 7 comes after a bad one, so it can never be the first. Drop it.", {
        bad: [0, 1, 2, 3, 6], ptrs: { lo: 4, hi: 5 }, tags: { 5: "bad" },
      }),
      s("But 6 stays in play. Test version 5.", {
        bad: [0, 1, 2, 3, 6], hl: [4], ptrs: { lo: 4, mid: 4, hi: 5 }, tags: { 5: "bad" },
      }),
      s("Version 5 is bad too, so 6 cannot be first. Drop 6.", {
        bad: [0, 1, 2, 3, 5, 6], hl: [4], ptrs: { lo: 4, mid: 4, hi: 4 }, tags: { 4: "bad" },
      }),
      s("The range is down to one version. How do we know it is the first bad one?", {
        bad: [0, 1, 2, 3, 5, 6], ok: [4], ptrs: { lo: 4, hi: 4 }, tags: { 4: "bad" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Search in Rotated Sorted Array": [
    A([4, 5, 6, 7, 0, 1, 2], [
      s("A sorted row was rotated. It is now two sorted pieces: 4 5 6 7 ...", {
        hl: [0, 1, 2, 3],
      }),
      s("... and 0 1 2. The break sits between 7 and 0.", {
        hl: [4, 5, 6],
      }),
      s("Look at the middle, 7, and compare it with the left end, 4.", {
        hl: [0, 3], ptrs: { lo: 0, mid: 3, hi: 6 },
      }),
      s("4 is smaller than 7, so the left half, 4 to 7, is in order.", {
        ok: [0, 1, 2, 3], ptrs: { lo: 0, mid: 3, hi: 6 },
      }),
      s("What about the right half, from 7 down to 2? Is it also in order?", {
        hl: [3, 6], ptrs: { lo: 0, mid: 3, hi: 6 }, tags: { 3: "7", 6: "2" },
      }),
    ]),
    A([4, 5, 6, 7, 0, 1, 2], [
      s("The target is 0. The left half 4 to 7 is in order. Does 0 fit between 4 and 7?", {
        ok: [0, 1, 2, 3], ptrs: { lo: 0, mid: 3, hi: 6 }, tags: { 0: "4", 3: "7" },
      }),
      s("No. 0 is smaller than 4, so it cannot be hiding in that half.", {
        bad: [0, 1, 2, 3], ptrs: { lo: 4, hi: 6 },
      }),
      s("Search the right half. The new middle is 1.", {
        bad: [0, 1, 2, 3], hl: [5], ptrs: { lo: 4, mid: 5, hi: 6 },
      }),
      s("This half is in order, and 1 is bigger than 0. Look to its left.", {
        bad: [0, 1, 2, 3, 5, 6], ptrs: { lo: 4, hi: 4 },
      }),
      s("Only one spot is left. At each step, what did we check first to choose a side?", {
        bad: [0, 1, 2, 3, 5, 6], ok: [4], ptrs: { lo: 4, mid: 4, hi: 4 },
      }),
    ]),
  ],

  // ===============================================================
  // BATCH 4: Binary Search, 3Sum, Sorting (problems 25 to 32)
  // ===============================================================

  // ---------------------------------------------------------------
  "Find Minimum in Rotated Sorted Array": [
    A([3, 4, 5, 1, 2], [
      s("A sorted row was rotated. We want its smallest number.", {
        ptrs: { lo: 0, hi: 4 },
      }),
      s("Look at the middle, 5, and the right end, 2.", {
        hl: [2, 4], ptrs: { lo: 0, mid: 2, hi: 4 },
      }),
      s("5 is bigger than 2. Going right from 5, the numbers must drop somewhere to reach 2.", {
        hl: [2, 4], ptrs: { lo: 0, mid: 2, hi: 4 }, tags: { 2: "5", 4: "2" },
      }),
      s("So where must the smallest number be hiding?", {
        hl: [3, 4], ptrs: { lo: 0, mid: 2, hi: 4 },
      }),
    ]),
    A([3, 4, 5, 1, 2], [
      s("Now only 1 and 2 remain. The middle is 1 and the right end is 2.", {
        bad: [0, 1, 2], hl: [3, 4], ptrs: { lo: 3, mid: 3, hi: 4 },
      }),
      s("1 is smaller than 2, so this part is in order.", {
        bad: [0, 1, 2], ok: [3, 4], ptrs: { lo: 3, mid: 3, hi: 4 },
      }),
      s("The middle might be the smallest itself, so we keep it. Only the right end can go.", {
        bad: [0, 1, 2, 4], ok: [3], ptrs: { lo: 3, mid: 3, hi: 3 },
      }),
      s("One number is left. Why did we keep the middle instead of dropping it?", {
        bad: [0, 1, 2, 4], ok: [3], ptrs: { lo: 3, mid: 3, hi: 3 },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Sqrt(x)": [
    A([1, 2, 3, 4, 5, 6, 7, 8], [
      s("Find the square root of 8, rounded down. Try the numbers 1 to 8.", {
        ptrs: { lo: 0, hi: 7 },
      }),
      s("Try 4 in the middle: 4 × 4 = 16, which is more than 8.", {
        hl: [3], ptrs: { lo: 0, mid: 3, hi: 7 }, tags: { 3: "16" },
      }),
      s("Too big. 4 and everything bigger can go.", {
        bad: [3, 4, 5, 6, 7], ptrs: { lo: 0, hi: 2 },
      }),
      s("Try 2: 2 × 2 = 4, which is not more than 8. It could be the answer.", {
        bad: [3, 4, 5, 6, 7], hl: [1], ptrs: { lo: 0, mid: 1, hi: 2 }, tags: { 1: "4" },
      }),
      s("We note 2 as a candidate. Why can we not simply stop here?", {
        bad: [3, 4, 5, 6, 7], ok: [1], ptrs: { lo: 0, mid: 1, hi: 2 },
        aux: { label: "best", items: ["2"] },
      }),
    ]),
    A([1, 2, 3, 4, 5, 6, 7, 8], [
      s("Candidate so far: 2, because 2 × 2 = 4 does not go over 8.", {
        bad: [3, 4, 5, 6, 7], ok: [1], hl: [2], ptrs: { lo: 2, hi: 2 },
        aux: { label: "best", items: ["2"] },
      }),
      s("Try the next number, 3: 3 × 3 = 9, which is more than 8.", {
        bad: [3, 4, 5, 6, 7], ok: [1], hl: [2], ptrs: { lo: 2, mid: 2, hi: 2 }, tags: { 2: "9" },
        aux: { label: "best", items: ["2"] },
      }),
      s("3 is too big, so it goes too. Nothing bigger is left to try.", {
        bad: [2, 3, 4, 5, 6, 7], ok: [1], ptrs: { lo: 2, hi: 1 },
        aux: { label: "best", items: ["2"] },
      }),
      s("8 is not a perfect square. Should we report 2 or 3, and why?", {
        bad: [2, 3, 4, 5, 6, 7], hl: [1], ptrs: { lo: 2, hi: 1 },
        aux: { label: "best", items: ["2"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Find First and Last Position of Element in Sorted Array": [
    A([5, 8, 8, 8, 8, 10], [
      s("Find the first 8. The array is sorted, so all the 8s sit together.", {
        hl: [1, 2, 3, 4], ptrs: { lo: 0, hi: 5 },
      }),
      s("The middle, index 2, is an 8. But there may be more 8s to its left.", {
        hl: [2], ptrs: { lo: 0, mid: 2, hi: 5 },
      }),
      s("So we do not stop. We keep the middle and drop what lies to its right.", {
        bad: [3, 4, 5], hl: [2], ptrs: { lo: 0, hi: 2 },
      }),
      s("The next middle, index 1, is another 8. We keep it and drop index 2.", {
        bad: [2, 3, 4, 5], hl: [1], ptrs: { lo: 0, mid: 1, hi: 1 },
      }),
      s("The middle is now 5, which is too small. It goes.", {
        bad: [0, 2, 3, 4, 5], hl: [1], ptrs: { lo: 1, hi: 1 },
      }),
      s("One spot is left. Why did finding an 8 not end the search?", {
        bad: [0, 2, 3, 4, 5], ok: [1], ptrs: { lo: 1, mid: 1, hi: 1 },
      }),
    ]),
    A([5, 8, 8, 8, 8, 10], [
      s("Now find the last 8. It is the same search, leaning the other way.", {
        hl: [1, 2, 3, 4], ptrs: { lo: 0, hi: 5 },
      }),
      s("The middle, index 3, is an 8. There may be more 8s to its right, so we keep it.", {
        hl: [3], ptrs: { lo: 0, mid: 3, hi: 5 },
      }),
      s("We drop everything to its left.", {
        bad: [0, 1, 2], hl: [3], ptrs: { lo: 3, hi: 5 },
      }),
      s("The next middle, index 4, is also an 8. Keep it, drop index 3.", {
        bad: [0, 1, 2, 3], hl: [4], ptrs: { lo: 4, mid: 4, hi: 5 },
      }),
      s("The middle is now 10, which is too big. It goes.", {
        bad: [0, 1, 2, 3], hl: [5], ptrs: { lo: 4, mid: 5, hi: 5 }, tags: { 5: "too big" },
      }),
      s("One spot is left. What changed in how we moved the pointers compared with the first search?", {
        bad: [0, 1, 2, 3, 5], ok: [4], ptrs: { lo: 4, mid: 4, hi: 4 },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Koko Eating Bananas": [
    A([3, 6, 7, 11], [
      s("Four piles of bananas. Koko has 8 hours and eats from one pile at a time.", {}),
      s("Try eating 4 bananas per hour. Pile 3 takes 1 hour.", {
        hl: [0], tags: { 0: "1 h" },
      }),
      s("Pile 6 takes 2 hours: 4 in the first, 2 in the second. A part-hour still counts as a whole hour.", {
        ok: [0], hl: [1], tags: { 0: "1 h", 1: "2 h" },
      }),
      s("Pile 7 takes 2 hours and pile 11 takes 3 hours.", {
        ok: [0, 1], hl: [2, 3], tags: { 0: "1 h", 1: "2 h", 2: "2 h", 3: "3 h" },
      }),
      s("The total is 1 + 2 + 2 + 3 = 8 hours. Does this speed work for the 8 hours?", {
        ok: [0, 1, 2, 3], tags: { 0: "1 h", 1: "2 h", 2: "2 h", 3: "3 h" }, out: "total 8 h",
      }),
    ]),
    A([3, 6, 7, 11], [
      s("Try a slower speed: 3 bananas per hour. Pile 3 takes 1 hour, pile 6 takes 2.", {
        ok: [0, 1], tags: { 0: "1 h", 1: "2 h" },
      }),
      s("Pile 7 takes 3 hours and pile 11 takes 4 hours.", {
        ok: [0, 1], hl: [2, 3], tags: { 0: "1 h", 1: "2 h", 2: "3 h", 3: "4 h" },
      }),
      s("The total is 10 hours, more than the 8 we have.", {
        bad: [0, 1, 2, 3], tags: { 0: "1 h", 1: "2 h", 2: "3 h", 3: "4 h" }, out: "total 10 h",
      }),
      s("Too slow. Any speed below 3 would be slower still. Which way should we search for a speed now?", {
        bad: [0, 1, 2, 3], tags: { 0: "1 h", 1: "2 h", 2: "3 h", 3: "4 h" }, out: "total 10 h",
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "3Sum": [
    A([-1, 0, 1, 2, -1, -4], [
      s("We want three numbers that add up to 0. First, sort the array.", {}),
      s("Sorted. Equal numbers are now neighbors.", {
        values: [-4, -1, -1, 0, 1, 2], hl: [1, 2],
      }),
      s("Fix the first number, -1. Two pointers search the rest, one from each end.", {
        values: [-4, -1, -1, 0, 1, 2], hl: [1], ptrs: { i: 1, l: 2, r: 5 },
      }),
      s("-1 + -1 + 2 = 0. That is a triplet.", {
        values: [-4, -1, -1, 0, 1, 2], ok: [1, 2, 5], ptrs: { i: 1, l: 2, r: 5 },
      }),
      s("Sorted order told the pointers which way to move. Why does that save us a whole loop?", {
        values: [-4, -1, -1, 0, 1, 2], ok: [1, 2, 5], ptrs: { i: 1, l: 2, r: 5 },
      }),
    ]),
    A([-4, -1, -1, 0, 1, 2], [
      s("Fix -1 at index 1. The pointers find -1, -1, 2 and then -1, 0, 1.", {
        ok: [1], ptrs: { i: 1 }, aux: { label: "found", items: ["-1,-1,2", "-1,0,1"] },
      }),
      s("Now move on to index 2. It is another -1.", {
        hl: [2], ptrs: { i: 2 }, aux: { label: "found", items: ["-1,-1,2", "-1,0,1"] },
      }),
      s("It would find the very same two triplets again.", {
        bad: [2], ptrs: { i: 2 }, aux: { label: "found", items: ["-1,-1,2", "-1,0,1"] },
      }),
      s("Our answer would hold duplicates. How can we notice a repeated number and skip it?", {
        bad: [2], hl: [1], ptrs: { i: 2 }, tags: { 1: "same", 2: "same" },
        aux: { label: "found", items: ["-1,-1,2", "-1,0,1"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Find All Numbers Disappeared in an Array": [
    A([4, 3, 2, 7, 8, 2, 3, 1], [
      s("Every number is between 1 and 8, so each number points to a spot. 4 points to the 4th spot.", {
        hl: [0], tags: { 3: "for 4" },
      }),
      s("We mark that spot by making its number negative.", {
        values: [4, 3, 2, -7, 8, 2, 3, 1], hl: [0], ok: [3],
      }),
      s("3 points to the 3rd spot. Mark it.", {
        values: [4, 3, -2, -7, 8, 2, 3, 1], hl: [1], ok: [2, 3],
      }),
      s("Keep going for all 8 numbers. Marked spots turn negative.", {
        values: [-4, -3, -2, -7, 8, 2, -3, -1], ok: [0, 1, 2, 3, 6, 7],
      }),
      s("Two spots stayed positive. What do their positions tell us?", {
        values: [-4, -3, -2, -7, 8, 2, -3, -1], ok: [0, 1, 2, 3, 6, 7], hl: [4, 5],
      }),
    ]),
    A([4, 3, 2, 7, 8, 2, 3, 1], [
      s("Some spots are already marked. Now we stand on the -7.", {
        values: [4, 3, 2, -7, 8, 2, 3, 1], hl: [3], ptrs: { i: 3 },
      }),
      s("The minus sign is only a mark. The real number here is 7.", {
        values: [4, 3, 2, -7, 8, 2, 3, 1], hl: [3], ptrs: { i: 3 }, tags: { 3: "real 7" },
      }),
      s("So this number points to the 7th spot.", {
        values: [4, 3, 2, -7, 8, 2, 3, 1], ok: [3], hl: [6], ptrs: { i: 3 },
        tags: { 3: "real 7", 6: "for 7" },
      }),
      s("Read as -7, it would point to a spot that does not exist. What must we do before using it?", {
        values: [4, 3, 2, -7, 8, 2, 3, 1], bad: [3], ptrs: { i: 3 }, tags: { 3: "-7?" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Sort Colors": [
    A([2, 0, 2, 1, 1, 0], [
      s("The colors are 0, 1 and 2. Low marks where the next 0 goes, high where the next 2 goes, mid reads.", {
        hl: [0], ptrs: { low: 0, mid: 0, high: 5 },
      }),
      s("mid reads a 2. A 2 belongs at the back, so we swap it with the high end.", {
        values: [0, 0, 2, 1, 1, 2], hl: [0], ok: [5], ptrs: { low: 0, mid: 0, high: 4 },
      }),
      s("mid now reads a 0. A 0 belongs at the front, so low and mid both step forward.", {
        values: [0, 0, 2, 1, 1, 2], ok: [0, 5], ptrs: { low: 1, mid: 1, high: 4 },
      }),
      s("Another 0. The same move again.", {
        values: [0, 0, 2, 1, 1, 2], ok: [0, 1, 5], ptrs: { low: 2, mid: 2, high: 4 },
      }),
      s("mid reads a 2 again, so it goes to the back. Where are the three zones forming?", {
        values: [0, 0, 2, 1, 1, 2], ok: [0, 1, 5], hl: [2], ptrs: { low: 2, mid: 2, high: 4 },
      }),
    ]),
    A([1, 2, 1, 0], [
      s("low is at the start. A 1 stays in the middle zone, so mid steps on.", {
        hl: [1], ptrs: { low: 0, mid: 1, high: 3 },
      }),
      s("mid reads a 2. It swaps with the back, and the back is a 0.", {
        hl: [1, 3], ptrs: { low: 0, mid: 1, high: 3 }, tags: { 1: "2", 3: "0" },
      }),
      s("After the swap, a 0 sits under mid. The back is now in place.", {
        values: [1, 0, 1, 2], ok: [3], hl: [1], ptrs: { low: 0, mid: 1, high: 2 },
      }),
      s("If mid stepped on now, that 0 would be left behind the 1s.", {
        values: [1, 0, 1, 2], ok: [3], bad: [1], ptrs: { low: 0, mid: 2, high: 2 },
      }),
      s("So after swapping with the back, should mid move on or look again?", {
        values: [1, 0, 1, 2], ok: [3], hl: [1], ptrs: { low: 0, mid: 1, high: 2 },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  // Intervals do not fit the tree or array renderer.
  // Needs a new renderer: Merge Intervals / challenge 1 and 2.
  "Merge Intervals": [null, null],

  // ===============================================================
  // BATCH 5: Sorting, Heaps, Linked Lists (problems 33 to 40)
  // ===============================================================

  // ---------------------------------------------------------------
  "Kth Largest Element in an Array": [
    T([2, 3], [
      s("We want the 2nd largest of 3 2 1 5 6 4. Keep only the 2 largest so far, with the smallest on top.", {
        hl: [0], tags: { 0: "top" }, out: "arrived 3, 2",
      }),
      s("1 arrives. It is smaller than the top, so it can never be among the 2 largest.", {
        bad: [], hl: [0], tags: { 0: "top 2" }, out: "arrived 1",
      }),
      s("5 arrives and beats the top, 2. The 2 leaves and 5 joins.", {
        values: [3, 5], hl: [0], tags: { 0: "top 3" }, out: "arrived 5",
      }),
      s("6 arrives and beats the top, 3. The heap now holds 5 and 6.", {
        values: [5, 6], hl: [0], tags: { 0: "top 5" }, out: "arrived 6",
      }),
      s("4 arrives and is smaller than the top, so it is dropped. What does the top stand for now?", {
        values: [5, 6], ok: [0, 1], tags: { 0: "top 5" }, out: "arrived 4",
      }),
    ]),
    A([3, 2, 1, 5, 6, 4], [
      s("Another way: sort the numbers from biggest to smallest.", {}),
      s("Here they are, sorted.", {
        values: [6, 5, 4, 3, 2, 1], hl: [0, 1, 2, 3, 4, 5],
      }),
      s("The 1st largest sits at spot 1, and the 2nd largest at spot 2.", {
        values: [6, 5, 4, 3, 2, 1], ok: [0], hl: [1], tags: { 0: "1st", 1: "2nd" },
      }),
      s("But we sorted all 6 numbers just to look at 2 of them. What if only the top 2 mattered?", {
        values: [6, 5, 4, 3, 2, 1], ok: [0, 1], bad: [2, 3, 4, 5],
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Top K Frequent Elements": [
    A([1, 1, 1, 2, 2, 3], [
      s("Count how often each number appears.", {
        ptrs: { i: 0 }, aux: { label: "counts", items: [] },
      }),
      s("Three 1s so far.", {
        ok: [0, 1, 2], ptrs: { i: 2 }, aux: { label: "counts", items: ["1→3"] },
      }),
      s("Then two 2s.", {
        ok: [0, 1, 2, 3, 4], ptrs: { i: 4 }, aux: { label: "counts", items: ["1→3", "2→2"] },
      }),
      s("And one 3.", {
        ok: [0, 1, 2, 3, 4, 5], ptrs: { i: 5 }, aux: { label: "counts", items: ["1→3", "2→2", "3→1"] },
      }),
      s("Now we have the counts, but we want only the top 2 by count. How do we pick them?", {
        ok: [0, 1, 2, 3, 4, 5], aux: { label: "counts", items: ["1→3", "2→2", "3→1"] },
      }),
    ]),
    A(["-", "-", "-", "-", "-", "-", "-"], [
      s("Idea: make buckets where the spot number is how often a number appeared.", {
        tags: { 1: "seen 1×", 2: "seen 2×", 3: "seen 3×" },
      }),
      s("3 appeared once, so it goes into spot 1.", {
        values: ["-", "3", "-", "-", "-", "-", "-"], hl: [1], tags: { 1: "seen 1×" },
      }),
      s("2 appeared twice, so it goes into spot 2.", {
        values: ["-", "3", "2", "-", "-", "-", "-"], ok: [1], hl: [2], tags: { 2: "seen 2×" },
      }),
      s("1 appeared three times, so it goes into spot 3.", {
        values: ["-", "3", "2", "1", "-", "-", "-"], ok: [1, 2], hl: [3], tags: { 3: "seen 3×" },
      }),
      s("To get the top 2, we read the buckets from the high end. Which spots do we read first?", {
        values: ["-", "3", "2", "1", "-", "-", "-"], ok: [1, 2, 3], ptrs: { read: 6 },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  // Intervals do not fit the tree or array renderer.
  // Needs a new renderer: Meeting Rooms / challenge 1 and 2.
  "Meeting Rooms": [null, null],

  // ---------------------------------------------------------------
  "Sort an Array": [
    A([5, 2, 3, 1], [
      s("Merge sort starts by cutting the array in half.", {
        hl: [0, 1], tags: { 0: "left", 2: "right" },
      }),
      s("Cut each half in half again.", {
        hl: [0, 2], tags: { 0: "5", 1: "2", 2: "3", 3: "1" },
      }),
      s("Now every piece is a single number. One number alone is already sorted.", {
        ok: [0, 1, 2, 3],
      }),
      s("So all the real work is putting pieces back together. How many levels of cutting does a long array need?", {
        ok: [0, 1, 2, 3],
      }),
    ]),
    A([2, 5, 1, 3], [
      s("Two sorted halves: 2 5 and 1 3. One pointer sits at the front of each.", {
        hl: [0, 2], ptrs: { a: 0, b: 2 }, aux: { label: "merged", items: [] },
      }),
      s("Compare 2 and 1. 1 is smaller, so it goes out first.", {
        ok: [2], hl: [0], ptrs: { a: 0, b: 3 }, aux: { label: "merged", items: ["1"] },
      }),
      s("Compare 2 and 3. 2 is smaller, so it goes next.", {
        ok: [2, 0], hl: [1, 3], ptrs: { a: 1, b: 3 }, aux: { label: "merged", items: ["1", "2"] },
      }),
      s("Compare 5 and 3. 3 is smaller, so it goes next.", {
        ok: [2, 0, 3], hl: [1], ptrs: { a: 1 }, aux: { label: "merged", items: ["1", "2", "3"] },
      }),
      s("Only 5 is left, so it goes last. Each number moved out only once.", {
        ok: [2, 0, 3, 1], aux: { label: "merged", items: ["1", "2", "3", "5"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Largest Number": [
    A([3, 30, 34, 5, 9], [
      s("We join numbers to make the biggest result. Which should come first: 3 or 30?", {
        hl: [0, 1],
      }),
      s("Try 3 first, then 30. Joined, that makes 330.", {
        hl: [0, 1], tags: { 0: "1st", 1: "2nd" }, out: "330",
      }),
      s("Try 30 first, then 3. Joined, that makes 303.", {
        hl: [0, 1], tags: { 0: "2nd", 1: "1st" }, out: "303",
      }),
      s("As a plain number, 30 is bigger than 3. Yet one order won. What are we really comparing?", {
        hl: [0, 1], out: "330 vs 303",
      }),
    ]),
    A([3, 30, 34, 5, 9], [
      s("Sort every pair by the join rule. 9 joins ahead of all the others.", {
        hl: [4],
      }),
      s("Move 9 to the front. 5 beats the rest as well, so it follows.", {
        values: [9, 5, 3, 30, 34], ok: [0, 1],
      }),
      s("34 against 3: 343 beats 334, so 34 goes first. 3 against 30: 330 beats 303.", {
        values: [9, 5, 34, 3, 30], ok: [0, 1, 2, 3, 4],
      }),
      s("Now join them in this order, left to right. What number do we get?", {
        values: [9, 5, 34, 3, 30], ok: [0, 1, 2, 3, 4], out: "9 | 5 | 34 | 3 | 30",
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  // Linked lists do not fit the tree or array renderer.
  // Needs a new renderer: Insertion Sort List / challenge 1 and 2.
  "Insertion Sort List": [null, null],

  // Needs a new renderer: Reverse Linked List / challenge 1 and 2.
  "Reverse Linked List": [null, null],

  // Needs a new renderer: Merge Two Sorted Lists / challenge 1 and 2.
  "Merge Two Sorted Lists": [null, null],

  // ===============================================================
  // BATCH 6: Linked Lists (problems 41 to 48)
  // All need a new "list" renderer, so these are null placeholders.
  // Replace each [null, null] with real visuals once the renderer exists.
  // ===============================================================
  "Linked List Cycle": [null, null],
  "Middle of the Linked List": [null, null],
  "Remove Nth Node From End of List": [null, null],
  "Palindrome Linked List": [null, null],
  "Intersection of Two Linked Lists": [null, null],
  "Remove Duplicates from Sorted List": [null, null],
  "Reorder List": [null, null],
  "Add Two Numbers": [null, null],

  // ===============================================================
  // TREES (existing)
  // ===============================================================

  // ---------------------------------------------------------------
  "Maximum Depth of Binary Tree": [
    T(LEVEL_TREE, [
      s("Start at the root, 3. Its depth must depend on what hangs below it.", { hl: [0] }),
      s("The left subtree is just the node 9: it is 1 level deep.", {
        hl: [1],
        tags: { 1: "depth 1" },
      }),
      s("The right subtree (20, with 15 and 7 below) is 2 levels deep.", {
        hl: [2, 5, 6],
        tags: { 1: "depth 1", 2: "depth 2" },
      }),
      s("Left side: 1 level. Right side: 2 levels. How deep should the whole tree be?", {
        hl: [0],
        tags: { 1: "1", 2: "2" },
      }),
    ]),
    T([1, N, 2], [
      s("Node 1 has a right child but no left child.", { hl: [0, 2] }),
      s("What is the depth of the empty spot on the left?", {
        hl: [1],
        tags: { 1: "depth = ?" },
      }),
      s("Count the nodes along the longest path that goes through that empty spot.", {
        hl: [1],
        tags: { 1: "count nodes" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Invert Binary Tree": [
    T([4, 2, 7, 1, 3, 6, 9], [
      s("Here is the original tree.", { hl: [0] }),
      s("And here is its mirror image. Spot what changed.", {
        values: [4, 7, 2, 9, 6, 3, 1],
        hl: [1, 2],
      }),
      s("Every level is flipped: 2 and 7 traded places, and so did 1, 3, 6 and 9.", {
        values: [4, 7, 2, 9, 6, 3, 1],
        ok: [1, 2, 3, 4, 5, 6],
      }),
    ]),
    T([4, 2, 7, 1, 3, 6, 9], [
      s("Swap only the root's children: 2 and 7 trade places, each carrying its own subtree.", {
        values: [4, 7, 2, 6, 9, 1, 3],
        hl: [1, 2],
      }),
      s("Now look at 7's children: 6 and 9 are still in their old order.", {
        values: [4, 7, 2, 6, 9, 1, 3],
        bad: [3, 4, 5, 6],
      }),
      s("The subtrees need the same treatment, all the way down.", {
        values: [4, 7, 2, 9, 6, 3, 1],
        ok: [1, 2, 3, 4, 5, 6],
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Same Tree": [
    T(
      [1, 2, 3],
      [
        s("Compare the roots first: 1 and 1.", { hl: [0], hl2: [0] }),
        s("The roots match. Now compare the left children.", {
          ok: [0], ok2: [0], hl: [1], hl2: [1],
        }),
        s("Left sides match. Finally, the right children.", {
          ok: [0, 1], ok2: [0, 1], hl: [2], hl2: [2],
        }),
        s("Everything matched, in both subtrees. What does that tell you about the two trees?", {
          ok: [0, 1, 2], ok2: [0, 1, 2],
        }),
      ],
      { values2: [1, 2, 3], names: ["p", "q"] }
    ),
    T(
      [1, 2, 3],
      [
        s("Same roots, same left children so far.", { ok: [0, 1], ok2: [0, 1] }),
        s("On the right, p has a node but q has nothing there.", { hl: [2], bad2: [2] }),
        s("Is a single missing node enough to make the trees different?", {
          ok: [0, 1], ok2: [0, 1], bad: [2], bad2: [2],
        }),
      ],
      { values2: [1, 2, N], names: ["p", "q"] }
    ),
  ],

  // ---------------------------------------------------------------
  "Symmetric Tree": [
    T([1, 2, 2, 3, 4, 4, 3], [
      s("Imagine folding the tree along a line through the root.", { hl: [0] }),
      s("Everything on the left of the root forms one subtree.", { hl: [1, 3, 4] }),
      s("Everything on the right forms the other.", { hl: [2, 5, 6] }),
      s("For the tree to be symmetric, these two sides must be mirror images.", {
        ok: [1, 3, 4], hl: [2, 5, 6],
      }),
    ]),
    T([1, 2, 2, 3, 4, 4, 3], [
      s("Mirror partners sit at the same distance from the center line.", { hl: [1, 2] }),
      s("Outer pair: the far-left 3 and the far-right 3.", { ok: [1, 2], hl: [3, 6] }),
      s("Inner pair: the two 4s in the middle.", { ok: [1, 2, 3, 6], hl: [4, 5] }),
      s("Each pair crosses over: the left child of one meets the right child of the other.", {
        ok: [1, 2, 3, 4, 5, 6],
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Binary Tree Level Order Traversal": [
    T(LEVEL_TREE, [
      s("Put the root in the queue.", { hl: [0], aux: q(["3"]) }),
      s("Take 3 out and add its children 9 and 20 at the back.", {
        ok: [0], hl: [1, 2], aux: q(["9", "20"]), out: "3",
      }),
      s("Take 9 out, from the front of the queue. It has no children.", {
        ok: [0, 1], hl: [2], aux: q(["20"]), out: "3, 9",
      }),
      s("Take 20 out and add 15 and 7.", {
        ok: [0, 1, 2], hl: [5, 6], aux: q(["15", "7"]), out: "3, 9, 20",
      }),
      s("Nodes left the queue in the same order they entered: first in, first out.", {
        ok: [0, 1, 2, 5, 6], aux: q([]), out: "3, 9, 20, 15, 7",
      }),
    ]),
    T(LEVEL_TREE, [
      s("The queue holds 1 node, so level 1 has exactly 1 node.", {
        hl: [0], tags: { 0: "size 1" }, aux: q(["3"]),
      }),
      s("Process just that 1 node and add its children. Level 1 is done.", {
        ok: [0], hl: [1, 2], aux: q(["9", "20"]), out: "[3]",
      }),
      s("The queue now holds 2 nodes, so level 2 has exactly 2 nodes.", {
        ok: [0], hl: [1, 2], tags: { 1: "size 2" }, aux: q(["9", "20"]), out: "[3]",
      }),
      s("Process exactly 2 nodes: 9, then 20. Their children join the queue behind them.", {
        ok: [0, 1, 2], hl: [5, 6], aux: q(["15", "7"]), out: "[3] [9, 20]",
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Validate Binary Search Tree": [
    T([5, 1, 6, N, N, 3, 7], [
      s("Check every node against its own parent. 1 is smaller than 5: fine.", {
        hl: [0, 1],
      }),
      s("6 is bigger than 5: fine.", { ok: [1], hl: [0, 2] }),
      s("3 is smaller than its parent 6, and 7 is bigger. Every parent-child pair looks fine!", {
        ok: [0, 1, 2, 5, 6],
      }),
      s("But 3 sits in the right subtree of 5, and it is smaller than 5. It does not belong there.", {
        hl: [0], bad: [5],
      }),
    ]),
    T([5, 1, 6, N, N, 3, 7], [
      s("The root can be anything: every value is allowed.", {
        hl: [0], tags: { 0: "(-∞, +∞)" },
      }),
      s("Going left, values must stay below 5.", {
        hl: [1], tags: { 0: "(-∞, +∞)", 1: "(-∞, 5)" },
      }),
      s("Going right, values must stay above 5.", {
        hl: [2], tags: { 0: "(-∞, +∞)", 1: "(-∞, 5)", 2: "(5, +∞)" },
      }),
      s("6's left child inherits both limits: above 5 and below 6.", {
        hl: [5], tags: { 0: "(-∞, +∞)", 1: "(-∞, 5)", 2: "(5, +∞)", 5: "(5, 6)" },
      }),
      s("3 is not inside (5, 6), so this is not a valid BST.", {
        bad: [5], tags: { 0: "(-∞, +∞)", 1: "(-∞, 5)", 2: "(5, +∞)", 5: "(5, 6)" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Lowest Common Ancestor of a BST": [
    T([6, 2, 8, 0, 4, 7, 9, N, N, 3, 5], [
      s("Find the lowest common ancestor of p = 3 and q = 5, starting at the root 6.", {
        hl: [0], tags: { 9: "p", 10: "q" },
      }),
      s("Both 3 and 5 are smaller than 6.", {
        hl: [0, 9, 10], tags: { 9: "p", 10: "q" },
      }),
      s("In a BST, smaller values live on the left of 6.", {
        hl: [1, 3, 4, 9, 10], tags: { 9: "p", 10: "q" },
      }),
      s("So where could their lowest common ancestor be?", {
        ok: [1, 3, 4, 9, 10], tags: { 9: "p", 10: "q" },
      }),
    ]),
    T([6, 2, 8, 0, 4, 7, 9, N, N, 3, 5], [
      s("Now p = 2 and q = 8, starting at the root 6.", {
        hl: [0], tags: { 1: "p", 2: "q" },
      }),
      s("2 is smaller than 6, so p is on the left.", {
        hl: [0, 1], tags: { 1: "p", 2: "q" },
      }),
      s("8 is larger than 6, so q is on the right.", {
        hl: [0, 2], tags: { 1: "p", 2: "q" },
      }),
      s("The two paths split apart right here, at 6.", {
        ok: [0], hl: [1, 2], tags: { 1: "p", 2: "q" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Diameter of Binary Tree": [
    T([1, 2, 3, 4, 5], [
      s("A path can bend at a node, going down on both sides.", { hl: [0] }),
      s("From node 1, the left side goes down 2 edges (1 → 2 → 4).", {
        hl: [0, 1, 3], tags: { 0: "left: 2" },
      }),
      s("The right side goes down 1 edge (1 → 3).", {
        hl: [0, 2], tags: { 0: "left: 2", 2: "right: 1" },
      }),
      s("Joined at node 1, they form one long path.", {
        ok: [3, 1, 0, 2], tags: { 0: "2 + 1" }, out: "3 edges",
      }),
    ]),
    T([1, 2, N, 4, 5, N, N, 6, N, N, 7], [
      s("A path that turns at the root goes root → 2 → 4 → 6.", {
        hl: [0, 1, 3, 7], tags: { 0: "3 edges" },
      }),
      s("Now try turning at node 2 instead: 6 → 4 → 2 → 5 → 7.", {
        ok: [7, 3, 1, 4, 10], tags: { 1: "4 edges" },
      }),
      s("The longest path does not have to touch the root. Every node is a candidate turning point.", {
        hl: [1], ok: [7, 3, 1, 4, 10], tags: { 0: "3 edges", 1: "4 edges" }, out: "4 edges",
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Binary Tree Inorder Traversal": [
    T([2, 1, 3], [
      s("Inorder: go left first.", { hl: [1] }),
      s("Nothing more on the left of 1, so visit 1.", { ok: [1], out: "1" }),
      s("Back at 2: its left side is finished, so visit 2.", { ok: [1, 0], out: "1, 2" }),
      s("Now go right and visit 3.", { ok: [1, 0, 2], out: "1, 2, 3" }),
    ]),
    T(BST7, [
      s("On a BST, dive as far left as you can.", { hl: [3] }),
      s("The leftmost node comes first: 1.", { ok: [3], out: "1" }),
      s("Then its parent 2, then 3.", { ok: [3, 1, 4], out: "1, 2, 3" }),
      s("Then the root, 4.", { ok: [3, 1, 4, 0], out: "1, 2, 3, 4" }),
      s("Then the right side: 5, 6, 7.", {
        ok: [3, 1, 4, 0, 5, 2, 6], out: "1, 2, 3, 4, 5, 6, 7",
      }),
      s("What do you notice about the order of the output?", {
        ok: [0, 1, 2, 3, 4, 5, 6], out: "1, 2, 3, 4, 5, 6, 7",
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Kth Smallest Element in a BST": [
    T([3, 1, 4, N, 2], [
      s("Visit the BST in order: left, node, right.", { hl: [1] }),
      s("First visited: 1.", { ok: [1], out: "1" }),
      s("Next: 2, the right child of 1.", { ok: [1, 4], out: "1, 2" }),
      s("Then 3, then 4.", { ok: [1, 4, 0, 2], out: "1, 2, 3, 4" }),
      s("The values came out sorted. Which traversal produced that order?", {
        ok: [0, 1, 2, 4], out: "1, 2, 3, 4",
      }),
    ]),
    T([3, 1, 4, N, 2], [
      s("We want k = 2. Count nodes as they are visited.", { hl: [1] }),
      s("Visit 1: that is the 1st.", { ok: [1], tags: { 1: "#1" }, out: "1" }),
      s("Visit 2: that is the 2nd, and k = 2.", {
        ok: [1], hl: [4], tags: { 1: "#1", 4: "#2" }, out: "1, 2",
      }),
      s("We already have the 2nd value. Do we need to visit 3 and 4 at all?", {
        ok: [1, 4], tags: { 1: "#1", 4: "#2" }, out: "1, 2",
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Path Sum": [
    T(
      [5, 4, 8, 11, N, 13, 4, 7, 2, N, N, N, N, N, 1],
      [
        s("The target sum is 22. We arrive at the root needing 22.", {
          hl: [0], tags: { 0: "need 22" },
        }),
        s("Use up 5. Arriving at 4, we still need 17.", {
          ok: [0], hl: [1], tags: { 0: "need 22", 1: "need 17" },
        }),
        s("Use up 4. Arriving at 11, we still need 13.", {
          ok: [0, 1], hl: [3], tags: { 0: "need 22", 1: "need 17", 3: "need 13" },
        }),
        s("Use up 11. Arriving at the leaf 2, we still need 2.", {
          ok: [0, 1, 3], hl: [8],
          tags: { 0: "need 22", 1: "need 17", 3: "need 13", 8: "need 2" },
        }),
      ]
    ),
    T(
      [5, 4, 8, 11, N, 13, 4, 7, 2, N, N, N, N, N, 1],
      [
        s("At the leaf 2 we need exactly 2 more, and the leaf is worth exactly 2.", {
          ok: [0, 1, 3], hl: [8], tags: { 3: "need 13", 8: "need 2" },
        }),
        s("The leaf 7 also arrives needing 2, but 7 is not 2: this path fails.", {
          ok: [0, 1, 3], bad: [7], tags: { 3: "need 13", 7: "need 2" },
        }),
        s("Only a leaf whose value matches what is still needed completes a path.", {
          ok: [0, 1, 3, 8], bad: [7], tags: { 3: "need 13", 7: "need 2", 8: "need 2" },
        }),
      ]
    ),
  ],

  // ---------------------------------------------------------------
  "Kth Largest Element in a Stream": [
    A([4, 5, 8, 2, 3, 5, 10], [
      s("Values arrive one by one. We only care about the 3 largest so far.", {
        hl: [0, 1, 2], aux: { label: "kept", items: ["4", "5", "8"] },
      }),
      s("2 arrives. It is smaller than everything we kept.", {
        ok: [0, 1, 2], bad: [3], ptrs: { now: 3 },
        aux: { label: "kept", items: ["4", "5", "8"] },
      }),
      s("3 arrives, also smaller than all three kept values. Can either ever matter?", {
        ok: [0, 1, 2], bad: [3, 4], ptrs: { now: 4 },
        aux: { label: "kept", items: ["4", "5", "8"] },
      }),
      s("10 arrives and beats the smallest kept value, so 4 drops out.", {
        ok: [1, 2], bad: [0, 3, 4], hl: [6], ptrs: { now: 6 },
        aux: { label: "kept", items: ["5", "8", "10"] },
      }),
    ]),
    T([4, 5, 8], [
      s("Keep the 3 largest values in a min-heap: the smallest sits on top.", {
        hl: [0], tags: { 0: "top" },
      }),
      s("The top is the smallest of the 3 largest values. What rank is that?", {
        hl: [0], tags: { 0: "rank = ?" },
      }),
      s("9 arrives. That is 4 values, one too many, so the top (4) leaves.", {
        values: [5, 8, 9], hl: [0], tags: { 0: "new top" },
      }),
      s("The new top is again the 3rd largest value seen so far.", {
        values: [5, 8, 9], ok: [0], tags: { 0: "3rd largest" },
      }),
    ]),
  ],
};

// ---------------------------------------------------------------
// Sanity checks so bad data never reaches the database
// ---------------------------------------------------------------
function validate() {
  for (const [title, list] of Object.entries(visuals)) {
    list.forEach((v, i) => {
      if (!v) return; // null = this challenge has no visual (needs a new renderer)
      const where = `"${title}" challenge ${i + 1}`;
      if (!["tree", "array"].includes(v.type)) throw new Error(`${where}: bad type`);
      if (!Array.isArray(v.steps) || v.steps.length === 0)
        throw new Error(`${where}: needs steps`);
      if (v.type === "tree" && v.values.length > 15)
        throw new Error(`${where}: tree too big (max 15 slots)`);
      v.steps.forEach((st, k) => {
        if (!st.caption) throw new Error(`${where} step ${k + 1}: missing caption`);
        if (st.values && st.values.length !== v.values.length)
          throw new Error(`${where} step ${k + 1}: values length must match`);
        const limit = Math.max(
          (st.values || v.values).length,
          ((st.values2 || v.values2) || []).length,
          15
        );
        for (const key of ["hl", "ok", "bad", "hl2", "ok2", "bad2"]) {
          (st[key] || []).forEach((idx) => {
            if (!Number.isInteger(idx) || idx < 0 || idx >= limit)
              throw new Error(`${where} step ${k + 1}: bad index in ${key}`);
          });
        }
      });
    });
  }
}

async function main() {
  validate();

  require("dotenv").config();
  const { MongoClient } = require("mongodb");

  const URI =
    process.env.DSA_MONGODB_URI ||
    process.env.DSA_MONGO_URI ||
    process.env.MONGODB_URI ||
    process.env.MONGO_URI;

  if (!URI) {
    console.error("No MongoDB connection string found in .env.");
    process.exit(1);
  }

  const client = new MongoClient(URI);
  try {
    await client.connect();
    const col = client.db(DB_NAME).collection(COLLECTION);

    let done = 0;
    for (const [title, list] of Object.entries(visuals)) {
      const doc = await col.findOne(
        { title },
        { projection: { intuitionChallenges: 1 } }
      );
      if (!doc) {
        console.log(`Skipped (not in database): ${title}`);
        continue;
      }
      const have = (doc.intuitionChallenges || []).length;
      if (list.length > have) {
        console.log(`Skipped (has ${have} challenges, visuals for ${list.length}): ${title}`);
        continue;
      }
      const $set = {};
      list.forEach((v, i) => {
        if (v) $set[`intuitionChallenges.${i}.visual`] = v;
      });
      if (Object.keys($set).length === 0) {
        console.log(`Skipped (no visuals yet): ${title}`);
        continue;
      }
      await col.updateOne({ _id: doc._id }, { $set });
      done++;
      console.log(`Visuals added (${list.length}): ${title}`);
    }
    console.log(`\nDone. Updated ${done} of ${Object.keys(visuals).length} problems.`);
  } catch (err) {
    console.error("Failed:", err.message);
    process.exitCode = 1;
  } finally {
    await client.close();
  }
}

if (require.main === module) {
  main();
}

module.exports = { visuals, validate };