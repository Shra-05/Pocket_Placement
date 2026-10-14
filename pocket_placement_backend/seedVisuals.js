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
const L = (values, steps, extra = {}) => ({ type: "list", values, steps, ...extra });
const G = (values, steps, extra = {}) => ({ type: "grid", values, steps, ...extra });
const GR = (nodes, edges, steps, extra = {}) => ({ type: "graph", nodes, edges, steps, ...extra });
const I = (intervals, steps, extra = {}) => ({ type: "intervals", intervals, steps, ...extra });
// Cells equal to 0 in a grid, as [row, col] pairs (handy for fading water or empty cells)
const zeros = (g) => g.flatMap((row, r) => row.flatMap((v, c) => (v === 0 ? [[r, c]] : [])));
const s = (caption, o = {}) => ({ caption, ...o });
const q = (items) => ({ label: "queue", items });

// Reused trees
const LEVEL_TREE = [3, 9, 20, N, N, 15, 7];
const BST7 = [4, 2, 6, 1, 3, 5, 7];

// Reused grids
const ISLANDS = [
  [1, 1, 0, 0, 0],
  [1, 1, 0, 0, 0],
  [0, 0, 1, 0, 0],
  [0, 0, 0, 1, 1],
];
const FILL = [[1, 1, 1], [1, 1, 0], [1, 0, 1]];
const ORANGES = [[2, 1, 1], [1, 1, 0], [0, 1, 1]];
const PAH = [[1, 3, 2], [4, 2, 5], [3, 6, 1]];
const UP_EMPTY = [["-", "-", "-"], ["-", "-", "-"], ["-", "-", "-"]];
const LCS_S0 = [
  [0, 0, 0, 0, 0, 0],
  [0, "-", "-", "-", "-", "-"],
  [0, "-", "-", "-", "-", "-"],
  [0, "-", "-", "-", "-", "-"],
];
const ED_EMPTY = [["-", "-", "-", "-"], ["-", "-", "-", "-"], ["-", "-", "-", "-"], ["-", "-", "-", "-"]];

// Reused graphs (positions are [x, y] between 0 and 1)
const PROV_NODES = ["0", "1", "2", "3", "4", "5"];
const PROV_EDGES = [[0, 1], [1, 2], [3, 4]];
const PROV_POS = [[0.08, 0.25], [0.25, 0.75], [0.42, 0.25], [0.62, 0.75], [0.8, 0.25], [0.95, 0.75]];

const PATH_A_NODES = ["0", "1", "2", "3", "4"];
const PATH_A_EDGES = [[0, 1], [0, 2], [1, 3], [3, 4]];
const PATH_A_POS = [[0.08, 0.5], [0.32, 0.2], [0.32, 0.8], [0.62, 0.2], [0.92, 0.2]];

const PATH_B_NODES = ["0", "1", "2", "3", "4", "5"];
const PATH_B_EDGES = [[0, 1], [0, 2], [3, 5], [5, 4], [4, 3]];
const PATH_B_POS = [[0.1, 0.5], [0.3, 0.2], [0.3, 0.8], [0.62, 0.2], [0.9, 0.5], [0.62, 0.8]];

const CLONE_NODES = ["1", "2", "3", "4"];
const CLONE_EDGES = [[0, 1], [1, 2], [2, 3], [3, 0]];
const CLONE_POS = [[0.25, 0.2], [0.75, 0.2], [0.75, 0.8], [0.25, 0.8]];

const COURSE_NODES = ["0", "1", "2", "3"];
const COURSE_EDGES = [[0, 1], [0, 2], [1, 3], [2, 3]];
const COURSE_POS = [[0.1, 0.5], [0.45, 0.15], [0.45, 0.85], [0.88, 0.5]];

const CYCLE_NODES = ["0", "1", "2"];
const CYCLE_EDGES = [[0, 1], [1, 2], [2, 0]];
const CYCLE_POS = [[0.5, 0.12], [0.85, 0.85], [0.15, 0.85]];

const NET_A_NODES = ["1", "2", "3", "4"];
const NET_A_EDGES = [[1, 0, 1], [1, 2, 1], [2, 3, 1]];
const NET_A_POS = [[0.5, 0.15], [0.12, 0.5], [0.5, 0.85], [0.88, 0.85]];

const NET_B_NODES = ["1", "2", "3", "4"];
const NET_B_EDGES = [[0, 1, 4], [0, 2, 1], [2, 1, 1], [1, 3, 1]];
const NET_B_POS = [[0.1, 0.5], [0.5, 0.15], [0.5, 0.85], [0.9, 0.15]];

const WORD_NODES = ["hit", "hot", "dot", "lot", "dog", "log", "cog"];
const WORD_EDGES = [[0, 1], [1, 2], [1, 3], [2, 3], [2, 4], [3, 5], [4, 5], [4, 6], [5, 6]];
const WORD_POS = [[0.08, 0.5], [0.28, 0.5], [0.5, 0.2], [0.5, 0.8], [0.75, 0.2], [0.75, 0.8], [0.94, 0.5]];

// Reused for the recursion and backtracking batch
const FIB_TAGS = { 0: "F0", 1: "F1", 2: "F2", 3: "F3", 4: "F4", 5: "F5", 6: "F6" };
const NQ_EMPTY = [["", "", "", ""], ["", "", "", ""], ["", "", "", ""], ["", "", "", ""]];
const NQ_ONE = [["", "Q", "", ""], ["", "", "", ""], ["", "", "", ""], ["", "", "", ""]];
const WS_BOARD = [["A", "B", "C", "E"], ["S", "F", "C", "S"], ["A", "D", "E", "E"]];

// Reused for the sliding window / greedy / bit / matrix batch
const GRID_9 = [[1, 2, 3], [4, 5, 6], [7, 8, 9]];
const ZERO_3 = [[1, 1, 1], [1, 0, 1], [1, 1, 1]];
const BIT_TAGS = { 0: "0 ones", 1: "1 one", 2: "1 one", 3: "2 ones", 4: "1 one", 5: "2 ones", 6: "2 ones", 7: "3 ones" };

// Reused for the sliding window / greedy / matrix / heap batch (second set)
const M34 = [[1, 3, 5, 7], [10, 11, 16, 20], [23, 30, 34, 60]];
const FLAT_TAGS = Object.fromEntries(
  [...Array(12).keys()].map((i) => [`${Math.floor(i / 4)},${i % 4}`, `i ${i}`])
);

// Reused for the intervals / tries / union-find batch (tries are drawn with the graph renderer)
const TRIE_CAT = {
  nodes: ["•", "c", "a", "t", "r"],
  edges: [[0, 1], [1, 2], [2, 3], [2, 4]],
  pos: [[0.5, 0.08], [0.5, 0.34], [0.5, 0.6], [0.28, 0.9], [0.72, 0.9]],
};
const TRIE_APPLE = {
  nodes: ["•", "a", "p", "p", "l", "e"],
  edges: [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5]],
  pos: [[0.08, 0.4], [0.25, 0.4], [0.42, 0.4], [0.58, 0.4], [0.75, 0.4], [0.92, 0.4]],
};
const TRIE_BDM = {
  nodes: ["•", "b", "d", "m", "a", "a", "a", "d", "d", "d"],
  edges: [[0, 1], [0, 2], [0, 3], [1, 4], [2, 5], [3, 6], [4, 7], [5, 8], [6, 9]],
  pos: [[0.5, 0.06], [0.2, 0.34], [0.5, 0.34], [0.8, 0.34], [0.2, 0.62], [0.5, 0.62], [0.8, 0.62], [0.2, 0.9], [0.5, 0.9], [0.8, 0.9]],
};
const TRIE_ROOTS = {
  nodes: ["•", "c", "a", "t"],
  edges: [[0, 1], [1, 2], [2, 3]],
  pos: [[0.1, 0.4], [0.37, 0.4], [0.63, 0.4], [0.9, 0.4]],
};
const UF_FIVE = {
  nodes: ["0", "1", "2", "3", "4"],
  edges: [[0, 1], [1, 2], [3, 4]],
  pos: [[0.1, 0.3], [0.3, 0.7], [0.5, 0.3], [0.7, 0.7], [0.9, 0.3]],
};
const UF_TRIANGLE = {
  nodes: ["0", "1", "2"],
  edges: [[0, 1], [1, 2], [0, 2]],
  pos: [[0.5, 0.12], [0.85, 0.8], [0.15, 0.8]],
};
const RC_TRIANGLE = {
  nodes: ["1", "2", "3"],
  edges: [[0, 1], [0, 2], [1, 2]],
  pos: [[0.5, 0.12], [0.85, 0.8], [0.15, 0.8]],
};
const TREE_FOUR = {
  nodes: ["1", "2", "3", "4"],
  edges: [[0, 1], [1, 2], [2, 3]],
  pos: [[0.1, 0.4], [0.37, 0.4], [0.63, 0.4], [0.9, 0.4]],
};

// Reused for the graphs / trees / backtracking batch
const MAI_GRID = [[0, 0, 1, 0], [1, 1, 1, 0], [0, 1, 0, 0]];
const SR_BOARD = [["X", "X", "X", "X"], ["X", "O", "O", "X"], ["X", "X", "O", "X"], ["X", "O", "X", "X"]];
// Cells equal to "X" as [row, col] pairs, to fade them so the O cells stand out
const xs = (g) => g.flatMap((row, r) => row.flatMap((v, c) => (v === "X" ? [[r, c]] : [])));
const FLIGHTS = {
  nodes: ["0", "1", "2", "3"],
  edges: [[0, 1, 100], [1, 2, 100], [2, 0, 100], [1, 3, 600], [2, 3, 200]],
  pos: [[0.1, 0.5], [0.42, 0.15], [0.42, 0.85], [0.9, 0.5]],
};
const MST_POINTS = {
  nodes: ["A", "B", "C", "D", "E"],
  edges: [[0, 1, 4], [1, 3, 3], [3, 4, 4], [1, 2, 9], [2, 3, 10], [0, 4, 7]],
  pos: [[0.08, 0.85], [0.28, 0.55], [0.42, 0.08], [0.64, 0.55], [0.92, 0.85]],
};

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




  // ===============================================================
  // BATCH 7: Stack and Queue (problems 49 to 58)
  // Stack strips list items bottom first, so the LAST chip is the top.
  // ===============================================================

  // ---------------------------------------------------------------
  "Valid Parentheses": [
    A(["(", "[", "]", ")"], [
      s("Push every opening bracket onto a stack. The newest one sits on top.", {
        hl: [0], ptrs: { i: 0 }, aux: { label: "stack", items: ["("] },
      }),
      s("[ is an opening bracket too. Push it.", {
        ok: [0], hl: [1], ptrs: { i: 1 }, aux: { label: "stack", items: ["(", "["] },
      }),
      s("] is a closing bracket. We compare it with the top of the stack.", {
        ok: [0], hl: [1, 2], ptrs: { i: 2 }, aux: { label: "stack", items: ["(", "["] },
      }),
      s("The top is [, which matches. Pop it.", {
        ok: [0, 1, 2], ptrs: { i: 2 }, aux: { label: "stack", items: ["("] },
      }),
      s("Next ) matches the ( and pops it. The stack ends up empty. What does that tell us?", {
        ok: [0, 1, 2, 3], ptrs: { i: 3 }, aux: { label: "stack", items: [] },
      }),
    ]),
    A(["(", "[", ")", "]"], [
      s("Now ( [ ) ]. Push ( and then push [.", {
        hl: [1], ptrs: { i: 1 }, aux: { label: "stack", items: ["(", "["] },
      }),
      s(") arrives, a closing bracket. We look at the top of the stack: it is [.", {
        hl: [2], ptrs: { i: 2 }, aux: { label: "stack", items: ["(", "["] },
      }),
      s("The ) needs a ( on top, but the top is [. They do not match.", {
        bad: [1, 2], ptrs: { i: 2 }, aux: { label: "stack", items: ["(", "["] },
      }),
      s("A ( is still waiting lower down. Why must the match be with the top, not with any open bracket?", {
        bad: [1, 2], hl: [0], ptrs: { i: 2 }, aux: { label: "stack", items: ["(", "["] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Min Stack": [
    A([5, 3, 7, 2], [
      s("Every pushed value also remembers the smallest value so far.", {
        hl: [0], aux: { label: "stack", items: ["5 (min 5)"] },
      }),
      s("Push 3. It is smaller, so the smallest so far becomes 3.", {
        ok: [0], hl: [1], aux: { label: "stack", items: ["5 (min 5)", "3 (min 3)"] },
      }),
      s("Push 7. The smallest so far stays 3.", {
        ok: [0, 1], hl: [2],
        aux: { label: "stack", items: ["5 (min 5)", "3 (min 3)", "7 (min 3)"] },
      }),
      s("Push 2. The smallest so far becomes 2.", {
        ok: [0, 1, 2], hl: [3],
        aux: { label: "stack", items: ["5 (min 5)", "3 (min 3)", "7 (min 3)", "2 (min 2)"] },
      }),
      s("To ask for the minimum we only read the top entry. How much work is that?", {
        ok: [0, 1, 2, 3],
        aux: { label: "stack", items: ["5 (min 5)", "3 (min 3)", "7 (min 3)", "2 (min 2)"] },
      }),
    ]),
    A([5, 3, 7, 2], [
      s("The stack holds 5, 3, 7, 2. The smallest value is 2.", {
        ok: [3],
        aux: { label: "stack", items: ["5 (min 5)", "3 (min 3)", "7 (min 3)", "2 (min 2)"] },
      }),
      s("Pop the 2. It was the smallest, so the minimum must change.", {
        bad: [3],
        aux: { label: "stack", items: ["5 (min 5)", "3 (min 3)", "7 (min 3)"] },
      }),
      s("The new top entry says min 3. The old minimum came back with no searching.", {
        bad: [3], hl: [2],
        aux: { label: "stack", items: ["5 (min 5)", "3 (min 3)", "7 (min 3)"] },
      }),
      s("Why would one single variable holding the minimum fail after this pop?", {
        bad: [3], hl: [2],
        aux: { label: "stack", items: ["5 (min 5)", "3 (min 3)", "7 (min 3)"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Implement Queue using Stacks": [
    A([1, 2, 3], [
      s("Items arrive in the order 1, 2, 3. A queue must hand back 1 first.", {
        ptrs: { i: 0 }, aux: { label: "stack 1", items: [] },
      }),
      s("We push them onto a stack. 1 goes in first, so it sits at the bottom.", {
        hl: [0], ptrs: { i: 0 }, aux: { label: "stack 1", items: ["1"] },
      }),
      s("2 and 3 pile on top of it.", {
        ok: [0, 1, 2], ptrs: { i: 2 }, aux: { label: "stack 1", items: ["1", "2", "3"] },
      }),
      s("Pop from this stack and 3 comes out first, but a queue needs 1. What can we do?", {
        ok: [0, 1], bad: [2], aux: { label: "stack 1", items: ["1", "2", "3"] },
      }),
    ]),
    A([1, 2, 3], [
      s("Pour stack 1 into a second stack, taking items from the top one by one.", {
        hl: [2], aux: { label: "stack 2", items: [] },
      }),
      s("3 moves over first.", {
        ok: [2], aux: { label: "stack 2", items: ["3"] },
      }),
      s("Then 2, then 1.", {
        ok: [0, 1, 2], aux: { label: "stack 2", items: ["3", "2", "1"] },
      }),
      s("Now 1 is on top of stack 2. The order has flipped.", {
        hl: [0], aux: { label: "stack 2", items: ["3", "2", "1"] },
      }),
      s("When must we pour, and when can we leave stack 2 alone?", {
        hl: [0], aux: { label: "stack 2", items: ["3", "2", "1"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Implement Stack using Queues": [
    A([1, 2, 3], [
      s("A queue gives back the oldest item first. A stack must give back the newest.", {
        aux: { label: "queue", items: [] },
      }),
      s("We add 1, 2, 3 to the queue, one at a time at the back.", {
        ok: [0, 1, 2], aux: { label: "queue", items: ["1", "2", "3"] },
      }),
      s("The front of the queue is 1, but a stack should hand back 3.", {
        hl: [0, 2], tags: { 0: "front", 2: "newest" },
        aux: { label: "queue", items: ["1", "2", "3"] },
      }),
      s("How can we bring the newest item to the front?", {
        hl: [2], tags: { 2: "newest" }, aux: { label: "queue", items: ["1", "2", "3"] },
      }),
    ]),
    A([1, 2, 3], [
      s("The queue holds 1, 2 and we have just added 3 at the back.", {
        hl: [2], tags: { 0: "front" },
      }),
      s("Move 1 from the front to the back.", {
        values: [2, 3, 1], hl: [2], tags: { 0: "front" },
      }),
      s("Move 2 from the front to the back as well.", {
        values: [3, 1, 2], hl: [2], tags: { 0: "front" },
      }),
      s("Now 3 is at the front. Removing from the front gives the newest item.", {
        values: [3, 1, 2], ok: [0], tags: { 0: "front" },
      }),
      s("How many items did we have to move, and when did we do it?", {
        values: [3, 1, 2], ok: [0], tags: { 0: "front" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Daily Temperatures": [
    A([73, 74, 75, 71, 69, 72, 76, 73], [
      s("For each day, how many days until a warmer one? A stack keeps the days still waiting.", {
        ptrs: { i: 0 }, aux: { label: "waiting", items: [] },
      }),
      s("Day 0 is 73. No warmer day yet, so it waits.", {
        hl: [0], ptrs: { i: 0 }, aux: { label: "waiting", items: ["73"] },
      }),
      s("Day 1 is 74, warmer than 73. The wait of 73 is over: 1 day.", {
        ok: [0], hl: [1], ptrs: { i: 1 }, tags: { 0: "1 day" },
        aux: { label: "waiting", items: ["74"] },
      }),
      s("Day 2 is 75, warmer than 74. The wait of 74 is over: 1 day.", {
        ok: [0, 1], hl: [2], ptrs: { i: 2 }, tags: { 0: "1 day", 1: "1 day" },
        aux: { label: "waiting", items: ["75"] },
      }),
      s("Day 3 is 71, cooler than 75. So 75 keeps waiting, and 71 joins it.", {
        ok: [0, 1], hl: [3], ptrs: { i: 3 }, tags: { 0: "1 day", 1: "1 day" },
        aux: { label: "waiting", items: ["75", "71"] },
      }),
    ]),
    A([73, 74, 75, 71, 69, 72, 76, 73], [
      s("By day 4 the stack holds 75, 71, 69. All of them are still waiting.", {
        hl: [2, 3, 4], ptrs: { i: 4 }, aux: { label: "waiting", items: ["75", "71", "69"] },
      }),
      s("Day 5 is 72, warmer than 69 on top. The wait of 69 is over: 1 day.", {
        ok: [4], hl: [5], ptrs: { i: 5 }, tags: { 4: "1 day" },
        aux: { label: "waiting", items: ["75", "71"] },
      }),
      s("72 is warmer than 71 as well. The wait of 71 is over: 2 days.", {
        ok: [3, 4], hl: [5], ptrs: { i: 5 }, tags: { 3: "2 days", 4: "1 day" },
        aux: { label: "waiting", items: ["75"] },
      }),
      s("72 is not warmer than 75, so we stop and push 72.", {
        ok: [3, 4], hl: [5], ptrs: { i: 5 }, tags: { 3: "2 days", 4: "1 day" },
        aux: { label: "waiting", items: ["75", "72"] },
      }),
      s("Day 6 is 76 and clears both 72 and 75. Is each day pushed and removed at most once?", {
        ok: [2, 3, 4, 5], hl: [6], ptrs: { i: 6 },
        tags: { 2: "4 days", 3: "2 days", 4: "1 day", 5: "1 day" },
        aux: { label: "waiting", items: ["76"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Next Greater Element I": [
    A([1, 3, 4, 2], [
      s("Find the next greater number for each value in 1 3 4 2. A stack holds values still waiting.", {
        aux: { label: "waiting", items: [] },
      }),
      s("1 goes on the stack to wait.", {
        hl: [0], ptrs: { i: 0 }, aux: { label: "waiting", items: ["1"] },
      }),
      s("3 is greater than 1, so 3 is the answer for 1. 3 then waits.", {
        ok: [0], hl: [1], ptrs: { i: 1 }, tags: { 0: "next 3" },
        aux: { label: "waiting", items: ["3"] },
      }),
      s("4 is greater than 3, so 4 is the answer for 3. 4 then waits.", {
        ok: [0, 1], hl: [2], ptrs: { i: 2 }, tags: { 0: "next 3", 1: "next 4" },
        aux: { label: "waiting", items: ["4"] },
      }),
      s("2 is smaller than 4, so it just waits behind it. What happens to values still waiting at the end?", {
        ok: [0, 1], hl: [3], ptrs: { i: 3 }, tags: { 0: "next 3", 1: "next 4" },
        aux: { label: "waiting", items: ["4", "2"] },
      }),
    ]),
    A([4, 1, 2], [
      s("Answers are kept in a map: 1→3, 3→4, 4→-1, 2→-1. Here -1 means none. The queries are 4, 1, 2.", {
        aux: { label: "map", items: ["1→3", "3→4", "4→-1", "2→-1"] },
      }),
      s("Look up 4 in the map.", {
        hl: [0], tags: { 0: "-1" },
        aux: { label: "map", items: ["1→3", "3→4", "4→-1", "2→-1"] },
      }),
      s("Look up 1.", {
        ok: [0], hl: [1], tags: { 0: "-1", 1: "3" },
        aux: { label: "map", items: ["1→3", "3→4", "4→-1", "2→-1"] },
      }),
      s("Look up 2.", {
        ok: [0, 1], hl: [2], tags: { 0: "-1", 1: "3", 2: "-1" },
        aux: { label: "map", items: ["1→3", "3→4", "4→-1", "2→-1"] },
      }),
      s("Each query was a single lookup. Why did we build the map from the second array?", {
        ok: [0, 1, 2], tags: { 0: "-1", 1: "3", 2: "-1" },
        aux: { label: "map", items: ["1→3", "3→4", "4→-1", "2→-1"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Evaluate Reverse Polish Notation": [
    A(["2", "1", "+", "3", "*"], [
      s("Numbers go onto a stack. An operator works on the top two numbers.", {
        ptrs: { i: 0 }, aux: { label: "stack", items: [] },
      }),
      s("Push 2.", {
        hl: [0], ptrs: { i: 0 }, aux: { label: "stack", items: ["2"] },
      }),
      s("Push 1.", {
        ok: [0], hl: [1], ptrs: { i: 1 }, aux: { label: "stack", items: ["2", "1"] },
      }),
      s("+ takes the top two, 1 and 2, adds them and pushes the result back.", {
        ok: [0, 1], hl: [2], ptrs: { i: 2 }, aux: { label: "stack", items: ["3"] },
      }),
      s("Push 3. Now * is next, with two numbers on the stack. What will it do?", {
        ok: [0, 1, 2], hl: [3], ptrs: { i: 3 }, aux: { label: "stack", items: ["3", "3"] },
      }),
    ]),
    A(["4", "3", "-"], [
      s("Now 4 3 -. Push 4, then push 3.", {
        hl: [1], ptrs: { i: 1 }, aux: { label: "stack", items: ["4", "3"] },
      }),
      s("- pops two numbers. The first popped is 3, the second is 4.", {
        hl: [2], ptrs: { i: 2 }, tags: { 1: "popped 1st", 0: "popped 2nd" },
        aux: { label: "stack", items: ["4", "3"] },
      }),
      s("Subtraction cares about order. Which one is on the left of the minus?", {
        hl: [0, 1], ptrs: { i: 2 }, tags: { 1: "popped 1st", 0: "popped 2nd" },
        aux: { label: "stack", items: ["4", "3"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Sliding Window Maximum": [
    A([1, 3, -1, -3, 5, 3, 6, 7], [
      s("A window of 3 slides along. A deque keeps candidates for the maximum, the biggest at the front.", {
        hl: [0, 1, 2], ptrs: { l: 0, r: 2 }, aux: { label: "deque", items: [] },
      }),
      s("Add 1 to the deque.", {
        hl: [0], ptrs: { r: 0 }, aux: { label: "deque", items: ["1"] },
      }),
      s("3 arrives and is bigger than 1. The 1 can never be the maximum again, so it goes.", {
        bad: [0], hl: [1], ptrs: { r: 1 }, aux: { label: "deque", items: ["3"] },
      }),
      s("-1 arrives. It is smaller than 3, so it waits behind 3.", {
        bad: [0], hl: [2], ptrs: { r: 2 }, aux: { label: "deque", items: ["3", "-1"] },
      }),
      s("The first window is full. Which number sits at the front of the deque?", {
        bad: [0], hl: [1], ptrs: { l: 0, r: 2 }, tags: { 1: "front" },
        aux: { label: "deque", items: ["3", "-1"] },
      }),
    ]),
    A([1, 3, -1, -3, 5, 3, 6, 7], [
      s("The window holds 3, -1, -3. The front of the deque is 3.", {
        hl: [1], ptrs: { l: 1, r: 3 }, aux: { label: "deque", items: ["3", "-1", "-3"] },
      }),
      s("Slide right. The window now starts at -1, so that 3 has fallen out of it.", {
        bad: [1], hl: [4], ptrs: { l: 2, r: 4 }, aux: { label: "deque", items: ["3", "-1", "-3"] },
      }),
      s("The front of the deque is outside the window, so we remove it from the front.", {
        bad: [1], hl: [4], ptrs: { l: 2, r: 4 }, aux: { label: "deque", items: ["-1", "-3"] },
      }),
      s("5 arrives. It beats -3 and -1, so both leave from the back. Only 5 remains.", {
        bad: [1, 2, 3], hl: [4], ptrs: { l: 2, r: 4 }, aux: { label: "deque", items: ["5"] },
      }),
      s("Two kinds of removal happened, one at each end. Why does each one make sense?", {
        bad: [1, 2, 3], ok: [4], ptrs: { l: 2, r: 4 }, aux: { label: "deque", items: ["5"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Largest Rectangle in Histogram": [
    A([2, 1, 5, 6, 2, 3], [
      s("Bars have heights 2 1 5 6 2 3. A rectangle can only be as tall as its shortest bar.", {
        hl: [0, 1, 2, 3, 4, 5],
      }),
      s("Pick the bar of height 5. How far can a rectangle of height 5 stretch?", {
        hl: [2],
      }),
      s("To the right, the bar of height 6 is tall enough.", {
        ok: [2, 3],
      }),
      s("The next bar, height 2, is shorter than 5, so the stretch stops there.", {
        ok: [2, 3], bad: [4],
      }),
      s("To the left, the bar of height 1 is shorter, so it stops there too. What area is that?", {
        ok: [2, 3], bad: [1, 4], tags: { 2: "h 5", 3: "w 2" },
      }),
    ]),
    A([2, 1, 5, 6, 2, 3], [
      s("Keep a stack of bars with growing heights. The 2 goes on first.", {
        hl: [0], aux: { label: "stack", items: ["2"] },
      }),
      s("1 is shorter than 2, so the 2 can not stretch further right. Take it off.", {
        bad: [0], hl: [1], aux: { label: "stack", items: ["1"] },
      }),
      s("5 and 6 keep growing, so both go on the stack.", {
        hl: [2, 3], aux: { label: "stack", items: ["1", "5", "6"] },
      }),
      s("2 arrives, shorter than 6 and 5. Both stop here and get measured.", {
        bad: [2, 3], hl: [4], aux: { label: "stack", items: ["1", "2"] },
      }),
      s("Each bar is pushed once and popped once. Why does a shorter bar settle the taller ones?", {
        ok: [4], aux: { label: "stack", items: ["1", "2"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Number of Recent Calls": [
    A([1, 100, 3001, 3002], [
      s("Each ping time goes into a queue. We only count pings from the last 3000 ms.", {
        aux: { label: "queue", items: [] },
      }),
      s("Ping at time 1 arrives.", {
        hl: [0], aux: { label: "queue", items: ["1"] },
      }),
      s("Ping at time 100 arrives. Both pings are within 3000 ms.", {
        ok: [0], hl: [1], aux: { label: "queue", items: ["1", "100"] },
      }),
      s("Ping at 3001 arrives. The window runs from 1 to 3001, so all three count.", {
        ok: [0, 1], hl: [2], aux: { label: "queue", items: ["1", "100", "3001"] },
      }),
      s("Ping at 3002 arrives. The window now starts at 2. Is the ping at 1 still inside?", {
        ok: [1, 2], bad: [0], hl: [3],
        aux: { label: "queue", items: ["1", "100", "3001", "3002"] },
      }),
    ]),
    A([1, 100, 3001, 3002], [
      s("The window for 3002 is 2 to 3002. The oldest ping, at 1, is too old.", {
        bad: [0], hl: [3], aux: { label: "queue", items: ["1", "100", "3001", "3002"] },
      }),
      s("We remove it from the front of the queue.", {
        bad: [0], hl: [3], aux: { label: "queue", items: ["100", "3001", "3002"] },
      }),
      s("The next oldest ping, 100, is inside the window.", {
        bad: [0], ok: [1, 2, 3], aux: { label: "queue", items: ["100", "3001", "3002"] },
      }),
      s("We stop removing. Why can we stop at the first ping that is still fresh?", {
        bad: [0], ok: [1, 2, 3], aux: { label: "queue", items: ["100", "3001", "3002"] },
      }),
    ]),
  ],


  // ===============================================================
  // BATCH 9: Dynamic Programming (new problems 1 to 10)
  // Unique Paths, Longest Common Subsequence and Edit Distance are in BATCH 11
  // below, because they use the "grid" renderer.
  // ===============================================================

  // ---------------------------------------------------------------
  "House Robber": [
    A([2, 7, 9, 3, 1], [
      s("Each number is the cash in a house. Robbing two neighbors sets off the alarm.", {}),
      s("Rob the first house, which holds 2.", {
        hl: [0],
      }),
      s("Its neighbor holds 7, but robbing both would trigger the alarm.", {
        ok: [0], bad: [1],
      }),
      s("Skip it, and the house after that is safe to rob. 2 and 9 are not neighbors.", {
        ok: [0, 2], bad: [1],
      }),
      s("At every house we choose: rob it, or skip it. What should that choice depend on?", {
        ok: [0, 2], bad: [1], hl: [3],
      }),
    ]),
    A([2, 7, 9, 3, 1], [
      s("Track the best total up to each house. At house 1 the best is 2.", {
        hl: [0], tags: { 0: "2" }, aux: { label: "best", items: ["2"] },
      }),
      s("At house 2: rob 7 alone, or keep 2. The best is 7.", {
        hl: [1], tags: { 0: "2", 1: "7" }, aux: { label: "best", items: ["2", "7"] },
      }),
      s("At house 3: rob 9 plus the best from two houses back (2), or keep 7. The best is 11.", {
        ok: [0], hl: [2], tags: { 0: "2", 1: "7", 2: "11" },
        aux: { label: "best", items: ["2", "7", "11"] },
      }),
      s("At house 4: 3 plus the best from two back (7) is 10, less than 11. The best stays 11.", {
        ok: [1], hl: [3], tags: { 1: "7", 2: "11", 3: "11" },
        aux: { label: "best", items: ["2", "7", "11", "11"] },
      }),
      s("Each answer only used the two answers before it. How many do we really need to remember?", {
        ok: [2, 3], tags: { 2: "11", 3: "11" },
        aux: { label: "best", items: ["2", "7", "11", "11"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Coin Change": [
    A([0, "-", "-", "-", "-", "-", "-", "-"], [
      s("Cell n holds the fewest coins to make n. The coins are 1, 2 and 5. Making 0 takes 0 coins.", {
        hl: [0],
      }),
      s("To make 1, add a 1-coin to the answer for 0. That is 1 coin.", {
        values: [0, 1, "-", "-", "-", "-", "-", "-"], ok: [0], hl: [1],
      }),
      s("To make 2, add a 2-coin to the answer for 0. That is 1 coin, better than 1 + 1.", {
        values: [0, 1, 1, "-", "-", "-", "-", "-"], ok: [0], hl: [2], tags: { 2: "2-coin" },
      }),
      s("To make 3, add a 2-coin to the answer for 1. That is 2 coins.", {
        values: [0, 1, 1, 2, "-", "-", "-", "-"], ok: [1], hl: [3],
      }),
      s("Each cell looks back at cells one coin away. Which cells would 7 look back at?", {
        values: [0, 1, 1, 2, "-", "-", "-", "-"], hl: [7],
      }),
    ]),
    A([0, 1, 1, 2, 2, 1, 2, 2], [
      s("Now every cell is filled. Let us see how the cell for 7 got its value.", {
        hl: [7],
      }),
      s("With a 1-coin we look at cell 6, which holds 2. That gives 3 coins.", {
        hl: [7, 6], tags: { 6: "2 + 1 = 3" },
      }),
      s("With a 2-coin we look at cell 5, which holds 1. That gives 2 coins.", {
        hl: [7, 5], tags: { 5: "1 + 1 = 2" },
      }),
      s("With a 5-coin we look at cell 2, which holds 1. That gives 2 coins.", {
        hl: [7, 2], tags: { 2: "1 + 1 = 2" },
      }),
      s("We keep the smallest of these. What if none of the coins fits at all?", {
        ok: [7],
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Longest Increasing Subsequence": [
    A([10, 9, 2, 5, 3, 7, 101, 18], [
      s("Each number can end a rising chain. We track the longest chain ending at each spot.", {
        hl: [0], tags: { 0: "1" },
      }),
      s("9 is not bigger than 10, so it starts its own chain.", {
        bad: [0], hl: [1], tags: { 0: "1", 1: "1" },
      }),
      s("2 starts a chain too.", {
        hl: [2], tags: { 0: "1", 1: "1", 2: "1" },
      }),
      s("5 is bigger than 2, so it extends the chain of 2. Chain length 2.", {
        ok: [2], hl: [3], tags: { 0: "1", 1: "1", 2: "1", 3: "2" },
      }),
      s("3 is also bigger than 2, so it extends that chain. Chain length 2.", {
        ok: [2], hl: [4], tags: { 0: "1", 1: "1", 2: "1", 3: "2", 4: "2" },
      }),
      s("Now 7. Which earlier chains can it extend?", {
        hl: [5], tags: { 0: "1", 1: "1", 2: "1", 3: "2", 4: "2" },
      }),
    ]),
    A([10, 9, 2, 5, 3, 7, 101, 18], [
      s("Here are the chain lengths ending at every number.", {
        tags: { 0: "1", 1: "1", 2: "1", 3: "2", 4: "2", 5: "3", 6: "4", 7: "4" },
      }),
      s("101 ends a chain of 4: 2, 3, 7, 101.", {
        ok: [2, 4, 5, 6], tags: { 0: "1", 1: "1", 2: "1", 3: "2", 4: "2", 5: "3", 6: "4", 7: "4" },
      }),
      s("18 also ends a chain of 4: 2, 3, 7, 18.", {
        ok: [2, 4, 5, 7], tags: { 0: "1", 1: "1", 2: "1", 3: "2", 4: "2", 5: "3", 6: "4", 7: "4" },
      }),
      s("The longest chain can end at any spot. Where should we look for the final answer?", {
        hl: [6, 7], tags: { 0: "1", 1: "1", 2: "1", 3: "2", 4: "2", 5: "3", 6: "4", 7: "4" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------


  // ---------------------------------------------------------------
  "Word Break": [
    A(["l", "e", "e", "t", "c", "o", "d", "e"], [
      s("Can leetcode be cut into dictionary words? The words are leet and code.", {
        aux: { label: "words", items: ["leet", "code"] },
      }),
      s("Try the first 4 letters. leet is in the dictionary.", {
        hl: [0, 1, 2, 3], aux: { label: "words", items: ["leet", "code"] },
      }),
      s("So the first 4 letters are fine. We mark this cut spot as reachable.", {
        ok: [0, 1, 2, 3], tags: { 3: "reachable" }, aux: { label: "words", items: ["leet", "code"] },
      }),
      s("From that spot, the remaining letters spell code, which is also a word.", {
        ok: [0, 1, 2, 3], hl: [4, 5, 6, 7], tags: { 3: "reachable" },
        aux: { label: "words", items: ["leet", "code"] },
      }),
      s("Each cut spot is only useful if we could reach it. What does reachable mean here?", {
        ok: [0, 1, 2, 3, 4, 5, 6, 7], tags: { 3: "reachable", 7: "end" },
        aux: { label: "words", items: ["leet", "code"] },
      }),
    ]),
    A(["c", "a", "t", "s", "a", "n", "d", "o", "g"], [
      s("Now catsandog, with the words cat, cats, and, sand and dog. Try cat first.", {
        hl: [0, 1, 2], aux: { label: "words", items: ["cat", "cats", "and", "sand", "dog"] },
      }),
      s("cat is a word, so the spot after it is reachable.", {
        ok: [0, 1, 2], tags: { 2: "reachable" },
        aux: { label: "words", items: ["cat", "cats", "and", "sand", "dog"] },
      }),
      s("From there, sand is a word, so we move on.", {
        ok: [0, 1, 2], hl: [3, 4, 5, 6], tags: { 2: "reachable" },
        aux: { label: "words", items: ["cat", "cats", "and", "sand", "dog"] },
      }),
      s("Only og is left, and it is not a word. This way is a dead end.", {
        ok: [0, 1, 2, 3, 4, 5, 6], bad: [7, 8], tags: { 2: "reachable" },
        aux: { label: "words", items: ["cat", "cats", "and", "sand", "dog"] },
      }),
      s("Cutting cats then and also ends with og. Why must we try every cut spot before saying no?", {
        hl: [0, 1, 2, 3], bad: [7, 8],
        aux: { label: "words", items: ["cat", "cats", "and", "sand", "dog"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Partition Equal Subset Sum": [
    A([1, 5, 11, 5], [
      s("Can we split the numbers into two groups with the same sum? The total is 22.", {
        hl: [0, 1, 2, 3], out: "total 22",
      }),
      s("Two equal groups must each add up to half the total, which is 11.", {
        hl: [0, 1, 2, 3], out: "each group 11",
      }),
      s("Try 11 on its own. That group reaches 11 exactly.", {
        ok: [2], out: "group A: 11",
      }),
      s("The rest, 1, 5 and 5, also add up to 11.", {
        ok: [2], hl: [0, 1, 3], out: "group A: 11 | group B: 11",
      }),
      s("So the question becomes: can some of the numbers add up to exactly 11?", {
        ok: [0, 1, 2, 3], out: "can we reach 11?",
      }),
    ]),
    A([1, 5, 11, 5], [
      s("Track which sums we can make. At the start we can only make 0.", {
        aux: { label: "reachable", items: ["0"] },
      }),
      s("Use the 1. Now 0 and 1 are reachable.", {
        hl: [0], aux: { label: "reachable", items: ["0", "1"] },
      }),
      s("Use the 5. Every old sum plus 5 is reachable too, which adds 5 and 6.", {
        ok: [0], hl: [1], aux: { label: "reachable", items: ["0", "1", "5", "6"] },
      }),
      s("Use the 11. Starting from 0, that reaches 11, our target.", {
        ok: [0, 1], hl: [2], aux: { label: "reachable", items: ["0", "1", "5", "6", "11"] },
      }),
      s("We reached the target half. Does it matter which numbers were used to get there?", {
        ok: [0, 1, 2], aux: { label: "reachable", items: ["0", "1", "5", "6", "11"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Min Cost Climbing Stairs": [
    A([10, 15, 20], [
      s("Each step has a cost. We can start on step 0 or step 1, and climb 1 or 2 steps at a time.", {
        hl: [0, 1],
      }),
      s("The top is just past the last step.", {
        hl: [2], tags: { 2: "last step" },
      }),
      s("To land on the top, we jump from step 2 or from step 1.", {
        hl: [1, 2],
      }),
      s("Jumping from step 1 means paying 15 and skipping over step 2.", {
        ok: [1], bad: [2], tags: { 1: "pay 15" },
      }),
      s("Jumping from step 2 means paying 20. Which way costs less to reach the top?", {
        hl: [2], tags: { 1: "pay 15", 2: "pay 20" },
      }),
    ]),
    A([10, 15, 20], [
      s("Track the cheapest cost to stand on each step, counting its own cost. Step 0 costs 10.", {
        hl: [0], tags: { 0: "10" },
      }),
      s("Step 1 can also be a starting step. It costs 15.", {
        hl: [1], tags: { 0: "10", 1: "15" },
      }),
      s("Step 2 comes from step 1 (15) or step 0 (10). The cheaper is 10, plus 20 for this step.", {
        ok: [0], hl: [2], tags: { 0: "10", 1: "15", 2: "30" },
      }),
      s("The top can be reached from step 2 (30) or step 1 (15). Which do we compare for the final answer?", {
        hl: [1, 2], tags: { 0: "10", 1: "15", 2: "30" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------

  // ---------------------------------------------------------------
  "Decode Ways": [
    A(["2", "2", "6"], [
      s("Each letter is a number from 1 to 26. How many ways can 226 be read?", {
        hl: [0, 1, 2],
      }),
      s("Read 2, 2 and 6 one at a time: B, B, F.", {
        hl: [0], out: "2 | 2 | 6",
      }),
      s("Or read 22 together as one letter, then 6 alone.", {
        hl: [0, 1], out: "22 | 6",
      }),
      s("Or read 2 alone, then 26 together as one letter.", {
        hl: [1, 2], out: "2 | 26",
      }),
      s("Some cuts worked here. Which pairs of digits are allowed to be read as one letter?", {
        ok: [0, 1, 2], out: "2 | 2 | 6",
      }),
    ]),
    A(["1", "0", "6"], [
      s("Now 106. There is a 0 in the middle, and no letter is 0.", {
        hl: [1],
      }),
      s("A lone 0 cannot be read as a letter.", {
        bad: [1],
      }),
      s("So the 0 has to join the digit before it. 10 is allowed.", {
        ok: [0, 1],
      }),
      s("Then the 6 stands alone as the last letter.", {
        ok: [0, 1, 2], out: "10 | 6",
      }),
      s("What if the digits were 306 instead? Would 30 be allowed as one letter?", {
        hl: [0, 1], out: "10 | 6",
      }),
    ]),
  ],

  // ===============================================================
  // BATCH 10: Linked Lists, using the "list" renderer (problems 38 to 48)
  // A top-level next: {...} is the starting wiring for every step.
  // A step's own next: {...} replaces it for that step, so repeat the full map.
  // A pointer index equal to values.length points at the "null" slot.
  // ===============================================================

  // ---------------------------------------------------------------
  "Insertion Sort List": [
    L([4, 2, 1, 3], [
      s("Insertion sort keeps a sorted part on the left and takes the next node from the rest.", {
        ok: [0], ptrs: { next: 1 },
      }),
      s("Take 2. It is smaller than 4, so it has to go in front of it.", {
        ok: [0], hl: [1], ptrs: { next: 1 },
      }),
      s("Insert it before 4. The sorted part is now 2, 4.", {
        values: [2, 4, 1, 3], ok: [0, 1], ptrs: { next: 2 },
      }),
      s("Take 1. It is smaller than everything sorted so far, so it goes to the very front.", {
        values: [1, 2, 4, 3], ok: [0, 1, 2], hl: [0], ptrs: { next: 3 },
      }),
      s("Now 3. Where in the sorted part does it belong?", {
        values: [1, 2, 4, 3], ok: [0, 1, 2], hl: [3], ptrs: { next: 3 },
      }),
    ]),
    L([1, 2, 4, 3], [
      s("The sorted part is 1, 2, 4. The next node to place is 3.", {
        ok: [0, 1, 2], hl: [3], ptrs: { take: 3 },
      }),
      s("Walk along the sorted part until the next value is bigger than 3.", {
        ok: [0, 1, 2], hl: [3], ptrs: { look: 1 }, tags: { 1: "2 < 3", 2: "4 > 3" },
      }),
      s("Lift 3 out of its place. The 4 before it now points to nothing.", {
        ok: [0, 1, 2], hl: [3], next: { 2: N }, hlNext: [2],
      }),
      s("Insert 3 after 2: the 2 points to 3, and the 3 points to 4.", {
        ok: [0, 1, 2], hl: [3], next: { 1: 3, 3: 2, 2: N }, hlNext: [1, 3],
      }),
      s("Only a few arrows changed and no value moved. How is that different from shifting values in an array?", {
        ok: [0, 1, 2, 3], next: { 1: 3, 3: 2, 2: N },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Reverse Linked List": [
    L([1, 2, 3, 4], [
      s("Reversing means every arrow must flip. prev starts at nothing and curr at the head.", {
        hl: [0], ptrs: { prev: 4, curr: 0 },
      }),
      s("Flip the arrow of 1 so it points at prev, which is nothing.", {
        hl: [0], next: { 0: N }, hlNext: [0], ptrs: { prev: 4, curr: 0 },
      }),
      s("Move forward: prev steps onto 1 and curr steps onto 2.", {
        hl: [1], ok: [0], next: { 0: N }, ptrs: { prev: 0, curr: 1 },
      }),
      s("Flip the arrow of 2 so it points back at 1.", {
        hl: [1], ok: [0], next: { 0: N, 1: 0 }, hlNext: [1], ptrs: { prev: 0, curr: 1 },
      }),
      s("Move forward again. Each step flips one arrow and moves both pointers. How does it finish?", {
        hl: [2], ok: [0, 1], next: { 0: N, 1: 0 }, ptrs: { prev: 1, curr: 2 },
      }),
    ]),
    L([1, 2, 3, 4], [
      s("Look at the node 2. Its arrow still leads on to 3.", {
        hl: [1], ok: [0], next: { 0: N }, ptrs: { prev: 0, curr: 1 },
      }),
      s("If we flip it back at 1 right away, the way to 3 and 4 is lost.", {
        hl: [1], bad: [2, 3], next: { 0: N, 1: 0 }, hlNext: [1], ptrs: { prev: 0, curr: 1 },
      }),
      s("So first we save where the arrow led. A third pointer, next, remembers node 3.", {
        hl: [2], ok: [0], next: { 0: N }, ptrs: { prev: 0, curr: 1, next: 2 },
      }),
      s("Now it is safe to flip the arrow of 2.", {
        hl: [1], ok: [0], next: { 0: N, 1: 0 }, hlNext: [1], ptrs: { prev: 0, curr: 1, next: 2 },
      }),
      s("Then everything moves forward, and curr goes to the saved node. What would go wrong without it?", {
        hl: [2], ok: [0, 1], next: { 0: N, 1: 0 }, ptrs: { prev: 1, curr: 2 },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Merge Two Sorted Lists": [
    L([1, 2, 4], [
      s("Two sorted lists. A pointer sits at the head of each.", {
        ptrs: { a: 0 }, ptrs2: { b: 0 }, aux: { label: "merged", items: [] },
      }),
      s("Compare 1 and 1. They are equal, so we can take either. We take the one from l1.", {
        hl: [0], hl2: [0], ptrs: { a: 0 }, ptrs2: { b: 0 }, aux: { label: "merged", items: [] },
      }),
      s("The 1 from l1 joins the merged list, and l1's pointer moves on.", {
        ok: [0], ptrs: { a: 1 }, ptrs2: { b: 0 }, aux: { label: "merged", items: ["1"] },
      }),
      s("Compare 2 and 1. The 1 in l2 is smaller, so it comes next.", {
        ok: [0], hl: [1], hl2: [0], ptrs: { a: 1 }, ptrs2: { b: 0 },
        aux: { label: "merged", items: ["1"] },
      }),
      s("It joins the merged list, and l2's pointer moves on.", {
        ok: [0], ok2: [0], ptrs: { a: 1 }, ptrs2: { b: 1 },
        aux: { label: "merged", items: ["1", "1"] },
      }),
      s("Compare 2 and 3. Which one goes next?", {
        ok: [0], ok2: [0], hl: [1], hl2: [1], ptrs: { a: 1 }, ptrs2: { b: 1 },
        aux: { label: "merged", items: ["1", "1"] },
      }),
    ], { values2: [1, 3, 4], names: ["l1", "l2"] }),
    L([5], [
      s("Now the lists are 5 and 1, 2, 3. A pointer sits at the head of each.", {
        ptrs: { a: 0 }, ptrs2: { b: 0 }, aux: { label: "merged", items: [] },
      }),
      s("1, 2 and 3 are all smaller than 5, so all of them are taken first.", {
        ok2: [0, 1, 2], ptrs: { a: 0 }, ptrs2: { b: 3 },
        aux: { label: "merged", items: ["1", "2", "3"] },
      }),
      s("The second list is finished. The 5 is still waiting in the first list.", {
        hl: [0], ok2: [0, 1, 2], ptrs: { a: 0 }, ptrs2: { b: 3 }, tags2: { 3: "end" },
        aux: { label: "merged", items: ["1", "2", "3"] },
      }),
      s("Nothing is left to compare. What happens to the rest of the first list?", {
        hl: [0], ok2: [0, 1, 2], ptrs: { a: 0 }, ptrs2: { b: 3 },
        aux: { label: "merged", items: ["1", "2", "3"] },
      }),
    ], { values2: [1, 2, 3], names: ["l1", "l2"] }),
  ],

  // ---------------------------------------------------------------
  "Linked List Cycle": [
    L([3, 2, 0, -4], [
      s("Two pointers start at the head. The last node points back to the second node.", {
        hlNext: [3], ptrs: { slow: 0, fast: 0 },
      }),
      s("Each round, slow moves 1 step and fast moves 2 steps.", {
        hl: [1, 2], ptrs: { slow: 1, fast: 2 },
      }),
      s("Next round. Fast ran off the tail into the loop and came back around, and it is now behind slow.", {
        hl: [2, 1], ptrs: { slow: 2, fast: 1 },
      }),
      s("One more round. Slow steps to the last node, and fast lands on the very same node.", {
        ok: [3], ptrs: { slow: 3, fast: 3 },
      }),
      s("The two pointers meet on one node. What does that tell us about the list?", {
        ok: [3], ptrs: { slow: 3, fast: 3 },
      }),
    ], { next: { 3: 1 } }),
    L([3, 2, 0, -4], [
      s("This list has no loop. The last node points at nothing.", {
        ptrs: { slow: 0, fast: 0 },
      }),
      s("Slow moves 1 step and fast moves 2.", {
        hl: [1, 2], ptrs: { slow: 1, fast: 2 },
      }),
      s("Again. Fast jumps past the last node and reaches the end of the list.", {
        hl: [2], ptrs: { slow: 2, fast: 4 }, tags: { 4: "end" },
      }),
      s("Fast ran out of list, so it can never come back around to meet slow. What should we conclude?", {
        hl: [2], ptrs: { slow: 2, fast: 4 }, tags: { 4: "end" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Middle of the Linked List": [
    L([1, 2, 3, 4, 5], [
      s("Slow and fast both start at the head.", {
        ptrs: { slow: 0, fast: 0 },
      }),
      s("Slow takes 1 step. Fast takes 2.", {
        ptrs: { slow: 1, fast: 2 },
      }),
      s("Again. Slow is on 3 and fast is on 5.", {
        hl: [2], ptrs: { slow: 2, fast: 4 },
      }),
      s("Fast is on the last node and cannot take another full step. Where is slow sitting?", {
        hl: [2, 4], ptrs: { slow: 2, fast: 4 }, tags: { 4: "last" },
      }),
    ]),
    L([1, 2, 3, 4, 5, 6], [
      s("Now there are 6 nodes. Both pointers start at the head.", {
        ptrs: { slow: 0, fast: 0 },
      }),
      s("Slow takes 1 step. Fast takes 2.", {
        ptrs: { slow: 1, fast: 2 },
      }),
      s("Again. Slow is on 3 and fast is on 5.", {
        ptrs: { slow: 2, fast: 4 },
      }),
      s("Slow moves to 4, and fast jumps off the end.", {
        ptrs: { slow: 3, fast: 6 }, tags: { 6: "end" },
      }),
      s("With 6 nodes there are two middle nodes, 3 and 4. Which one should we return?", {
        hl: [2, 3], ptrs: { slow: 3, fast: 6 }, tags: { 6: "end" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Remove Nth Node From End of List": [
    L([1, 2, 3, 4, 5], [
      s("To remove the 2nd node from the end, give fast a head start of 2 steps.", {
        ptrs: { slow: 0, fast: 0 },
      }),
      s("Fast takes step 1.", {
        ptrs: { slow: 0, fast: 1 },
      }),
      s("Fast takes step 2. There is now a gap of 2 nodes between the pointers.", {
        hl: [0, 2], ptrs: { slow: 0, fast: 2 },
      }),
      s("From now on both pointers move together. Why does keeping this gap matter once fast reaches the end?", {
        hl: [0, 2], ptrs: { slow: 0, fast: 2 },
      }),
    ]),
    L([1, 2, 3, 4, 5], [
      s("Both pointers move one step at a time, keeping the same gap.", {
        ptrs: { slow: 1, fast: 3 },
      }),
      s("Again.", {
        ptrs: { slow: 2, fast: 4 },
      }),
      s("Fast is on the last node. Slow is just before the node we want to remove.", {
        bad: [3], tags: { 3: "remove" }, ptrs: { slow: 2, fast: 4 },
      }),
      s("Slow's arrow now jumps over 4, straight to 5. Node 4 is out of the list.", {
        bad: [3], next: { 2: 4 }, hlNext: [2], ptrs: { slow: 2, fast: 4 },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Palindrome Linked List": [
    L([1, 2, 2, 1], [
      s("First find the middle with slow and fast pointers.", {
        ptrs: { slow: 0, fast: 0 },
      }),
      s("Slow takes 1 step. Fast takes 2.", {
        ptrs: { slow: 1, fast: 2 },
      }),
      s("Again. Fast reaches the end, and slow sits where the second half begins.", {
        hl: [2, 3], ok: [0, 1], ptrs: { slow: 2, fast: 4 },
      }),
      s("Cut the list here. The first half is 1, 2 and the second half is 2, 1.", {
        hl: [2, 3], ok: [0, 1], next: { 1: N }, hlNext: [1], tags: { 0: "first", 2: "second" },
      }),
      s("The second half only has forward arrows. How can we compare it with the first half?", {
        hl: [2, 3], ok: [0, 1], next: { 1: N }, tags: { 0: "first", 2: "second" },
      }),
    ]),
    L([1, 2, 2, 1], [
      s("The list is cut into two halves: 1, 2 and 2, 1.", {
        ok: [0, 1], hl: [2, 3], next: { 1: N },
      }),
      s("Reverse the second half. The last 1 now points back at 2.", {
        ok: [0, 1], hl: [2, 3], next: { 1: N, 2: N, 3: 2 }, hlNext: [3],
      }),
      s("Put one pointer at the head of the first half and one at the head of the reversed half.", {
        hl: [0, 3], next: { 1: N, 2: N, 3: 2 }, ptrs: { a: 0, b: 3 },
      }),
      s("1 and 1 match. Both pointers step inward.", {
        ok: [0, 3], hl: [1, 2], next: { 1: N, 2: N, 3: 2 }, ptrs: { a: 1, b: 2 },
      }),
      s("2 and 2 match too. Every pair matched. What can we say about the list?", {
        ok: [0, 1, 2, 3], next: { 1: N, 2: N, 3: 2 }, ptrs: { a: 1, b: 2 },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Intersection of Two Linked Lists": [
    L([4, 1, 8, 4, 5], [
      s("These two lists join and share their last nodes: 8, 4, 5.", {
        ok: [2, 3, 4], ok2: [3, 4, 5], tags: { 2: "shared" }, tags2: { 3: "shared" },
      }),
      s("Put a pointer at the head of each list and move them in step.", {
        ptrs: { pa: 0 }, ptrs2: { pb: 0 },
      }),
      s("A has 5 nodes and B has 6, so the pointers reach the shared part at different times.", {
        hl: [2], hl2: [2], ptrs: { pa: 2 }, ptrs2: { pb: 2 },
      }),
      s("A's pointer is already on 8, while B's pointer is still on 1. How can we line them up?", {
        hl: [2], hl2: [2], ptrs: { pa: 2 }, ptrs2: { pb: 2 },
      }),
    ], { values2: [5, 6, 1, 8, 4, 5], names: ["A", "B"] }),
    L([4, 1, 8, 4, 5], [
      s("Idea: when a pointer reaches the end of its list, send it to the head of the other list.", {
        ptrs: { pa: 5 }, ptrs2: { pb: 5 }, tags: { 5: "end" },
      }),
      s("A's pointer jumps to the head of B. B's pointer reaches the end of B.", {
        ptrs2: { pa: 0, pb: 6 }, tags2: { 6: "end" },
      }),
      s("B's pointer jumps to the head of A. A's pointer keeps walking through B.", {
        ptrs: { pb: 0 }, ptrs2: { pa: 1 },
      }),
      s("Now each pointer has walked both lists, and both stand on the same node, 8. Why at the same time?", {
        ok: [2], ok2: [3], ptrs: { pb: 2 }, ptrs2: { pa: 3 },
        tags: { 2: "same node" }, tags2: { 3: "same node" },
      }),
    ], { values2: [5, 6, 1, 8, 4, 5], names: ["A", "B"] }),
  ],

  // ---------------------------------------------------------------
  "Remove Duplicates from Sorted List": [
    L([1, 1, 2, 3, 3], [
      s("The list is sorted, so equal values sit side by side.", {
        hl: [0, 1],
      }),
      s("Compare each node with the one after it. The first two are both 1.", {
        hl: [0, 1], ptrs: { cur: 0 },
      }),
      s("Equal values mean the second 1 is a duplicate and has to go.", {
        hl: [0], bad: [1], ptrs: { cur: 0 },
      }),
      s("What should the arrow from the first 1 point at now?", {
        hl: [0], bad: [1], ptrs: { cur: 0 },
      }),
    ]),
    L([1, 1, 2, 3, 3], [
      s("The first 1 skips its duplicate and points straight at 2.", {
        bad: [1], hl: [0], next: { 0: 2 }, hlNext: [0], ptrs: { cur: 0 },
      }),
      s("The next node, 2, is different, so cur can move on to it.", {
        bad: [1], ok: [0], hl: [2], next: { 0: 2 }, ptrs: { cur: 2 },
      }),
      s("Then cur moves to 3. The node after it is also 3, so that duplicate is skipped as well.", {
        bad: [1, 4], ok: [0, 2], hl: [3], next: { 0: 2, 3: N }, hlNext: [3], ptrs: { cur: 3 },
      }),
      s("After skipping a duplicate, cur stayed put instead of moving ahead. Why?", {
        bad: [1, 4], ok: [0, 2, 3], next: { 0: 2, 3: N }, ptrs: { cur: 3 },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Reorder List": [
    L([1, 2, 3, 4], [
      s("We want 1, 4, 2, 3 from 1, 2, 3, 4, taking from the front and the back in turn.", {
        hl: [0, 3],
      }),
      s("First find the middle with slow and fast pointers.", {
        ptrs: { slow: 1, fast: 2 },
      }),
      s("Cut the list after the middle. The second half is 3, 4.", {
        ok: [0, 1], hl: [2, 3], next: { 1: N }, hlNext: [1],
      }),
      s("Reverse the second half so it reads 4, 3. How will we weave 1, 2 with 4, 3?", {
        ok: [0, 1], hl: [2, 3], next: { 1: N, 2: N, 3: 2 }, hlNext: [3],
      }),
    ]),
    L([1, 2, 3, 4], [
      s("Two halves: 1, 2 and the reversed 4, 3.", {
        ok: [0, 1], hl: [2, 3], next: { 1: N, 2: N, 3: 2 },
      }),
      s("Take 1 and link it to 4, the head of the other half.", {
        hl: [0, 3], next: { 0: 3, 1: N, 2: N, 3: 2 }, hlNext: [0],
      }),
      s("Link 4 back to 2, the next node of the first half.", {
        hl: [3, 1], next: { 0: 3, 1: N, 2: N, 3: 1 }, hlNext: [3],
      }),
      s("Link 2 to 3, the next node of the second half.", {
        hl: [1, 2], next: { 0: 3, 1: 2, 2: N, 3: 1 }, hlNext: [1],
      }),
      s("The list now reads 1, 4, 2, 3. We changed arrows, not values. Why can this be done in place?", {
        ok: [0, 1, 2, 3], next: { 0: 3, 1: 2, 2: N, 3: 1 },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Add Two Numbers": [
    L([2, 4, 3], [
      s("Digits are stored backwards: 342 is 2, 4, 3. We start at the head, like adding from the ones place.", {
        ptrs: { a: 0 }, ptrs2: { b: 0 }, aux: { label: "sum", items: [] },
      }),
      s("2 + 5 = 7. No carry.", {
        hl: [0], hl2: [0], ptrs: { a: 0 }, ptrs2: { b: 0 }, aux: { label: "sum", items: ["7"] },
      }),
      s("4 + 6 = 10. Write 0 and carry 1 into the next column.", {
        ok: [0], ok2: [0], hl: [1], hl2: [1], tags: { 1: "carry 1" },
        ptrs: { a: 1 }, ptrs2: { b: 1 }, aux: { label: "sum", items: ["7", "0"] },
      }),
      s("3 + 4 plus the carry 1 makes 8. Write 8.", {
        ok: [0, 1], ok2: [0, 1], hl: [2], hl2: [2],
        ptrs: { a: 2 }, ptrs2: { b: 2 }, aux: { label: "sum", items: ["7", "0", "8"] },
      }),
      s("The sum is also stored backwards. Why does starting at the head work so well here?", {
        ok: [0, 1, 2], ok2: [0, 1, 2], aux: { label: "sum", items: ["7", "0", "8"] },
      }),
    ], { values2: [5, 6, 4], names: ["l1", "l2"] }),
    L([9, 9], [
      s("Now 99 and 1. The digits are 9, 9 and 1.", {
        ptrs: { a: 0 }, ptrs2: { b: 0 }, aux: { label: "sum", items: [] },
      }),
      s("9 + 1 = 10. Write 0 and carry 1.", {
        hl: [0], hl2: [0], tags: { 1: "carry 1" }, ptrs: { a: 0 }, ptrs2: { b: 0 },
        aux: { label: "sum", items: ["0"] },
      }),
      s("The second list has run out, so it counts as 0. 9 + 0 + 1 = 10: write 0, carry 1 again.", {
        ok: [0], ok2: [0], hl: [1], tags: { 2: "carry 1" }, ptrs: { a: 1 }, ptrs2: { b: 1 },
        aux: { label: "sum", items: ["0", "0"] },
      }),
      s("Both lists are finished, but a carry of 1 is left over. What do we do with it?", {
        ok: [0, 1], ok2: [0], tags: { 2: "carry 1" }, ptrs: { a: 2 }, ptrs2: { b: 1 },
        aux: { label: "sum", items: ["0", "0"] },
      }),
    ], { values2: [1], names: ["l1", "l2"] }),
  ],

  // ===============================================================
  // BATCH 11: Grids and DP tables, using the "grid" renderer
  // Cells are [row, col] pairs, for example hl: [[1, 2]]. Tag keys are "row,col".
  // values are 2D arrays. A top-level dim: [...] fades cells (water, empty cells).
  // rowLabels / colLabels label the rows and columns of a DP table.
  // ===============================================================

  // ---------------------------------------------------------------
  "Number of Islands": [
    G(ISLANDS, [
      s("Land is 1 and water is 0. An island is land that touches up, down, left or right.", {}),
      s("Scan cell by cell. The first land we meet starts a new island.", {
        hl: [[0, 0]], tags: { "0,0": "#1" },
      }),
      s("Everything connected to it belongs to the same island.", {
        ok: [[0, 0], [0, 1], [1, 0], [1, 1]], tags: { "0,0": "#1" },
      }),
      s("Keep scanning. This land is not connected to the first island, so it is a new one.", {
        ok: [[0, 0], [0, 1], [1, 0], [1, 1]], hl: [[2, 2]], tags: { "0,0": "#1", "2,2": "#2" },
      }),
      s("The land at the bottom right touches the middle one only at a corner. Is it the same island?", {
        ok: [[0, 0], [0, 1], [1, 0], [1, 1], [2, 2]], hl: [[3, 3], [3, 4]],
        tags: { "0,0": "#1", "2,2": "#2" },
      }),
    ], { dim: zeros(ISLANDS) }),
    G(ISLANDS, [
      s("While walking an island, we must remember which cells we have already visited.", {
        hl: [[0, 0]], tags: { "0,0": "start" },
      }),
      s("Mark the start as visited, then step right.", {
        ok: [[0, 0]], hl: [[0, 1]],
      }),
      s("From there we can step down.", {
        ok: [[0, 0], [0, 1]], hl: [[1, 1]],
      }),
      s("Then step left.", {
        ok: [[0, 0], [0, 1], [1, 1]], hl: [[1, 0]],
      }),
      s("From here, the cell above is the start again. What stops us from circling forever?", {
        ok: [[0, 1], [1, 1], [1, 0]], hl: [[0, 0]], tags: { "0,0": "seen" },
      }),
    ], { dim: zeros(ISLANDS) }),
  ],

  // ---------------------------------------------------------------
  "Flood Fill": [
    G(FILL, [
      s("Start at the middle cell, which has color 1. We repaint it and all connected 1s with color 2.", {
        hl: [[1, 1]],
      }),
      s("Repaint the start cell.", {
        values: [[1, 1, 1], [1, 2, 0], [1, 0, 1]], ok: [[1, 1]],
      }),
      s("Look at its neighbors. Cells with color 1 get repainted. Cells with another color do not.", {
        values: [[1, 1, 1], [1, 2, 0], [1, 0, 1]], ok: [[1, 1]], hl: [[0, 1], [1, 0]], bad: [[1, 2], [2, 1]],
      }),
      s("Repaint those two, then keep spreading outward from them.", {
        values: [[1, 2, 1], [2, 2, 0], [1, 0, 1]], ok: [[1, 1], [0, 1], [1, 0]],
      }),
      s("The 1 in the bottom corner touches only 0s. Will it be repainted?", {
        values: [[2, 2, 2], [2, 2, 0], [2, 0, 1]],
        ok: [[0, 0], [0, 1], [0, 2], [1, 0], [1, 1], [2, 0]], hl: [[2, 2]],
      }),
    ]),
    G([[1, 1], [1, 0]], [
      s("What if the new color is 1, the same color that is already there?", {
        hl: [[0, 0]],
      }),
      s("We repaint the start cell with 1. It looks exactly the same as before.", {
        ok: [[0, 0]],
      }),
      s("Its neighbors have color 1 too, so we visit them. Each one sees the start, still color 1.", {
        ok: [[0, 0]], hl: [[0, 1], [1, 0]],
      }),
      s("A repainted cell still looks unpainted, so we keep walking in circles. How can we avoid that?", {
        bad: [[0, 0], [0, 1], [1, 0]],
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Rotting Oranges": [
    G(ORANGES, [
      s("2 is rotten, 1 is fresh and 0 is empty. Each minute, rot spreads to fresh neighbors.", {
        ok: [[0, 0]], aux: { label: "minute", items: ["0"] },
      }),
      s("Minute 1: the rotten orange infects the two fresh oranges next to it.", {
        values: [[2, 2, 1], [2, 1, 0], [0, 1, 1]], ok: [[0, 0]], hl: [[0, 1], [1, 0]],
        aux: { label: "minute", items: ["1"] },
      }),
      s("Minute 2: both new rotten oranges spread. The empty cell below the left one stays empty.", {
        values: [[2, 2, 2], [2, 2, 0], [0, 1, 1]], ok: [[0, 0], [0, 1], [1, 0]], hl: [[0, 2], [1, 1]],
        aux: { label: "minute", items: ["2"] },
      }),
      s("Minute 3: only the orange below the center has a rotten neighbor and is still fresh.", {
        values: [[2, 2, 2], [2, 2, 0], [0, 2, 1]], ok: [[0, 0], [0, 1], [0, 2], [1, 0], [1, 1]],
        hl: [[2, 1]], aux: { label: "minute", items: ["3"] },
      }),
      s("Minute 4: the last orange rots. Rot spread outward in waves. Which search works like that?", {
        values: [[2, 2, 2], [2, 2, 0], [0, 2, 2]],
        ok: [[0, 0], [0, 1], [0, 2], [1, 0], [1, 1], [2, 1]], hl: [[2, 2]],
        aux: { label: "minute", items: ["4"] },
      }),
    ], { dim: zeros(ORANGES) }),
    G([[2, 1, 0], [0, 0, 1]], [
      s("A new grid. The top row is 2, 1, 0 and the bottom row is 0, 0, 1.", {
        ok: [[0, 0]], aux: { label: "minute", items: ["0"] },
      }),
      s("Minute 1: the fresh orange next to the rotten one rots.", {
        values: [[2, 2, 0], [0, 0, 1]], ok: [[0, 0]], hl: [[0, 1]],
        aux: { label: "minute", items: ["1"] },
      }),
      s("Nothing else can rot. The last fresh orange is walled in by empty cells.", {
        values: [[2, 2, 0], [0, 0, 1]], ok: [[0, 0], [0, 1]], bad: [[1, 2]],
        aux: { label: "minute", items: ["1"] },
      }),
      s("No rotten neighbor is left, yet a fresh orange remains. What should we answer?", {
        values: [[2, 2, 0], [0, 0, 1]], ok: [[0, 0], [0, 1]], bad: [[1, 2]],
        aux: { label: "minute", items: ["1"] },
      }),
    ], { dim: zeros([[2, 1, 0], [0, 0, 1]]) }),
  ],

  // ---------------------------------------------------------------
  "Pacific Atlantic Water Flow": [
    G(PAH, [
      s("Numbers are heights. Water flows to equal or lower neighbors. The Pacific touches the top and left edges.", {
        hl: [[0, 0], [0, 1], [0, 2], [1, 0], [2, 0]],
        tags: { "0,0": "P", "0,1": "P", "0,2": "P", "1,0": "P", "2,0": "P" },
      }),
      s("Checking every cell downhill repeats a lot of work. Instead, start at the ocean and walk uphill.", {
        ok: [[0, 0], [0, 1], [0, 2], [1, 0], [2, 0]],
        tags: { "0,0": "P", "0,1": "P", "0,2": "P", "1,0": "P", "2,0": "P" },
      }),
      s("From the 2 on the top edge, the 5 below it is higher, so water there can reach the Pacific.", {
        ok: [[0, 0], [0, 1], [0, 2], [1, 0], [2, 0]], hl: [[1, 2]],
        tags: { "0,2": "P", "1,2": "reached" },
      }),
      s("From the 3 on the left edge, the 6 beside it is higher, so it is reached too.", {
        ok: [[0, 0], [0, 1], [0, 2], [1, 0], [2, 0], [1, 2]], hl: [[2, 1]],
        tags: { "2,0": "P", "2,1": "reached" },
      }),
      s("The middle cell, 2, is lower than all its neighbors. Can the walk ever reach it?", {
        ok: [[0, 0], [0, 1], [0, 2], [1, 0], [2, 0], [1, 2], [2, 1]], hl: [[1, 1]],
      }),
    ]),
    G(PAH, [
      s("The uphill walk from the Pacific edges reaches these cells.", {
        ok: [[0, 0], [0, 1], [0, 2], [1, 0], [2, 0], [1, 2], [2, 1]],
        tags: { "0,0": "P", "0,1": "P", "0,2": "P", "1,0": "P", "2,0": "P", "1,2": "P", "2,1": "P" },
      }),
      s("The walk from the Atlantic edges, the bottom and the right, reaches these cells.", {
        ok: [[2, 0], [2, 1], [2, 2], [0, 2], [1, 2], [0, 1], [1, 0]],
        tags: { "2,0": "A", "2,1": "A", "2,2": "A", "0,2": "A", "1,2": "A", "0,1": "A", "1,0": "A" },
      }),
      s("Now put the two together. Some cells were reached by one walk, some by both, one by neither.", {
        tags: {
          "0,0": "P", "2,2": "A", "1,1": "none",
          "0,1": "P+A", "0,2": "P+A", "1,0": "P+A", "2,0": "P+A", "1,2": "P+A", "2,1": "P+A",
        },
      }),
      s("Which cells can send water to both oceans?", {
        ok: [[0, 1], [0, 2], [1, 0], [2, 0], [1, 2], [2, 1]], bad: [[0, 0], [2, 2], [1, 1]],
        tags: {
          "0,0": "P", "2,2": "A", "1,1": "none",
          "0,1": "P+A", "0,2": "P+A", "1,0": "P+A", "2,0": "P+A", "1,2": "P+A", "2,1": "P+A",
        },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Unique Paths": [
    G(UP_EMPTY, [
      s("Each cell shows how many ways lead to it. The robot may only move right or down.", {
        hl: [[0, 0]],
      }),
      s("The start cell has 1 way: the robot is already standing there.", {
        values: [[1, "-", "-"], ["-", "-", "-"], ["-", "-", "-"]], ok: [[0, 0]],
      }),
      s("Anywhere in the top row can only be reached by moving right, so each has 1 way.", {
        values: [[1, 1, 1], ["-", "-", "-"], ["-", "-", "-"]], ok: [[0, 0], [0, 1], [0, 2]],
      }),
      s("The left column can only be reached by moving down. That is 1 way each as well.", {
        values: [[1, 1, 1], [1, "-", "-"], [1, "-", "-"]],
        ok: [[0, 0], [0, 1], [0, 2], [1, 0], [2, 0]],
      }),
      s("Cells inside can be reached from above or from the left. How do those two combine?", {
        values: [[1, 1, 1], [1, "-", "-"], [1, "-", "-"]],
        ok: [[0, 0], [0, 1], [0, 2], [1, 0], [2, 0]], hl: [[1, 1]],
      }),
    ]),
    G(UP_EMPTY, [
      s("Cell (1, 1) can be reached from the cell above it or from the cell to its left.", {
        values: [[1, 1, 1], [1, "-", "-"], [1, "-", "-"]], hl: [[1, 1]], ok: [[0, 1], [1, 0]],
      }),
      s("The cell above holds 1 way and the cell on the left holds 1 way. Every route to either can step in.", {
        values: [[1, 1, 1], [1, "-", "-"], [1, "-", "-"]], hl: [[1, 1]], ok: [[0, 1], [1, 0]],
        tags: { "0,1": "1", "1,0": "1" },
      }),
      s("So this cell holds 2 ways.", {
        values: [[1, 1, 1], [1, 2, "-"], [1, "-", "-"]], hl: [[1, 1]], ok: [[0, 1], [1, 0]],
      }),
      s("Now cell (1, 2): the cell above holds 1 and the cell on the left holds 2. What goes here?", {
        values: [[1, 1, 1], [1, 2, "-"], [1, "-", "-"]], hl: [[1, 2]], ok: [[0, 2], [1, 1]],
        tags: { "0,2": "1", "1,1": "2" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Longest Common Subsequence": [
    G(LCS_S0, [
      s("Rows are the letters of ace and columns the letters of abcde. A cell holds the longest common length so far.", {}),
      s("a and a match. We take the diagonal cell, 0, and add 1.", {
        values: [[0, 0, 0, 0, 0, 0], [0, 1, "-", "-", "-", "-"], [0, "-", "-", "-", "-", "-"], [0, "-", "-", "-", "-", "-"]],
        hl: [[1, 1]], ok: [[0, 0]], tags: { "0,0": "diag" },
      }),
      s("Later, c and c match too. The diagonal cell holds 1, so this cell becomes 2.", {
        values: [[0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 1], [0, 1, 1, 2, "-", "-"], [0, "-", "-", "-", "-", "-"]],
        hl: [[2, 3]], ok: [[1, 2]], tags: { "1,2": "diag" },
      }),
      s("What should a cell hold when its two letters differ?", {
        values: [[0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 1], [0, 1, 1, 2, "-", "-"], [0, "-", "-", "-", "-", "-"]],
        hl: [[2, 4]],
      }),
    ], { rowLabels: ["", "a", "c", "e"], colLabels: ["", "a", "b", "c", "d", "e"] }),
    G(LCS_S0, [
      s("Now c against d, in row 2, column 4. The letters differ.", {
        values: [[0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 1], [0, 1, 1, 2, "-", "-"], [0, "-", "-", "-", "-", "-"]],
        hl: [[2, 4]],
      }),
      s("Look at the cell above. It holds 1.", {
        values: [[0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 1], [0, 1, 1, 2, "-", "-"], [0, "-", "-", "-", "-", "-"]],
        hl: [[2, 4], [1, 4]],
      }),
      s("Now the cell to the left. It holds 2.", {
        values: [[0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 1], [0, 1, 1, 2, "-", "-"], [0, "-", "-", "-", "-", "-"]],
        hl: [[2, 4], [2, 3]],
      }),
      s("Which value should this cell hold?", {
        values: [[0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 1], [0, 1, 1, 2, "-", "-"], [0, "-", "-", "-", "-", "-"]],
        hl: [[2, 4]], ok: [[1, 4], [2, 3]],
      }),
      s("It takes the larger one, 2. Why is copying the bigger neighbor always safe when the letters differ?", {
        values: [[0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 1], [0, 1, 1, 2, 2, "-"], [0, "-", "-", "-", "-", "-"]],
        hl: [[2, 4]], ok: [[2, 3]],
      }),
    ], { rowLabels: ["", "a", "c", "e"], colLabels: ["", "a", "b", "c", "d", "e"] }),
  ],

  // ---------------------------------------------------------------
  "Edit Distance": [
    G(ED_EMPTY, [
      s("Rows are the letters of cat, columns the letters of cut. A cell holds the fewest edits so far.", {}),
      s("Top row: turning an empty word into c, cu, cut takes 1, 2, 3 insertions.", {
        values: [[0, 1, 2, 3], ["-", "-", "-", "-"], ["-", "-", "-", "-"], ["-", "-", "-", "-"]],
        ok: [[0, 0], [0, 1], [0, 2], [0, 3]],
      }),
      s("Left column: turning c, ca, cat into an empty word takes 1, 2, 3 deletions.", {
        values: [[0, 1, 2, 3], [1, "-", "-", "-"], [2, "-", "-", "-"], [3, "-", "-", "-"]],
        ok: [[0, 0], [0, 1], [0, 2], [0, 3], [1, 0], [2, 0], [3, 0]],
      }),
      s("Every other cell builds on these edges. What happens when two letters match, like c and c?", {
        values: [[0, 1, 2, 3], [1, "-", "-", "-"], [2, "-", "-", "-"], [3, "-", "-", "-"]],
        ok: [[0, 0], [0, 1], [0, 2], [0, 3], [1, 0], [2, 0], [3, 0]], hl: [[1, 1]],
      }),
    ], { rowLabels: ["", "c", "a", "t"], colLabels: ["", "c", "u", "t"] }),
    G(ED_EMPTY, [
      s("The cell for a against u. The letters differ, so we must make one edit.", {
        values: [[0, 1, 2, 3], [1, 0, 1, 2], [2, 1, "-", "-"], [3, "-", "-", "-"]], hl: [[2, 2]],
      }),
      s("Replace a with u: take the diagonal cell, 0, and add 1.", {
        values: [[0, 1, 2, 3], [1, 0, 1, 2], [2, 1, "-", "-"], [3, "-", "-", "-"]],
        hl: [[2, 2], [1, 1]], tags: { "1,1": "0+1" },
      }),
      s("Delete a: take the cell above, 1, and add 1.", {
        values: [[0, 1, 2, 3], [1, 0, 1, 2], [2, 1, "-", "-"], [3, "-", "-", "-"]],
        hl: [[2, 2], [1, 2]], tags: { "1,2": "1+1" },
      }),
      s("Insert u: take the cell on the left, 1, and add 1.", {
        values: [[0, 1, 2, 3], [1, 0, 1, 2], [2, 1, "-", "-"], [3, "-", "-", "-"]],
        hl: [[2, 2], [2, 1]], tags: { "2,1": "1+1" },
      }),
      s("We keep the smallest of the three. Which one is it?", {
        values: [[0, 1, 2, 3], [1, 0, 1, 2], [2, 1, "-", "-"], [3, "-", "-", "-"]],
        hl: [[2, 2]], ok: [[1, 1], [1, 2], [2, 1]],
        tags: { "1,1": "0+1", "1,2": "1+1", "2,1": "1+1" },
      }),
    ], { rowLabels: ["", "c", "a", "t"], colLabels: ["", "c", "u", "t"] }),
  ],

  // ===============================================================
  // BATCH 12: Graphs, using the "graph" renderer
  // GR(nodes, edges, steps, { pos, directed, height }). Edges are node index pairs,
  // with an optional weight as the third value. hlE / okE / badE color edges by node pair.
  // ===============================================================

  // ---------------------------------------------------------------
  "Number of Provinces": [
    GR(PROV_NODES, PROV_EDGES, [
      s("Each circle is a city and each line a direct link. A province is a group of connected cities.", {}),
      s("Start at city 0, which is not visited yet. That begins a province.", {
        hl: [0], tags: { 0: "#1" },
      }),
      s("Follow its link to city 1, then on to city 2. All three belong to the same province.", {
        ok: [0, 1, 2], okE: [[0, 1], [1, 2]], tags: { 0: "#1" },
      }),
      s("City 3 is not visited, so a new province begins. Its link leads on to city 4.", {
        ok: [0, 1, 2], okE: [[0, 1], [1, 2]], hl: [3, 4], hlE: [[3, 4]], tags: { 0: "#1", 3: "#2" },
      }),
      s("City 5 has no links at all. Does it still count as a province?", {
        ok: [0, 1, 2, 3, 4], okE: [[0, 1], [1, 2], [3, 4]], hl: [5], tags: { 0: "#1", 3: "#2" },
      }),
    ], { pos: PROV_POS, height: 190 }),
    GR(PROV_NODES, PROV_EDGES, [
      s("Start at city 1. It links to city 0 and city 2.", {
        hl: [1], hlE: [[0, 1], [1, 2]],
      }),
      s("Visit city 0 first. Its only link goes straight back to city 1.", {
        ok: [1], hl: [0], hlE: [[0, 1]],
      }),
      s("City 1 is already visited, so we do not walk there again.", {
        ok: [1], hl: [0], badE: [[0, 1]],
      }),
      s("Then city 2 is visited from city 1. What would happen on this back-and-forth if we never marked cities?", {
        ok: [0, 1], hl: [2], okE: [[0, 1]], hlE: [[1, 2]],
      }),
    ], { pos: PROV_POS, height: 190 }),
  ],

  // ---------------------------------------------------------------
  "Find if Path Exists in Graph": [
    GR(PATH_A_NODES, PATH_A_EDGES, [
      s("Is there a path from 0 to 4? Start at the source and look at its links.", {
        hl: [0], tags: { 0: "from", 4: "to" },
      }),
      s("Node 0 links to 1 and 2. Both get explored.", {
        ok: [0], hl: [1, 2], hlE: [[0, 1], [0, 2]], tags: { 0: "from", 4: "to" },
      }),
      s("Node 2 has no other links, so that branch ends. Node 1 leads on to node 3.", {
        ok: [0, 1, 2], okE: [[0, 1], [0, 2]], hl: [3], hlE: [[1, 3]], tags: { 0: "from", 4: "to" },
      }),
      s("Node 3 links to node 4, our destination. What does reaching it tell us?", {
        ok: [0, 1, 2, 3], okE: [[0, 1], [0, 2], [1, 3]], hl: [4], hlE: [[3, 4]], tags: { 0: "from", 4: "to" },
      }),
    ], { pos: PATH_A_POS, height: 190 }),
    GR(PATH_B_NODES, PATH_B_EDGES, [
      s("Now a graph in two separate pieces. Can we get from 0 to 5?", {
        hl: [0, 5], tags: { 0: "from", 5: "to" },
      }),
      s("Explore from 0. Its links lead to nodes 1 and 2.", {
        ok: [0], hl: [1, 2], hlE: [[0, 1], [0, 2]], tags: { 0: "from", 5: "to" },
      }),
      s("Neither 1 nor 2 has any other link, so the exploration runs dry.", {
        ok: [0, 1, 2], okE: [[0, 1], [0, 2]], tags: { 0: "from", 5: "to" },
      }),
      s("We never reached 5, which sits in a different piece. What should we answer?", {
        ok: [0, 1, 2], okE: [[0, 1], [0, 2]], bad: [3, 4, 5], tags: { 0: "from", 5: "to" },
      }),
    ], { pos: PATH_B_POS, height: 200 }),
  ],

  // ---------------------------------------------------------------
  "Clone Graph": [
    GR(CLONE_NODES, CLONE_EDGES, [
      s("We must build a brand new copy of every node, with the same links. Start at node 1.", {
        hl: [0], aux: { label: "copies", items: [] },
      }),
      s("Make a copy of node 1 and note it in a map.", {
        hl: [0], aux: { label: "copies", items: ["1→1'"] },
      }),
      s("Move to a neighbor, node 2, and copy it too.", {
        ok: [0], hl: [1], hlE: [[0, 1]], aux: { label: "copies", items: ["1→1'", "2→2'"] },
      }),
      s("Walk on to nodes 3 and 4, copying each one as we reach it.", {
        ok: [0, 1], okE: [[0, 1]], hl: [2, 3], hlE: [[1, 2], [2, 3]],
        aux: { label: "copies", items: ["1→1'", "2→2'", "3→3'", "4→4'"] },
      }),
      s("Every node has exactly one copy. What would go wrong if one node got two copies?", {
        ok: [0, 1, 2, 3], okE: [[0, 1], [1, 2], [2, 3]],
        aux: { label: "copies", items: ["1→1'", "2→2'", "3→3'", "4→4'"] },
      }),
    ], { pos: CLONE_POS, height: 220 }),
    GR(CLONE_NODES, CLONE_EDGES, [
      s("Now we are at node 4, which links back to node 1. Node 1 already has a copy.", {
        ok: [0, 1, 2], okE: [[0, 1], [1, 2], [2, 3]], hl: [3, 0], hlE: [[3, 0]],
        aux: { label: "copies", items: ["1→1'", "2→2'", "3→3'", "4→4'"] },
      }),
      s("We must not make another copy of node 1.", {
        ok: [1, 2], okE: [[0, 1], [1, 2], [2, 3]], hl: [3], bad: [0], badE: [[3, 0]],
        aux: { label: "copies", items: ["1→1'", "2→2'", "3→3'", "4→4'"] },
      }),
      s("We look node 1 up in the map instead, and link the copy of 4 to the copy of 1.", {
        ok: [1, 2, 3], okE: [[0, 1], [1, 2], [2, 3]], hl: [0], hlE: [[3, 0]],
        aux: { label: "copies", items: ["1→1'", "2→2'", "3→3'", "4→4'"] },
      }),
      s("The map answers 'have we copied this node?' in one step. What does that stop when the graph has a loop?", {
        ok: [0, 1, 2, 3], okE: [[0, 1], [1, 2], [2, 3], [3, 0]],
        aux: { label: "copies", items: ["1→1'", "2→2'", "3→3'", "4→4'"] },
      }),
    ], { pos: CLONE_POS, height: 220 }),
  ],

  // ---------------------------------------------------------------
  "Course Schedule": [
    GR(COURSE_NODES, COURSE_EDGES, [
      s("An arrow from 0 to 1 means: take course 0 before course 1.", {
        hl: [0, 1], hlE: [[0, 1]],
      }),
      s("Course 0 has no arrows pointing into it, so it can be taken right away.", {
        hl: [0], tags: { 0: "waits: 0", 1: "waits: 1", 2: "waits: 1", 3: "waits: 2" },
      }),
      s("Take 0. Its arrows are removed, and courses 1 and 2 no longer wait for anything.", {
        ok: [0], hl: [1, 2], okE: [[0, 1], [0, 2]], tags: { 1: "waits: 0", 2: "waits: 0", 3: "waits: 2" },
      }),
      s("Take 1 and 2. Now course 3 has nothing left to wait for.", {
        ok: [0, 1, 2], hl: [3], okE: [[0, 1], [0, 2], [1, 3], [2, 3]], tags: { 3: "waits: 0" },
      }),
      s("All four courses could be taken. Why did we always pick a course that was waiting for nothing?", {
        ok: [0, 1, 2, 3], okE: [[0, 1], [0, 2], [1, 3], [2, 3]],
      }),
    ], { pos: COURSE_POS, directed: true, height: 220 }),
    GR(CYCLE_NODES, CYCLE_EDGES, [
      s("Now course 1 needs 0, course 2 needs 1, and course 0 needs 2.", {
        hl: [0, 1, 2],
      }),
      s("Look for a course with no arrows pointing into it. Each one is waiting for one other course.", {
        tags: { 0: "waits: 1", 1: "waits: 1", 2: "waits: 1" },
      }),
      s("Every course is waiting for another one, so none can be taken first.", {
        bad: [0, 1, 2], badE: [[0, 1], [1, 2], [2, 0]], tags: { 0: "waits: 1", 1: "waits: 1", 2: "waits: 1" },
      }),
      s("Following the arrows brings us back to where we began. What should we answer for this schedule?", {
        bad: [0, 1, 2], badE: [[0, 1], [1, 2], [2, 0]],
      }),
    ], { pos: CYCLE_POS, directed: true, height: 220 }),
  ],

  // ---------------------------------------------------------------
  "Network Delay Time": [
    GR(NET_A_NODES, NET_A_EDGES, [
      s("A signal starts at node 2. Each arrow shows how long it takes to cross.", {
        hl: [1], tags: { 1: "t=0" },
      }),
      s("After 1 time unit, it reaches nodes 1 and 3.", {
        ok: [1], hl: [0, 2], hlE: [[1, 0], [1, 2]], tags: { 1: "t=0", 0: "t=1", 2: "t=1" },
      }),
      s("From node 3, the signal needs 1 more unit to reach node 4.", {
        ok: [1, 0, 2], okE: [[1, 0], [1, 2]], hl: [3], hlE: [[2, 3]],
        tags: { 1: "t=0", 0: "t=1", 2: "t=1", 3: "t=2" },
      }),
      s("Every node has heard the signal. The network is done when the last node hears it. When is that?", {
        ok: [0, 1, 2, 3], okE: [[1, 0], [1, 2], [2, 3]],
        tags: { 1: "t=0", 0: "t=1", 2: "t=1", 3: "t=2" },
      }),
    ], { pos: NET_A_POS, directed: true, height: 210 }),
    GR(NET_B_NODES, NET_B_EDGES, [
      s("Start at node 1. Node 2 can be reached directly in 4, or through node 3.", {
        hl: [0], tags: { 0: "t=0" },
      }),
      s("Directly to node 2 costs 4. We note that time for now.", {
        ok: [0], hl: [1], hlE: [[0, 1]], tags: { 0: "t=0", 1: "t=4" },
      }),
      s("Through node 3 it costs 1 + 1 = 2, which beats the 4 we noted.", {
        ok: [0], hl: [2, 1], hlE: [[0, 2], [2, 1]], tags: { 0: "t=0", 2: "t=1", 1: "t=2" },
      }),
      s("We keep the smaller time. The slow direct arrow is no longer needed.", {
        ok: [0, 2, 1], okE: [[0, 2], [2, 1]], badE: [[0, 1]], tags: { 0: "t=0", 2: "t=1", 1: "t=2" },
      }),
      s("Node 4 hears the signal one unit after node 2. Why must we keep the smallest time for every node?", {
        ok: [0, 2, 1], okE: [[0, 2], [2, 1]], hl: [3], hlE: [[1, 3]],
        tags: { 0: "t=0", 2: "t=1", 1: "t=2", 3: "t=?" },
      }),
    ], { pos: NET_B_POS, directed: true, height: 210 }),
  ],

  // ---------------------------------------------------------------
  "Word Ladder": [
    GR(WORD_NODES, WORD_EDGES, [
      s("Each word is a node. Two words are linked when they differ by exactly one letter.", {
        tags: { 0: "begin", 6: "end" },
      }),
      s("hit and hot differ only in the middle letter, so they are linked.", {
        hl: [0, 1], hlE: [[0, 1]], tags: { 0: "begin", 6: "end" },
      }),
      s("hot and dot also differ in one letter.", {
        hl: [1, 2], hlE: [[1, 2]], tags: { 0: "begin", 6: "end" },
      }),
      s("hit and cog differ in three letters, so there is no direct link. How can we get from hit to cog?", {
        bad: [0, 6], tags: { 0: "begin", 6: "end" },
      }),
    ], { pos: WORD_POS, height: 250 }),
    GR(WORD_NODES, WORD_EDGES, [
      s("Search outward from hit, one layer at a time. Layer 0 is hit itself.", {
        ok: [0], tags: { 0: "layer 0" },
      }),
      s("Layer 1: every word one change away from hit. That is only hot.", {
        ok: [0], hl: [1], hlE: [[0, 1]], tags: { 0: "layer 0", 1: "layer 1" },
      }),
      s("Layer 2: dot and lot, both one change away from hot.", {
        ok: [0, 1], hl: [2, 3], hlE: [[1, 2], [1, 3]],
        tags: { 0: "layer 0", 1: "layer 1", 2: "layer 2", 3: "layer 2" },
      }),
      s("Layer 3: dog and log.", {
        ok: [0, 1, 2, 3], hl: [4, 5], hlE: [[2, 4], [3, 5]],
        tags: { 2: "layer 2", 3: "layer 2", 4: "layer 3", 5: "layer 3" },
      }),
      s("Layer 4 contains cog, the first time we meet it. Why does that make this the shortest ladder?", {
        ok: [0, 1, 2, 3, 4, 5], hl: [6], hlE: [[4, 6], [5, 6]],
        tags: { 4: "layer 3", 5: "layer 3", 6: "layer 4" },
      }),
    ], { pos: WORD_POS, height: 250 }),
  ],

  // ===============================================================
  // BATCH 13: Intervals, using the "intervals" renderer
  // I(intervals, steps, { range }). A step's own intervals: [...] replaces the list for that step.
  // marker: 3 draws a dashed line at time 3, and markerLabel: "end 3" names it.
  // ===============================================================

  // ---------------------------------------------------------------
  "Merge Intervals": [
    I([[1, 3], [2, 6], [8, 10], [9, 12]], [
      s("Each bar is a span of time. Two spans that overlap should become one.", {}),
      s("The first two spans overlap: the second starts at 2, before the first ends at 3.", {
        hl: [0, 1], marker: 3, markerLabel: "end 3",
      }),
      s("Merge them into one span. It starts at 1 and stretches to 6.", {
        intervals: [[1, 6], [8, 10], [9, 12]], ok: [0],
      }),
      s("Compare the merged span, which ends at 6, with the next one, which starts at 8. There is a gap.", {
        intervals: [[1, 6], [8, 10], [9, 12]], ok: [0], hl: [1], marker: 6, markerLabel: "end 6",
      }),
      s("So the next span stays separate. Why is it enough to compare only with the last merged span?", {
        intervals: [[1, 6], [8, 10], [9, 12]], ok: [0], hl: [1],
      }),
    ], { range: [0, 13] }),
    I([[1, 10], [2, 5]], [
      s("Now one span sits completely inside another.", {
        hl: [0, 1],
      }),
      s("They overlap, so they merge. The new span starts at 1, the start of the first.", {
        hl: [0, 1], marker: 1, markerLabel: "start 1",
      }),
      s("For the end, the first span ends at 10 and the second ends at 5.", {
        hl: [0, 1], tags: { 0: "ends 10", 1: "ends 5" },
      }),
      s("If we copied the second end, the merged span would be this short one. Which end should we keep?", {
        intervals: [[1, 5]], bad: [0], tags: { 0: "too short?" },
      }),
    ], { range: [0, 11] }),
  ],

  // ---------------------------------------------------------------
  "Meeting Rooms": [
    I([[7, 10], [2, 4]], [
      s("Two meetings, shown as spans of time. Can one person attend both?", {}),
      s("Sort the meetings by start time, so the earliest one comes first.", {
        intervals: [[2, 4], [7, 10]], hl: [0, 1],
      }),
      s("The first meeting ends at 4. The next one starts at 7.", {
        intervals: [[2, 4], [7, 10]], ok: [0], hl: [1], marker: 4, markerLabel: "end 4",
      }),
      s("There is a gap, so no clash. Why is it enough to compare each meeting only with the one before it?", {
        intervals: [[2, 4], [7, 10]], ok: [0, 1],
      }),
    ], { range: [0, 11] }),
    I([[1, 5], [3, 6], [8, 9]], [
      s("Now three meetings, already sorted by start time.", {}),
      s("The first meeting ends at 5.", {
        hl: [0], marker: 5, markerLabel: "end 5",
      }),
      s("The second one starts at 3, before time 5 has passed. The two meetings overlap.", {
        bad: [0, 1], marker: 5, markerLabel: "end 5",
      }),
      s("We do not need to look at the third meeting. Why does one overlap settle the question?", {
        bad: [0, 1], hl: [2],
      }),
    ], { range: [0, 10] }),
  ],

  // ===============================================================
  // BATCH 14: Recursion and Backtracking (written from the real challenges)
  // ===============================================================

  // ---------------------------------------------------------------
  "Fibonacci Number": [
    A([0, 1, 1, 2, 3, 5, 8], [
      s("Here are the first Fibonacci numbers, F(0) to F(6).", {
        tags: FIB_TAGS,
      }),
      s("Take F(5), which is 5. What earlier numbers could it be built from?", {
        hl: [5], tags: FIB_TAGS,
      }),
      s("The number right before it is 3, but 3 alone does not make 5.", {
        hl: [5], bad: [4], tags: FIB_TAGS,
      }),
      s("Something else must be added to 3 to make 5. Which earlier number is it?", {
        hl: [5], ok: [4], tags: FIB_TAGS,
      }),
    ]),
    T(["F4", "F3", "F2", "F2", "F1", "F1", "F0", "F1", "F0"], [
      s("This is the call tree for F(4). Each circle is one call.", {
        hl: [0],
      }),
      s("F(2) is worked out in two different places.", {
        hl: [2, 3],
      }),
      s("F(1) is worked out three times.", {
        hl: [4, 5, 7],
      }),
      s("Only the first time each value is computed is needed. The later calls repeat work.", {
        ok: [3, 7, 8], bad: [2, 4, 5, 6],
      }),
      s("What could we keep so that a repeated call costs almost nothing?", {
        ok: [3, 7, 8], bad: [2, 4, 5, 6],
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Climbing Stairs": [
    A([0, 1, 2, 3, 4, 5], [
      s("You can climb 1 or 2 steps at a time. The goal is the top, step 5.", {
        hl: [5],
      }),
      s("Think about the last move that landed you on the top. First, see how moves work on a smaller step, step 3.", {
        hl: [3],
      }),
      s("A 1-step move onto step 3 starts from step 2.", {
        ok: [2], hl: [3], tags: { 2: "+1 step" },
      }),
      s("A 2-step move onto step 3 starts from step 1.", {
        ok: [1], hl: [3], tags: { 1: "+2 steps" },
      }),
      s("Now go back to step 5. Which steps could the last move have started from?", {
        hl: [5],
      }),
    ]),
    A([1, 2, 3, "-", "-"], [
      s("The ways to reach steps 1, 2 and 3 are already known: 1, 2 and 3.", {
        tags: { 0: "step 1", 1: "step 2", 2: "step 3", 3: "step 4", 4: "step 5" },
      }),
      s("To reach step 4, the last move starts from step 3 or from step 2.", {
        hl: [3], ok: [1, 2], tags: { 0: "step 1", 1: "step 2", 2: "step 3", 3: "step 4", 4: "step 5" },
      }),
      s("Every route to step 3 can end with a 1-step. Every route to step 2 can end with a 2-step.", {
        hl: [3], ok: [1, 2], tags: { 0: "step 1", 1: "step 2", 2: "step 3", 3: "step 4", 4: "step 5" },
      }),
      s("How should the ways for step 3 and step 2 be combined to count the ways to step 4?", {
        hl: [3], ok: [1, 2], tags: { 1: "2 ways", 2: "3 ways", 3: "? ways" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Pow(x, n)": [
    A(["x", "x", "x", "x", "x", "x", "x", "x", "x", "x"], [
      s("x^10 means x multiplied by itself 10 times. Here are the 10 factors.", {}),
      s("Group the first 5 factors together. That group is x^5.", {
        hl: [0, 1, 2, 3, 4],
      }),
      s("The other 5 factors form a second group, which is also x^5.", {
        ok: [0, 1, 2, 3, 4], hl: [5, 6, 7, 8, 9],
      }),
      s("How can these two groups of 5 factors be combined to get all 10 factors?", {
        ok: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      }),
    ]),
    A(["8", "4", "2", "1", "?", "?", "?"], [
      s("Here are powers of 2. Each time n drops by 1, the value is cut in half.", {
        tags: { 0: "n=3", 1: "n=2", 2: "n=1", 3: "n=0", 4: "n=-1", 5: "n=-2", 6: "n=-3" },
      }),
      s("8 became 4, then 2, then 1.", {
        ok: [0, 1, 2, 3],
        tags: { 0: "n=3", 1: "n=2", 2: "n=1", 3: "n=0", 4: "n=-1", 5: "n=-2", 6: "n=-3" },
      }),
      s("Keep going: n = -1 gives half of 1.", {
        values: ["8", "4", "2", "1", "1/2", "?", "?"], ok: [0, 1, 2, 3], hl: [4],
        tags: { 0: "n=3", 1: "n=2", 2: "n=1", 3: "n=0", 4: "n=-1", 5: "n=-2", 6: "n=-3" },
      }),
      s("And n = -3 gives 1/8. How does 2 to the power -3 relate to 2 to the power 3, which is 8?", {
        values: ["8", "4", "2", "1", "1/2", "1/4", "1/8"], hl: [0, 6],
        tags: { 0: "n=3", 1: "n=2", 2: "n=1", 3: "n=0", 4: "n=-1", 5: "n=-2", 6: "n=-3" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Subsets": [
    A([1, 2, 3], [
      s("We build one subset by looking at the numbers 1, 2, 3 one at a time.", {
        aux: { label: "subset", items: [] },
      }),
      s("Look at the number 1. What can we do with it?", {
        hl: [0], aux: { label: "subset", items: [] },
      }),
      s("One possible subset so far contains it.", {
        hl: [0], ok: [0], aux: { label: "subset", items: ["1"] },
      }),
      s("Another possible subset so far leaves it out.", {
        hl: [0], bad: [0], aux: { label: "subset", items: [] },
      }),
      s("The number 2 comes next. How many choices does each number give us?", {
        hl: [1], aux: { label: "subset", items: [] },
      }),
    ]),
    A([1, 2, 3], [
      s("Start with no numbers looked at. There is just one subset: the empty one.", {
        aux: { label: "subsets", items: ["{}"] }, out: "1 subset",
      }),
      s("Look at 1. Each subset so far can stay as it is, or get a 1 added.", {
        hl: [0], aux: { label: "subsets", items: ["{}", "{1}"] }, out: "2 subsets",
      }),
      s("Look at 2. The same thing happens to every subset so far.", {
        ok: [0], hl: [1], aux: { label: "subsets", items: ["{}", "{1}", "{2}", "{1,2}"] }, out: "4 subsets",
      }),
      s("Look at 3. The list changes again. What pattern does the count follow for n numbers?", {
        ok: [0, 1], hl: [2],
        aux: { label: "subsets", items: ["{}", "{1}", "{2}", "{1,2}", "{3}", "{1,3}", "{2,3}", "{1,2,3}"] },
        out: "8 subsets",
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Permutations": [
    A([1, 2, 3], [
      s("We build a permutation of 1, 2, 3 by filling positions one at a time.", {
        aux: { label: "built", items: [] },
      }),
      s("Position 1 is filled with 2.", {
        ok: [1], aux: { label: "built", items: ["2"] },
      }),
      s("Position 2 is next. Which of 1, 2, 3 may go there, if every number must be used exactly once?", {
        ok: [1], aux: { label: "built", items: ["2"] },
      }),
    ]),
    A(["_", "_", "_"], [
      s("Three positions to fill with 1, 2 and 3, using each number once.", {
        tags: { 0: "pos 1", 1: "pos 2", 2: "pos 3" },
      }),
      s("Position 1 can take any of the 3 numbers.", {
        hl: [0], tags: { 0: "3 choices", 1: "pos 2", 2: "pos 3" },
      }),
      s("Say 2 goes first. Position 2 can only take what is left: 1 or 3.", {
        values: ["2", "_", "_"], ok: [0], hl: [1], tags: { 0: "used", 1: "2 choices", 2: "pos 3" },
      }),
      s("Say 1 goes second. Position 3 can only take the one number left.", {
        values: ["2", "1", "_"], ok: [0, 1], hl: [2], tags: { 0: "used", 1: "used", 2: "1 choice" },
      }),
      s("The number of choices went down at each position. How many different full orderings can this give?", {
        values: ["2", "1", "3"], ok: [0, 1, 2], tags: { 0: "3 choices", 1: "2 choices", 2: "1 choice" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Combination Sum": [
    A([2, 3, 6, 7], [
      s("Candidates are 2, 3, 6 and 7. The target is 7. We pick numbers one at a time.", {
        aux: { label: "chosen", items: [] },
      }),
      s("Pick 2. We still need 5 more.", {
        hl: [0], tags: { 0: "need 5" }, aux: { label: "chosen", items: ["2"] },
      }),
      s("The problem says a number may be used any number of times.", {
        hl: [0], tags: { 0: "need 5" }, aux: { label: "chosen", items: ["2"] },
      }),
      s("For the next pick, which candidates should we look at?", {
        tags: { 0: "need 5" }, aux: { label: "chosen", items: ["2"] },
      }),
    ]),
    T([7, 5, 4, 3, 2, 2, 1, 1, 0, 0, -1, 0, -1, -1, -2], [
      s("Candidates 2 and 3, target 7. Each circle shows how much is still needed.", {
        hl: [0],
      }),
      s("Going down a level, we choose a 2 or a 3 and the remaining target shrinks.", {
        hl: [1, 2],
      }),
      s("Some branches reach exactly 0.", {
        ok: [8, 9, 11],
      }),
      s("Others fall below 0.", {
        ok: [8, 9, 11], bad: [10, 12, 13, 14],
      }),
      s("What do these two kinds of node tell us about when to stop searching a branch?", {
        ok: [8, 9, 11], bad: [10, 12, 13, 14],
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Generate Parentheses": [
    A(["_", "_", "_", "_", "_", "_"], [
      s("We build a string of 6 characters using 3 opening and 3 closing parentheses.", {
        aux: { label: "used", items: ["open 0", "close 0"] },
      }),
      s("Place an opening parenthesis in slot 1.", {
        values: ["(", "_", "_", "_", "_", "_"], hl: [0], aux: { label: "used", items: ["open 1", "close 0"] },
      }),
      s("Another opening one fits in slot 2.", {
        values: ["(", "(", "_", "_", "_", "_"], hl: [1], ok: [0], aux: { label: "used", items: ["open 2", "close 0"] },
      }),
      s("And a third in slot 3.", {
        values: ["(", "(", "(", "_", "_", "_"], hl: [2], ok: [0, 1], aux: { label: "used", items: ["open 3", "close 0"] },
      }),
      s("All 3 opening parentheses are used. Can slot 4 take a fourth opening one?", {
        values: ["(", "(", "(", "_", "_", "_"], hl: [3], ok: [0, 1, 2], aux: { label: "used", items: ["open 3", "close 0"] },
      }),
    ]),
    A(["_", "_", "_", "_", "_", "_"], [
      s("The string so far is ((, with 2 opening and no closing parentheses.", {
        values: ["(", "(", "_", "_", "_", "_"], ok: [0, 1], aux: { label: "used", items: ["open 2", "close 0"] },
      }),
      s("Add a closing parenthesis. It closes one of the open ones, so this works.", {
        values: ["(", "(", ")", "_", "_", "_"], ok: [1, 2], aux: { label: "used", items: ["open 2", "close 1"] },
      }),
      s("Now try a closing parenthesis as the very first character.", {
        values: [")", "_", "_", "_", "_", "_"], bad: [0], aux: { label: "used", items: ["open 0", "close 1"] },
      }),
      s("That ) has nothing to close. So when is a closing parenthesis allowed?", {
        values: [")", "_", "_", "_", "_", "_"], bad: [0], aux: { label: "used", items: ["open 0", "close 1"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Letter Combinations of a Phone Number": [
    A(["2", "3"], [
      s("The digits are 2 and 3. Each digit sits on a phone key with letters on it.", {}),
      s("The key 2 shows these letters.", {
        hl: [0], aux: { label: "key 2", items: ["a", "b", "c"] },
      }),
      s("The key 3 shows these letters.", {
        hl: [1], ok: [0], aux: { label: "key 3", items: ["d", "e", "f"] },
      }),
      s("For each digit we pick one letter from its key. How many options does a digit give us?", {
        hl: [0, 1], aux: { label: "key 3", items: ["d", "e", "f"] },
      }),
    ]),
    A(["2", "3"], [
      s("The digit 2 offers a, b, c and the digit 3 offers d, e, f. We pick one letter per digit.", {
        aux: { label: "letters", items: ["2: abc", "3: def"] },
      }),
      s("Pick a for the digit 2. Pair it with each letter of the digit 3.", {
        hl: [0], aux: { label: "combos", items: ["ad", "ae", "af"] },
      }),
      s("Pick b the same way.", {
        hl: [0], aux: { label: "combos", items: ["ad", "ae", "af", "bd", "be", "bf"] },
      }),
      s("Do the same for c. How many combinations will there be in total?", {
        hl: [0, 1], aux: { label: "combos", items: ["ad", "ae", "af", "bd", "be", "bf"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "N-Queens": [
    G(NQ_EMPTY, [
      s("We must place 4 queens on a 4 × 4 board. A queen attacks along its row, column and diagonals.", {}),
      s("Place a queen. Everything else in its row is attacked.", {
        values: NQ_ONE, ok: [[0, 1]], bad: [[0, 0], [0, 2], [0, 3]],
      }),
      s("A second queen in the same row would be attacked at once.", {
        values: [["", "Q", "", "Q"], ["", "", "", ""], ["", "", "", ""], ["", "", "", ""]],
        bad: [[0, 1], [0, 3]],
      }),
      s("We have 4 queens and 4 rows. How many queens can each row hold?", {
        values: NQ_ONE, ok: [[0, 1]],
      }),
    ]),
    G(NQ_EMPTY, [
      s("Say we place queens row by row. This queen sits in the first row.", {
        values: NQ_ONE, hl: [[0, 1]],
      }),
      s("It attacks the squares straight down its column.", {
        values: NQ_ONE, ok: [[0, 1]], bad: [[1, 1], [2, 1], [3, 1]],
      }),
      s("It also attacks along both diagonals.", {
        values: NQ_ONE, ok: [[0, 1]], bad: [[1, 1], [2, 1], [3, 1], [1, 0], [1, 2], [2, 3]],
      }),
      s("In the next row three squares are blocked and one is free. What must we remember about earlier queens?", {
        values: NQ_ONE, ok: [[0, 1]], bad: [[1, 0], [1, 1], [1, 2]], hl: [[1, 3]],
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Word Search": [
    G(WS_BOARD, [
      s("We search for ABCCED. The A in the top left matches the first letter.", {
        hl: [[0, 0]],
      }),
      s("The next letter is B. Look at the cells around the A.", {
        ok: [[0, 0]],
      }),
      s("A B sits right beside it.", {
        ok: [[0, 0]], hl: [[0, 1]],
      }),
      s("The next letter is C. There is one right beside the B.", {
        ok: [[0, 0], [0, 1]], hl: [[0, 2]],
      }),
      s("The second C is in the row below, directly under the first C.", {
        ok: [[0, 0], [0, 1], [0, 2]], hl: [[1, 2]],
      }),
      s("We moved right, right, then down. Which cells can we step to from any cell?", {
        ok: [[0, 0], [0, 1], [0, 2], [1, 2]],
      }),
    ]),
    G([["A", "B"]], [
      s("A tiny board with just A and B. We search for the word ABA. Start at the A.", {
        hl: [[0, 0]],
      }),
      s("Step to the B.", {
        ok: [[0, 0]], hl: [[0, 1]],
      }),
      s("The next letter is A. The only A next to the B is the one we started on.", {
        ok: [[0, 1]], hl: [[0, 0]],
      }),
      s("Using that same A again would build ABA out of only one A on the board.", {
        ok: [[0, 1]], bad: [[0, 0]],
      }),
      s("Is that a valid way to find the word? What should we have done when we first stepped onto that A?", {
        ok: [[0, 1]], bad: [[0, 0]],
      }),
    ]),
  ],

  // ===============================================================
  // BATCH 15: Two Pointers (written from the real challenges)
  // ===============================================================

  // ---------------------------------------------------------------
  "Two Sum II - Input Array Is Sorted": [
    A([2, 3, 5, 8, 11], [
      s("The array is sorted and the target is 10. One pointer sits on the smallest number, one on the largest.", {
        ptrs: { l: 0, r: 4 },
      }),
      s("Their sum is 2 + 11 = 13, which is bigger than the target.", {
        hl: [0, 4], ptrs: { l: 0, r: 4 }, tags: { 4: "13 > 10" },
      }),
      s("Try moving the left pointer to 3. The sum becomes 3 + 11 = 14.", {
        hl: [1, 4], bad: [1], ptrs: { l: 1, r: 4 }, tags: { 4: "14 > 10" },
      }),
      s("That made the sum even bigger. Which pointer should move to bring it down?", {
        hl: [0, 4], ptrs: { l: 0, r: 4 }, tags: { 4: "13 > 10" },
      }),
    ]),
    A([2, 3, 5, 8, 11], [
      s("The right number, 11, makes 13 with the smallest number, 2. That is over the target of 10.", {
        hl: [0, 4], ptrs: { l: 0, r: 4 }, tags: { 0: "+11=13" },
      }),
      s("What if 11 were paired with the next number, 3?", {
        hl: [1, 4], ptrs: { l: 1, r: 4 }, tags: { 0: "+11=13", 1: "+11=14" },
      }),
      s("And with 5, then with 8?", {
        hl: [2, 3, 4], ptrs: { r: 4 }, tags: { 0: "+11=13", 1: "+11=14", 2: "+11=16", 3: "+11=19" },
      }),
      s("Look at all these sums next to the target of 10. Is there any reason to keep 11?", {
        bad: [4], tags: { 0: "+11=13", 1: "+11=14", 2: "+11=16", 3: "+11=19" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Remove Duplicates from Sorted Array": [
    A([0, 0, 1, 1, 1, 2, 2, 3, 3, 4], [
      s("Here is a sorted array.", {}),
      s("Look at the value 1. Where are its copies?", {
        hl: [2, 3, 4],
      }),
      s("Now the value 2.", {
        ok: [2, 3, 4], hl: [5, 6],
      }),
      s("And the value 3.", {
        ok: [2, 3, 4, 5, 6], hl: [7, 8],
      }),
      s("Where do copies of a value always sit in a sorted array?", {
        hl: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      }),
    ]),
    A([0, 0, 1, 1, 2], [
      s("Index 0 is always kept. Two pointers, i and j, start at index 1.", {
        ok: [0], ptrs: { i: 1, j: 1 },
      }),
      s("i looks at index 1. It equals the last kept value, 0, so nothing is copied.", {
        ok: [0], bad: [1], ptrs: { i: 1, j: 1 },
      }),
      s("i moves on and finds a new value, 1. It is copied to the spot where j points.", {
        values: [0, 1, 1, 1, 2], ok: [0], hl: [1, 2], ptrs: { i: 2, j: 1 },
      }),
      s("Then j steps forward, but i moves on every time. What is each pointer for?", {
        values: [0, 1, 1, 1, 2], ok: [0, 1], ptrs: { i: 3, j: 2 },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Remove Element": [
    A([3, 2, 2, 3], [
      s("We remove every 3 from this array. The numbers that stay must end up at the front.", {}),
      s("These are the 3s.", {
        bad: [0, 3],
      }),
      s("These are the other numbers.", {
        bad: [0, 3], ok: [1, 2],
      }),
      s("After the removal, which elements should fill the first positions of the array?", {
        bad: [0, 3], ok: [1, 2],
      }),
    ]),
    A([1, 3, 2, 3, 4], [
      s("Remove every 3. The numbers that stay must sit together at the front, with no gaps.", {}),
      s("The 1 is kept. It is already at the front.", {
        ok: [0],
      }),
      s("The 3 is removed, so we skip over it.", {
        ok: [0], bad: [1],
      }),
      s("The 2 is kept. Where in the array should it be written?", {
        ok: [0], bad: [1], hl: [2],
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Squares of a Sorted Array": [
    A([-4, -1, 0, 3, 10], [
      s("The array is sorted: -4, -1, 0, 3, 10. We want the squares in sorted order.", {}),
      s("Square every number and look at the results.", {
        hl: [0, 1, 2, 3, 4], tags: { 0: "16", 1: "1", 2: "0", 3: "9", 4: "100" },
      }),
      s("Negative numbers turn positive when squared. -4 gives 16, far bigger than the squares of -1 or 0.", {
        hl: [0, 1, 2], tags: { 0: "16", 1: "1", 2: "0", 3: "9", 4: "100" },
      }),
      s("Where in the array could the biggest square come from?", {
        tags: { 0: "16", 1: "1", 2: "0", 3: "9", 4: "100" },
      }),
    ]),
    A(["_", "_", "_", "_", "_"], [
      s("The result has 5 empty slots, to be filled from smallest to largest.", {
        tags: { 0: "smallest", 4: "largest" },
      }),
      s("The squares at the two ends of the input are 16 and 100.", {
        tags: { 0: "smallest", 4: "largest" }, aux: { label: "end squares", items: ["16", "100"] },
      }),
      s("Which slot of the result can we fill right now, and with which square?", {
        tags: { 0: "smallest", 4: "largest" }, aux: { label: "end squares", items: ["16", "100"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Valid Palindrome II": [
    A(["a", "b", "c", "a"], [
      s("We compare from both ends. We may delete at most one character.", {
        ptrs: { l: 0, r: 3 },
      }),
      s("a and a match. Both pointers move inward.", {
        ok: [0, 3], ptrs: { l: 1, r: 2 },
      }),
      s("b and c do not match.", {
        ok: [0, 3], bad: [1, 2], ptrs: { l: 1, r: 2 },
      }),
      s("The word is not a palindrome yet, but one deletion is allowed. What can we do here?", {
        ok: [0, 3], bad: [1, 2], ptrs: { l: 1, r: 2 },
      }),
    ]),
    A(["a", "b", "c", "a"], [
      s("Suppose we delete the c.", {
        bad: [2],
      }),
      s("The letters left are a, b, a.", {
        ok: [0, 1, 3], bad: [2],
      }),
      s("We have used our one deletion. What must these remaining letters satisfy for the answer to be true?", {
        ok: [0, 1, 3], bad: [2],
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "3Sum Closest": [
    A([-4, -1, 1, 2], [
      s("The array is sorted: -4, -1, 1, 2. The target is 1, and we want three numbers with a sum close to it.", {}),
      s("Fix the first number, -4. Now we need the best two numbers from the rest.", {
        ok: [0], hl: [1, 2, 3], tags: { 0: "fixed" },
      }),
      s("The rest is sorted too. How can that order help us find the best pair quickly?", {
        ok: [0], hl: [1, 2, 3], tags: { 0: "fixed" },
      }),
    ]),
    A([-4, -1, 1, 2], [
      s("The fixed number is -4. The pointers sit on -1 and 2.", {
        ok: [0], ptrs: { l: 1, r: 3 }, tags: { 0: "fixed" },
      }),
      s("The sum is -4 + -1 + 2 = -3. The target is 1, so the sum is too small.", {
        ok: [0], hl: [1, 3], ptrs: { l: 1, r: 3 }, tags: { 0: "fixed", 3: "-3 < 1" },
      }),
      s("Try moving the right pointer left, to 1. The sum becomes -4 - 1 + 1 = -4.", {
        ok: [0], bad: [2], ptrs: { l: 1, r: 2 }, tags: { 0: "fixed", 2: "-4 < 1" },
      }),
      s("That moved the sum further from the target. Which pointer should move to raise the sum?", {
        ok: [0], hl: [1, 3], ptrs: { l: 1, r: 3 }, tags: { 0: "fixed", 3: "-3 < 1" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "4Sum": [
    A([-2, -1, 0, 0, 1, 2], [
      s("We need four numbers that add up to 0. The array is sorted.", {}),
      s("Fix the first number, -2.", {
        ok: [0], tags: { 0: "fixed" },
      }),
      s("Fix a second number, -1.", {
        ok: [0, 1], tags: { 0: "fixed", 1: "fixed" },
      }),
      s("Now two more numbers are needed from the rest. Which problem from earlier does that look like?", {
        ok: [0, 1], hl: [2, 3, 4, 5], tags: { 0: "fixed", 1: "fixed" },
      }),
    ]),
    A([-2, -1, 1, 1, 2, 2], [
      s("We fixed -2 and -1, so the last two numbers must add up to 3.", {
        ok: [0, 1],
      }),
      s("The pair 1 and 2 works. But there are two 1s and two 2s.", {
        ok: [0, 1], hl: [2, 3, 4, 5],
      }),
      s("The first 1 with the first 2 gives the group -2, -1, 1, 2.", {
        ok: [0, 1, 2, 4],
      }),
      s("The second 1, or the second 2, gives that very same group again.", {
        ok: [0, 1, 2, 4], bad: [3, 5],
      }),
      s("The answer must list each group only once. What should we do with equal values that sit side by side?", {
        ok: [0, 1, 2, 4], bad: [3, 5],
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Trapping Rain Water": [
    A([3, 0, 2, 0, 4], [
      s("Each number is the height of a bar. Water collects in the dips between taller bars.", {}),
      s("Look at the dip at index 1, which has height 0.", {
        hl: [1],
      }),
      s("The tallest bar to its left is 3.", {
        ok: [0], hl: [1], tags: { 0: "left: 3" },
      }),
      s("The tallest bar to its right is 4.", {
        ok: [0, 4], hl: [1], tags: { 0: "left: 3", 4: "right: 4" },
      }),
      s("How high can the water rise above this dip?", {
        ok: [0, 4], hl: [1], tags: { 0: "left: 3", 4: "right: 4" },
      }),
    ]),
    A([3, 0, 2, 0, 4], [
      s("Two pointers start at the ends. Each side remembers the tallest bar it has seen.", {
        ptrs: { l: 0, r: 4 }, aux: { label: "tallest", items: ["left 3", "right 4"] },
      }),
      s("The left side's tallest bar is 3 and the right side's is 4. They are not equal.", {
        hl: [0, 4], ptrs: { l: 0, r: 4 }, aux: { label: "tallest", items: ["left 3", "right 4"] },
      }),
      s("We can only move one pointer at a time. For which side do we already know the water level for sure?", {
        ptrs: { l: 0, r: 4 }, aux: { label: "tallest", items: ["left 3", "right 4"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Boats to Save People": [
    A([1, 2, 2, 3], [
      s("The weights, sorted, are 1, 2, 2, 3. A boat holds at most 2 people and a weight of 3.", {}),
      s("Two people can share a boat if together they weigh at most 3. A 1 and a 2 fit.", {
        ok: [0, 1],
      }),
      s("A 2 and another 2 weigh 4, which is too much.", {
        bad: [1, 2],
      }),
      s("Many pairings are possible. Which two people should we try to pair first?", {}),
    ]),
    A([2, 3, 3], [
      s("Now the weights are 2, 3, 3 and the boat limit is 4. We try the lightest with the heaviest.", {
        ptrs: { a: 0, b: 2 },
      }),
      s("Together they weigh 2 + 3 = 5, which is over the limit.", {
        bad: [0, 2], ptrs: { a: 0, b: 2 }, tags: { 2: "5 > 4" },
      }),
      s("They do not fit together, but the heaviest person still needs a boat.", {
        hl: [2], ptrs: { a: 0, b: 2 }, tags: { 2: "5 > 4" },
      }),
      s("Everyone else weighs at least as much as the lightest. What should happen to the heaviest person?", {
        hl: [2], ptrs: { a: 0, b: 2 }, tags: { 2: "5 > 4" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Is Subsequence": [
    A(["a", "h", "b", "g", "d", "c"], [
      s("We scan t for the letters of abc, in order. First we need an a.", {
        ptrs: { i: 0 }, aux: { label: "s is", items: ["a", "b", "c"] },
      }),
      s("The first letter of t is a. It matches the letter we need.", {
        ok: [0], ptrs: { i: 0 }, aux: { label: "s is", items: ["a", "b", "c"] },
      }),
      s("The a is matched. What should we look for next as we move on to h?", {
        ok: [0], hl: [1], ptrs: { i: 1 }, aux: { label: "s is", items: ["a", "b", "c"] },
      }),
    ]),
    A(["a", "h", "b", "g", "d", "c"], [
      s("In t, the letters a, b and c appear in that order, with other letters between them.", {
        ok: [0, 2, 5],
      }),
      s("The letters h, g and d were skipped over along the way.", {
        ok: [0, 2, 5], bad: [1, 3, 4],
      }),
      s("We have reached the end of t. What tells us that s is a subsequence of t?", {
        ok: [0, 2, 5], bad: [1, 3, 4], ptrs: { i: 5 },
      }),
    ]),
  ],

  // ===============================================================
  // BATCH 16: Sliding Window, Greedy, Bit Manipulation, Prefix Sum & Hashing,
  // Matrix, Heap (written from the real challenges)
  // ===============================================================

  // ---------------------------------------------------------------
  "Maximum Average Subarray I": [
    A([1, 12, -5, -6, 50, 3], [
      s("The window length is k = 4. Every window we look at has exactly 4 numbers.", {
        hl: [0, 1, 2, 3],
      }),
      s("First window: 1, 12, -5, -6. Its sum is 2 and its average is 0.5.", {
        hl: [0, 1, 2, 3], tags: { 0: "sum 2", 3: "avg 0.5" },
      }),
      s("Second window: 12, -5, -6, 50. Its sum is 51 and its average is 12.75.", {
        hl: [1, 2, 3, 4], tags: { 1: "sum 51", 4: "avg 12.75" },
      }),
      s("Third window: -5, -6, 50, 3. Its sum is 42 and its average is 10.5.", {
        hl: [2, 3, 4, 5], tags: { 2: "sum 42", 5: "avg 10.5" },
      }),
      s("All three windows have the same length. What could we compare instead of comparing averages?", {}),
    ]),
    A([1, 12, -5, -6, 50, 3], [
      s("The window covers 1, 12, -5, -6. Its sum is 2.", {
        hl: [0, 1, 2, 3], tags: { 0: "sum 2" },
      }),
      s("Slide it one step right. The 1 leaves the window and the 50 enters it.", {
        ok: [1, 2, 3], bad: [0], hl: [4], tags: { 0: "leaves", 4: "enters" },
      }),
      s("The new window is 12, -5, -6, 50. Its sum is 51.", {
        hl: [1, 2, 3, 4], tags: { 1: "sum 51" },
      }),
      s("The sum went from 2 to 51. How can we update it, instead of adding up all four numbers again?", {
        hl: [1, 2, 3, 4], tags: { 0: "leaves", 4: "enters" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Minimum Size Subarray Sum": [
    A([2, 3, 1, 2, 4, 3], [
      s("All the numbers are positive. We grow a window from the left end.", {
        hl: [0], ptrs: { l: 0, r: 0 }, tags: { 0: "sum 2" },
      }),
      s("Add the 3 to the window.", {
        hl: [0, 1], ptrs: { l: 0, r: 1 }, tags: { 1: "sum 5" },
      }),
      s("Add the 1.", {
        hl: [0, 1, 2], ptrs: { l: 0, r: 2 }, tags: { 2: "sum 6" },
      }),
      s("Add the 2.", {
        hl: [0, 1, 2, 3], ptrs: { l: 0, r: 3 }, tags: { 3: "sum 8" },
      }),
      s("Look at what the sum did each time we added a number. What does adding a positive number do?", {
        hl: [0, 1, 2, 3], ptrs: { l: 0, r: 3 }, tags: { 3: "sum 8" },
      }),
    ]),
    A([2, 3, 1, 2, 4, 3], [
      s("The window 2, 3, 1, 2 has sum 8. The target is 7, so this window is valid.", {
        hl: [0, 1, 2, 3], ptrs: { l: 0, r: 3 }, tags: { 3: "sum 8" },
      }),
      s("Its length is 4. We are looking for the shortest valid window.", {
        hl: [0, 1, 2, 3], ptrs: { l: 0, r: 3 }, tags: { 0: "length 4" },
      }),
      s("We have not found a shorter valid window yet. What should we try next?", {
        hl: [0, 1, 2, 3], ptrs: { l: 0, r: 3 }, tags: { 0: "length 4" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Longest Repeating Character Replacement": [
    A(["A", "A", "B", "A", "B", "B", "A"], [
      s("We look at a window of letters: A, A, B, A. We want all of them to be the same letter.", {
        hl: [0, 1, 2, 3],
      }),
      s("Count the letters in the window. A appears 3 times and B appears once.", {
        hl: [0, 1, 2, 3], aux: { label: "counts", items: ["A:3", "B:1"] },
      }),
      s("We keep the most frequent letter and change the others. The window length is 4.", {
        ok: [0, 1, 3], bad: [2], aux: { label: "counts", items: ["A:3", "B:1"] },
      }),
      s("How many changes does this window need?", {
        ok: [0, 1, 3], bad: [2], aux: { label: "counts", items: ["A:3", "B:1"] },
      }),
    ]),
    A(["A", "A", "B", "A", "B", "B", "A"], [
      s("Now k = 1, so at most 1 change is allowed. Here is the window A, B, A, B.", {
        hl: [1, 2, 3, 4], ptrs: { l: 1, r: 4 }, aux: { label: "counts", items: ["A:2", "B:2"] },
      }),
      s("The most frequent letter appears 2 times in a window of 4. So the window needs 2 changes.", {
        hl: [1, 2, 3, 4], ptrs: { l: 1, r: 4 }, tags: { 4: "needs 2" },
        aux: { label: "counts", items: ["A:2", "B:2"] },
      }),
      s("That is more than k = 1, so this window is not allowed.", {
        bad: [1, 2, 3, 4], ptrs: { l: 1, r: 4 }, tags: { 4: "needs 2" },
        aux: { label: "counts", items: ["A:2", "B:2"] },
      }),
      s("The right edge cannot go back. What should we do to make the window allowed again?", {
        bad: [1, 2, 3, 4], ptrs: { l: 1, r: 4 }, tags: { 4: "needs 2" },
        aux: { label: "counts", items: ["A:2", "B:2"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Permutation in String": [
    A(["a", "b"], [
      s("Here is the string ab and the letters in it.", {
        aux: { label: "letters", items: ["a:1", "b:1"] },
      }),
      s("Here is ba. It is a permutation of ab.", {
        values: ["b", "a"], ok: [0, 1], aux: { label: "letters", items: ["a:1", "b:1"] },
      }),
      s("But aa is not a permutation of ab.", {
        values: ["a", "a"], bad: [0, 1], aux: { label: "letters", items: ["a:2"] },
      }),
      s("What do ab and ba have in common that ab and aa do not?", {
        values: ["b", "a"], ok: [0, 1], aux: { label: "letters", items: ["a:1", "b:1"] },
      }),
    ]),
    A(["e", "i", "d", "b", "a", "o", "o", "o"], [
      s("A window of 2 letters sits over s2. It holds e and i.", {
        hl: [0, 1], aux: { label: "counts", items: ["e:1", "i:1"] },
      }),
      s("Slide it one step right: e leaves and d enters. The counts below are still the old ones.", {
        bad: [0], hl: [1, 2], tags: { 0: "leaves", 2: "enters" },
        aux: { label: "counts", items: ["e:1", "i:1"] },
      }),
      s("Here are the counts for the new window, i and d.", {
        hl: [1, 2], aux: { label: "counts", items: ["i:1", "d:1"] },
      }),
      s("Compare the old counts with the new ones. How do the counts change when the window slides?", {
        hl: [1, 2], aux: { label: "counts", items: ["i:1", "d:1"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Jump Game": [
    A([2, 3, 1, 1, 4], [
      s("Each number says the farthest we can jump forward from that spot.", {}),
      s("We stand on index 1, which holds 3.", {
        hl: [1], ptrs: { i: 1 }, tags: { 1: "max 3" },
      }),
      s("A jump of 3 steps lands on index 4, the last index.", {
        hl: [1], ok: [4], ptrs: { i: 1 }, tags: { 1: "max 3", 4: "+3 steps" },
      }),
      s("Which indexes can we reach in one jump from index 1?", {
        hl: [1], ptrs: { i: 1 }, tags: { 1: "max 3" },
      }),
    ]),
    A([2, 3, 1, 1, 4], [
      s("We scan from left to right and keep asking how far we could possibly get.", {
        ptrs: { i: 0 }, aux: { label: "we keep", items: ["0"] },
      }),
      s("At index 0 the value is 2, so index 2 is as far as we can get.", {
        hl: [0], ptrs: { i: 0 }, aux: { label: "we keep", items: ["2"] },
      }),
      s("At index 1 the value is 3, so we can get as far as index 4.", {
        ok: [0], hl: [1], ptrs: { i: 1 }, aux: { label: "we keep", items: ["4"] },
      }),
      s("At index 2 the value is 1. That only reaches index 3, less than we already know.", {
        ok: [0, 1], hl: [2], ptrs: { i: 2 }, aux: { label: "we keep", items: ["4"] },
      }),
      s("We only ever needed one number. Which single number did we keep track of?", {
        ok: [0, 1, 2], aux: { label: "we keep", items: ["4"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Gas Station": [
    A([-1, -1, 1], [
      s("Three stations. Each number is the fuel gained at a station minus the cost of the next road.", {
        tags: { 0: "2 - 3", 1: "3 - 4", 2: "4 - 3" },
      }),
      s("Add up all three numbers: all the fuel we can collect minus all the fuel we must burn.", {
        hl: [0, 1, 2], tags: { 0: "2 - 3", 1: "3 - 4", 2: "4 - 3" }, out: "total -1",
      }),
      s("The total gas is less than the total cost. What is the answer?", {
        hl: [0, 1, 2], tags: { 0: "2 - 3", 1: "3 - 4", 2: "4 - 3" }, out: "total -1",
      }),
    ]),
    A([1, -1, -2, 3], [
      s("Each number is fuel gained minus the next road's cost. We start at station 0 with an empty tank.", {
        ptrs: { start: 0 }, aux: { label: "tank", items: ["0"] },
      }),
      s("After station 0 the tank holds 1.", {
        hl: [0], ptrs: { start: 0 }, aux: { label: "tank", items: ["1"] },
      }),
      s("After station 1 it holds 0.", {
        ok: [0], hl: [1], ptrs: { start: 0, at: 1 }, aux: { label: "tank", items: ["0"] },
      }),
      s("After station 2 it would be -2. We run out of fuel on the road leaving station 2.", {
        ok: [0, 1], bad: [2], ptrs: { start: 0, at: 2 }, aux: { label: "tank", items: ["-2"] },
      }),
      s("We started at station 0. What can we conclude about starting at stations 0, 1 and 2?", {
        ok: [0, 1], bad: [2], ptrs: { start: 0, at: 2 }, aux: { label: "tank", items: ["-2"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Best Time to Buy and Sell Stock II": [
    A([1, 3, 6], [
      s("Prices over three days are 1, 3 and 6.", {}),
      s("Plan 1: buy on day 1 and sell on day 3. That earns 6 - 1.", {
        hl: [0, 2], tags: { 0: "buy", 2: "sell" }, out: "plan 1: 6 - 1",
      }),
      s("Plan 2: buy on day 1 and sell on day 2. That earns 3 - 1.", {
        hl: [0, 1], tags: { 0: "buy", 1: "sell" }, out: "plan 2: 3 - 1",
      }),
      s("Then buy again on day 2 and sell on day 3. That earns 6 - 3 more.", {
        hl: [1, 2], tags: { 1: "buy", 2: "sell" }, out: "plan 2: (3 - 1) + (6 - 3)",
      }),
      s("Compare the two plans. How does holding through the whole climb compare with adding up the small rises?", {
        out: "plan 1: 6 - 1 | plan 2: (3 - 1) + (6 - 3)",
      }),
    ]),
    A([1, 3, 2, 5], [
      s("Prices are 1, 3, 2 and 5. Look at each day-to-day change.", {}),
      s("From 1 to 3 the price rises by 2.", {
        ok: [0, 1], tags: { 1: "+2" }, out: "profit so far: 2",
      }),
      s("From 3 to 2 the price falls.", {
        ok: [0, 1], bad: [1, 2], tags: { 1: "+2", 2: "-1" }, out: "profit so far: 2",
      }),
      s("How much should the fall from 3 to 2 add to our profit?", {
        ok: [0, 1], bad: [1, 2], tags: { 1: "+2", 2: "-1" }, out: "profit so far: 2",
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Partition Labels": [
    A(["a", "b", "a", "b", "c", "d", "c"], [
      s("We cut the string into parts so that no letter appears in two parts.", {}),
      s("The first part starts at index 0, which holds the letter a.", {
        ok: [0],
      }),
      s("There is another a later in the string.", {
        ok: [0], hl: [2],
      }),
      s("How far must the first part extend, given that it holds the letter a?", {
        ok: [0], hl: [2],
      }),
    ]),
    A(["a", "b", "a", "b", "c", "d", "c"], [
      s("The last position of each letter is a:2, b:3, c:6, d:5. We scan from the left.", {
        ptrs: { i: 0 }, aux: { label: "last at", items: ["a:2", "b:3", "c:6", "d:5"] },
      }),
      s("At index 1 we have met the letters a and b.", {
        ok: [0], hl: [1], ptrs: { i: 1 }, aux: { label: "last at", items: ["a:2", "b:3", "c:6", "d:5"] },
      }),
      s("At index 2 we are on a again. Could the part end here?", {
        ok: [0, 1], hl: [2], ptrs: { i: 2 }, aux: { label: "last at", items: ["a:2", "b:3", "c:6", "d:5"] },
      }),
      s("No: there is still a b at index 3. So when is it safe to end a part at an index i?", {
        ok: [0, 1, 2], bad: [3], ptrs: { i: 2 }, aux: { label: "last at", items: ["a:2", "b:3", "c:6", "d:5"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Single Number": [
    A(["_", "_", "_"], [
      s("We XOR 5 (101) with another 5 (101), one bit column at a time. The result row is empty so far.", {
        tags: { 0: "1 ^ 1", 1: "0 ^ 0", 2: "1 ^ 1" },
      }),
      s("First column: 1 XOR 1 gives 0.", {
        values: [0, "_", "_"], hl: [0], tags: { 0: "1 ^ 1", 1: "0 ^ 0", 2: "1 ^ 1" },
      }),
      s("Second and third columns: 0 XOR 0 gives 0, and 1 XOR 1 gives 0.", {
        values: [0, 0, 0], ok: [0, 1, 2], tags: { 0: "1 ^ 1", 1: "0 ^ 0", 2: "1 ^ 1" },
      }),
      s("The whole result is 000. What does any number give when it is XORed with itself?", {
        values: [0, 0, 0], ok: [0, 1, 2],
      }),
    ]),
    A([4, 1, 2, 1, 2], [
      s("Start with 0 and XOR in the numbers one at a time.", {
        ptrs: { i: 0 }, aux: { label: "running", items: ["0"] },
      }),
      s("XOR in 4. The running value is 4.", {
        hl: [0], aux: { label: "running", items: ["4"] },
      }),
      s("XOR in 1 and then 2. The running value is 7.", {
        ok: [0], hl: [1, 2], aux: { label: "running", items: ["7"] },
      }),
      s("XOR in the second 1. The running value is 6.", {
        ok: [0, 1, 2], hl: [3], aux: { label: "running", items: ["6"] },
      }),
      s("XOR in the second 2. The running value is 4. What happened to the numbers that appear twice?", {
        ok: [0, 1, 2, 3], hl: [4], aux: { label: "running", items: ["4"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Number of 1 Bits": [
    A([1, 1, 0, 0], [
      s("n = 12 is 1100 in binary.", {
        aux: { label: "n", items: ["1100"] },
      }),
      s("n - 1 = 11 is 1011.", {
        values: [1, 0, 1, 1], aux: { label: "n", items: ["1100"] },
      }),
      s("AND the two bit by bit. 1100 and 1011 give 1000. The second bit disappeared.", {
        values: [1, 0, 0, 0], ok: [0], bad: [1], aux: { label: "n", items: ["1100"] },
      }),
      s("Compare 1000 with the original 1100. What did n & (n - 1) do to n?", {
        values: [1, 0, 0, 0], ok: [0], bad: [1], aux: { label: "n", items: ["1100"] },
      }),
    ]),
    A([1, 1, 0, 1], [
      s("Now n = 13, which is 1101 in binary.", {
        aux: { label: "steps", items: ["0"] },
      }),
      s("Apply n & (n - 1) once. The result is 1100.", {
        values: [1, 1, 0, 0], bad: [3], aux: { label: "steps", items: ["1"] },
      }),
      s("Apply it again. The result is 1000.", {
        values: [1, 0, 0, 0], bad: [1], aux: { label: "steps", items: ["2"] },
      }),
      s("And again. The result is 0000.", {
        values: [0, 0, 0, 0], bad: [0], aux: { label: "steps", items: ["3"] },
      }),
      s("After 3 steps n is 0. How does that number of steps relate to the bits of 1101?", {
        values: [0, 0, 0, 0], aux: { label: "steps", items: ["3"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Counting Bits": [
    A([0, 1, 2, 3, 4, 5, 6, 7], [
      s("The numbers 0 to 7, each with the count of its 1 bits.", {
        tags: BIT_TAGS,
      }),
      s("Look at 6, which is 110. Dropping its last bit gives 3, which is 11.", {
        hl: [6, 3], tags: BIT_TAGS,
      }),
      s("6 and 3 both have two 1 bits.", {
        ok: [6, 3], tags: BIT_TAGS,
      }),
      s("Now 7, which is 111. Dropping its last bit gives 3 again.", {
        ok: [6], hl: [7, 3], tags: BIT_TAGS,
      }),
      s("7 has three 1 bits and 3 has two. How do the counts of i and i >> 1 compare?", {
        hl: [7, 3], tags: BIT_TAGS,
      }),
    ]),
    A(["-", "-", "-", "-", "-", "-", "-", "-"], [
      s("We fill in the answers from 0 upward. Nothing is filled in yet.", {
        tags: { 0: "ans[0]", 7: "ans[7]" },
      }),
      s("The first few answers are known.", {
        values: [0, 1, 1, "-", "-", "-", "-", "-"], ok: [0, 1, 2],
      }),
      s("To fill ans[3] we use 3 >> 1, which is 1. The answer for 1 is already there.", {
        values: [0, 1, 1, "-", "-", "-", "-", "-"], hl: [3], ok: [1],
      }),
      s("Now ans[3] is filled in.", {
        values: [0, 1, 1, 2, "-", "-", "-", "-"], ok: [0, 1, 2, 3],
      }),
      s("To fill ans[7] we look at 7 >> 1 = 3. Is that answer already filled in?", {
        values: [0, 1, 1, 2, "-", "-", "-", "-"], hl: [7], ok: [3],
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Missing Number": [
    A([3, 0, 1], [
      s("The array holds 3 numbers from the range 0 to 3. One number of the range is missing.", {
        aux: { label: "range", items: ["0", "1", "2", "3"] },
      }),
      s("The full range 0, 1, 2, 3 adds up to 6.", {
        aux: { label: "range", items: ["0", "1", "2", "3"] }, out: "full range: 6",
      }),
      s("The array 3, 0, 1 adds up to 4.", {
        hl: [0, 1, 2], aux: { label: "range", items: ["0", "1", "2", "3"] }, out: "full range: 6 | array: 4",
      }),
      s("The array's sum is short of the full sum. What does the gap tell us?", {
        aux: { label: "range", items: ["0", "1", "2", "3"] }, out: "full range: 6 | array: 4",
      }),
    ]),
    A([3, 0, 1], [
      s("Put the indexes 0, 1, 2, 3 and the array's values 3, 0, 1 together in one list, to XOR them.", {
        aux: { label: "list", items: ["0", "1", "2", "3", "3", "0", "1"] },
      }),
      s("The numbers 0, 1 and 3 each appear twice in this list.", {
        hl: [0, 1, 2], aux: { label: "list", items: ["0", "1", "2", "3", "3", "0", "1"] },
      }),
      s("Now XOR all seven numbers together. What is left at the end?", {
        aux: { label: "list", items: ["0", "1", "2", "3", "3", "0", "1"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Subarray Sum Equals K": [
    A([1, 2, 3], [
      s("The prefix sums of 1, 2, 3 are 0, 1, 3, 6. Each one is the total of the numbers so far.", {
        aux: { label: "prefix", items: ["0", "1", "3", "6"] },
      }),
      s("Take the stretch 2, 3. Its sum is 5.", {
        hl: [1, 2], aux: { label: "prefix", items: ["0", "1", "3", "6"] },
      }),
      s("The prefix before the stretch is 1, and the prefix after it is 6.", {
        hl: [1, 2], tags: { 1: "before 1", 2: "after 6" },
        aux: { label: "prefix", items: ["0", "1", "3", "6"] },
      }),
      s("How can the stretch's sum, 5, be made from the prefix sums 1 and 6?", {
        hl: [1, 2], tags: { 1: "before 1", 2: "after 6" },
        aux: { label: "prefix", items: ["0", "1", "3", "6"] },
      }),
    ]),
    A([1, 2, 3], [
      s("k = 3. We walk along, keeping the prefix sums we have seen. At the start we have seen 0.", {
        ptrs: { i: 0 }, aux: { label: "seen", items: ["0"] },
      }),
      s("After the 1, the prefix is 1.", {
        hl: [0], tags: { 0: "P = 1" }, aux: { label: "seen", items: ["0"] },
      }),
      s("After the 2, the prefix is 3. Which earlier prefix would make a stretch ending here sum to k = 3?", {
        ok: [0], hl: [1], tags: { 1: "P = 3" }, aux: { label: "seen", items: ["0", "1"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Longest Consecutive Sequence": [
    A([100, 4, 200, 1, 3, 2], [
      s("All the numbers go into a set, so we can check quickly whether a number is present.", {
        aux: { label: "set", items: ["100", "4", "200", "1", "3", "2"] },
      }),
      s("Look at 4. The number just before it, 3, is in the set.", {
        hl: [1], ok: [4], aux: { label: "set", items: ["100", "4", "200", "1", "3", "2"] },
      }),
      s("Look at 1. The number just before it, 0, is not in the set.", {
        hl: [3], tags: { 3: "0 missing" }, aux: { label: "set", items: ["100", "4", "200", "1", "3", "2"] },
      }),
      s("Look at 100. The number just before it, 99, is not in the set either.", {
        hl: [0], tags: { 0: "99 missing" }, aux: { label: "set", items: ["100", "4", "200", "1", "3", "2"] },
      }),
      s("Some numbers have their predecessor in the set and some do not. Which should start counting a sequence?", {
        aux: { label: "set", items: ["100", "4", "200", "1", "3", "2"] },
      }),
    ]),
    A([100, 4, 200, 1, 3, 2], [
      s("Counting from the start 1, we check 2, then 3, then 4.", {
        ok: [3, 5, 4, 1], tags: { 3: "start" }, aux: { label: "set", items: ["100", "4", "200", "1", "3", "2"] },
      }),
      s("The numbers 2, 3 and 4 are not starts, so nobody counts from them.", {
        ok: [3, 5, 4, 1], tags: { 3: "start", 5: "skipped", 4: "skipped", 1: "skipped" },
        aux: { label: "set", items: ["100", "4", "200", "1", "3", "2"] },
      }),
      s("The starts 100 and 200 each count just themselves.", {
        ok: [3, 5, 4, 1], hl: [0, 2], tags: { 0: "start", 2: "start" },
        aux: { label: "set", items: ["100", "4", "200", "1", "3", "2"] },
      }),
      s("Count how many times each number was walked over. Why does that keep the total work small?", {
        ok: [3, 5, 4, 1, 0, 2], aux: { label: "set", items: ["100", "4", "200", "1", "3", "2"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Contiguous Array": [
    A([0, 1, 0], [
      s("We look for a stretch with equal numbers of 0s and 1s. The array is 0, 1, 0.", {}),
      s("Now treat each 0 as -1.", {
        values: [-1, 1, -1],
      }),
      s("The stretch -1, 1 has one of each.", {
        values: [-1, 1, -1], hl: [0, 1],
      }),
      s("What is the sum of a stretch that has equal numbers of 0s and 1s?", {
        values: [-1, 1, -1], hl: [0, 1],
      }),
    ]),
    A([-1, 1, 1, -1], [
      s("With 0 as -1, the array is -1, 1, 1, -1. The running sum is 0 before the first number.", {
        aux: { label: "running", items: ["0"] },
      }),
      s("After each number, the running sum is -1, 0, 1, 0.", {
        tags: { 0: "run -1", 1: "run 0", 2: "run 1", 3: "run 0" },
        aux: { label: "running", items: ["0", "-1", "0", "1", "0"] },
      }),
      s("The running sum is 0 at the start and also after the second number. Look at the stretch between them.", {
        hl: [0, 1], tags: { 0: "run -1", 1: "run 0" },
        aux: { label: "running", items: ["0", "-1", "0", "1", "0"] },
      }),
      s("A running sum repeated at two places: what does that say about the stretch between them?", {
        hl: [0, 1], tags: { 0: "run -1", 1: "run 0" },
        aux: { label: "running", items: ["0", "-1", "0", "1", "0"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Spiral Matrix": [
    G(GRID_9, [
      s("We walk the grid in a spiral, clockwise, starting at the top-left corner.", {
        hl: [[0, 0]],
      }),
      s("First we walk the top row from left to right.", {
        ok: [[0, 0], [0, 1], [0, 2]], out: "1, 2, 3",
      }),
      s("The top row is finished. Which edge of the unvisited area has to move now?", {
        ok: [[0, 0], [0, 1], [0, 2]], out: "1, 2, 3",
      }),
    ]),
    G(GRID_9, [
      s("The outer layer is done: 1, 2, 3, 6, 9, 8, 7, 4.", {
        ok: [[0, 0], [0, 1], [0, 2], [1, 2], [2, 2], [2, 1], [2, 0], [1, 0]], out: "1, 2, 3, 6, 9, 8, 7, 4",
      }),
      s("Only the center cell, 5, is still unvisited.", {
        ok: [[0, 0], [0, 1], [0, 2], [1, 2], [2, 2], [2, 1], [2, 0], [1, 0]], hl: [[1, 1]],
        out: "1, 2, 3, 6, 9, 8, 7, 4",
      }),
      s("Visit it.", {
        ok: [[0, 0], [0, 1], [0, 2], [1, 2], [2, 2], [2, 1], [2, 0], [1, 0], [1, 1]],
        out: "1, 2, 3, 6, 9, 8, 7, 4, 5",
      }),
      s("Nothing is left to visit. How can the four boundaries tell us it is time to stop?", {
        ok: [[0, 0], [0, 1], [0, 2], [1, 2], [2, 2], [2, 1], [2, 0], [1, 0], [1, 1]],
        out: "1, 2, 3, 6, 9, 8, 7, 4, 5",
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Rotate Image": [
    G(GRID_9, [
      s("We rotate the grid 90 degrees clockwise. Follow the 1 in the top-left corner.", {
        hl: [[0, 0]],
      }),
      s("After the turn, the 1 sits in the top-right corner.", {
        values: [[7, 4, 1], [8, 5, 2], [9, 6, 3]], hl: [[0, 2]],
      }),
      s("Now follow the 3, which starts in the top-right corner.", {
        values: [[1, 2, 3], [4, 5, 6], [7, 8, 9]], hl: [[0, 2]],
      }),
      s("After the turn, the 3 sits in the bottom-right corner.", {
        values: [[7, 4, 1], [8, 5, 2], [9, 6, 3]], hl: [[2, 2]],
      }),
      s("The 1 and the 3 moved to new rows and columns. Where does the element at row i, column j go?", {
        values: [[7, 4, 1], [8, 5, 2], [9, 6, 3]], hl: [[0, 2], [2, 2]],
      }),
    ]),
    G(GRID_9, [
      s("The goal: after a clockwise quarter turn, the top row 1 2 3 ends up as the right column.", {
        hl: [[0, 0], [0, 1], [0, 2]],
      }),
      s("Try reversing every row.", {
        values: [[3, 2, 1], [6, 5, 4], [9, 8, 7]],
      }),
      s("Then reverse every column.", {
        values: [[9, 8, 7], [6, 5, 4], [3, 2, 1]], bad: [[0, 0], [0, 1], [0, 2]],
      }),
      s("That is a half turn, with 9 8 7 on top instead of 7 4 1. Which two steps make a quarter turn?", {
        values: [[9, 8, 7], [6, 5, 4], [3, 2, 1]], bad: [[0, 0], [0, 1], [0, 2]],
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Set Matrix Zeroes": [
    G(ZERO_3, [
      s("We scan row by row. Suppose we zero a row and column the moment we meet a 0.", {}),
      s("The scan reaches the 0 in the middle.", {
        hl: [[1, 1]],
      }),
      s("We zero its whole row and column at once. The new zeros are in red.", {
        values: [[1, 0, 1], [0, 0, 0], [1, 0, 1]], ok: [[1, 1]], bad: [[0, 1], [1, 0], [1, 2], [2, 1]],
      }),
      s("The scan carries on to the bottom row. The cell below the middle is now 0.", {
        values: [[1, 0, 1], [0, 0, 0], [1, 0, 1]], ok: [[1, 1]], hl: [[2, 1]], bad: [[0, 1], [1, 0], [1, 2]],
      }),
      s("We wrote that 0 ourselves. What goes wrong if the scan treats it like an original zero?", {
        values: [[1, 0, 1], [0, 0, 0], [1, 0, 1]], ok: [[1, 1]], hl: [[2, 1]],
      }),
    ]),
    G(ZERO_3, [
      s("The 0 in the middle means row 1 and column 1 will have to be zeroed later.", {
        hl: [[1, 1]],
      }),
      s("We want to remember that, without a copy of the matrix and without extra lists.", {
        hl: [[1, 1]],
      }),
      s("Where inside the matrix itself could we write a note for row 1 and a note for column 1?", {
        hl: [[1, 1]],
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Last Stone Weight": [
    A([2, 7, 4, 1, 8, 1], [
      s("The stones weigh 2, 7, 4, 1, 8 and 1. Each turn needs the two heaviest.", {}),
      s("Finding the heaviest means looking at every stone.", {
        hl: [0, 1, 2, 3, 4, 5],
      }),
      s("The two heaviest are 8 and 7. They smash together into a stone of weight 1.", {
        hl: [4, 1],
      }),
      s("A new stone appears, and we will need the heaviest again and again. Which structure keeps it easy to reach?", {
        hl: [4, 1],
      }),
    ]),
    A([8, 5, 2], [
      s("Stones 8, 5 and 2. The two heaviest, 8 and 5, smash together.", {
        hl: [0, 1],
      }),
      s("Both are destroyed, and a stone of weight 3 is left from the smash.", {
        values: ["-", "-", 2], bad: [0, 1], aux: { label: "new stone", items: ["3"] },
      }),
      s("The stone of weight 2 is still waiting.", {
        values: ["-", "-", 2], ok: [2], aux: { label: "new stone", items: ["3"] },
      }),
      s("The new stone of weight 3 is not on the list yet. What should we do with it?", {
        values: ["-", "-", 2], ok: [2], aux: { label: "new stone", items: ["3"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Find Median from Data Stream": [
    A([5, 1, 4, 2, 3], [
      s("Numbers arrive in any order: 5, 1, 4, 2, 3.", {}),
      s("In sorted order they read 1, 2, 3, 4, 5.", {
        values: [1, 2, 3, 4, 5],
      }),
      s("The median is the number in the middle.", {
        values: [1, 2, 3, 4, 5], hl: [2],
      }),
      s("Sorting after every new number is slow. How could we split the numbers so the middle is easy to find?", {
        values: [1, 2, 3, 4, 5], hl: [2],
      }),
    ]),
    A([1, 2, 3, 4], [
      s("The sorted numbers 1, 2, 3, 4, split into a lower half and an upper half.", {
        ok: [0, 1], hl: [2, 3], tags: { 0: "lower", 2: "upper" },
      }),
      s("With an even count, the median is the average of the two numbers in the middle, 2 and 3.", {
        ok: [0], hl: [1, 2], tags: { 0: "lower", 2: "upper" },
      }),
      s("To read the median quickly, which value of each half do we need ready?", {
        ok: [0, 1], hl: [2, 3], tags: { 0: "lower", 2: "upper" },
      }),
    ]),
  ],

  // ===============================================================
  // BATCH 17: Sliding Window, Greedy, Bit Manipulation, Prefix Sum & Hashing,
  // Matrix, Heap (second set, written from the real challenges)
  // ===============================================================

  // ---------------------------------------------------------------
  "Find All Anagrams in a String": [
    A(["c", "b", "a", "e", "b", "a", "b", "a", "c", "d"], [
      s("We look for anagrams of p = abc inside s. An anagram uses the same letters as p.", {
        aux: { label: "p", items: ["a", "b", "c"] },
      }),
      s("Here is a candidate substring of s: c, b, a.", {
        hl: [0, 1, 2], aux: { label: "p", items: ["a", "b", "c"] },
      }),
      s("It uses exactly the letters of p. Now try a longer substring: c, b, a, e.", {
        ok: [0, 1, 2], hl: [3], aux: { label: "p", items: ["a", "b", "c"] },
      }),
      s("Too long: the extra e means it is not an anagram.", {
        bad: [0, 1, 2, 3], aux: { label: "p", items: ["a", "b", "c"] },
      }),
      s("Too short: c and b alone are missing the a.", {
        bad: [0, 1], aux: { label: "p", items: ["a", "b", "c"] },
      }),
      s("How long must a substring of s be to have any chance of being an anagram of p?", {
        hl: [0, 1, 2], aux: { label: "p", items: ["a", "b", "c"] },
      }),
    ]),
    A(["c", "b", "a", "e", "b", "a", "b", "a", "c", "d"], [
      s("The window at index 0 holds c, b, a. Its letter counts are shown below.", {
        hl: [0, 1, 2], ptrs: { start: 0 }, aux: { label: "window", items: ["a:1", "b:1", "c:1"] },
      }),
      s("The letter counts of p = abc are shown below.", {
        hl: [0, 1, 2], ptrs: { start: 0 }, aux: { label: "p counts", items: ["a:1", "b:1", "c:1"] },
      }),
      s("The window's counts are equal to the counts of p.", {
        ok: [0, 1, 2], ptrs: { start: 0 }, aux: { label: "both", items: ["a:1", "b:1", "c:1"] },
      }),
      s("The answer is a list of start positions. What should we do now that this window matches p?", {
        ok: [0, 1, 2], ptrs: { start: 0 }, aux: { label: "both", items: ["a:1", "b:1", "c:1"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Fruit Into Baskets": [
    A([0, 1, 2, 2], [
      s("The trees in a row hold fruit of types 0, 1, 2, 2. We have two baskets, one fruit type per basket.", {}),
      s("Start at the first tree: pick 0, then 1. Both fit in the baskets.", {
        ok: [0, 1],
      }),
      s("The third tree has type 2, a third type. We must stop.", {
        ok: [0, 1], bad: [2],
      }),
      s("Start at the second tree instead: 1, 2, 2 uses only two types.", {
        ok: [1, 2, 3],
      }),
      s("We always pick trees in a row and may hold two types. What is this problem really asking for?", {
        ok: [1, 2, 3],
      }),
    ]),
    A([1, 2, 1, 3, 3], [
      s("The window holds 1, 2, 1. That is two types of fruit.", {
        hl: [0, 1, 2], ptrs: { l: 0, r: 2 }, aux: { label: "types", items: ["1:2", "2:1"] },
      }),
      s("The window grows to the right and takes in a 3.", {
        hl: [0, 1, 2], bad: [3], ptrs: { l: 0, r: 3 }, aux: { label: "types", items: ["1:2", "2:1", "3:1"] },
      }),
      s("Now the window holds three types, over our limit of two.", {
        bad: [0, 1, 2, 3], ptrs: { l: 0, r: 3 }, aux: { label: "types", items: ["1:2", "2:1", "3:1"] },
      }),
      s("The right edge cannot go back. What do we do to bring the window back under the limit?", {
        bad: [0, 1, 2, 3], ptrs: { l: 0, r: 3 }, aux: { label: "types", items: ["1:2", "2:1", "3:1"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Max Consecutive Ones III": [
    A([1, 1, 0, 1, 0, 0, 1], [
      s("We may flip at most k = 1 zero into a one. We want the longest stretch of 1s.", {}),
      s("Take the window 1, 1, 0, 1. It contains one zero.", {
        hl: [0, 1, 2, 3], tags: { 2: "zero" },
      }),
      s("Flip that zero and the whole window becomes 1s.", {
        values: [1, 1, 1, 1, 0, 0, 1], ok: [0, 1, 2, 3],
      }),
      s("Now take the window 1, 0, 1, 0 instead. It contains two zeros.", {
        hl: [1, 2, 3, 4], bad: [2, 4],
      }),
      s("Which windows can be turned into all 1s with our flips? What must be true about a window's zeros?", {
        hl: [1, 2, 3, 4], bad: [2, 4],
      }),
    ]),
    A([1, 1, 0, 1, 0, 0, 1], [
      s("k = 1. The window 1, 1, 0, 1 has one zero, which is allowed.", {
        hl: [0, 1, 2, 3], ptrs: { l: 0, r: 3 }, aux: { label: "zeros", items: ["1"] },
      }),
      s("Extend the window to the right. It now includes another 0.", {
        hl: [0, 1, 2, 3], bad: [4], ptrs: { l: 0, r: 4 }, aux: { label: "zeros", items: ["2"] },
      }),
      s("The window has 2 zeros, but only 1 flip is allowed.", {
        bad: [2, 4], hl: [0, 1, 3], ptrs: { l: 0, r: 4 }, aux: { label: "zeros", items: ["2"] },
      }),
      s("The right edge cannot move back. What do we do to the window?", {
        bad: [2, 4], hl: [0, 1, 3], ptrs: { l: 0, r: 4 }, aux: { label: "zeros", items: ["2"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Minimum Window Substring": [
    A(["A", "D", "O", "B", "E", "C"], [
      s("We need a window of s that has all the letters of t = ABC: A, B and C.", {
        aux: { label: "has", items: [] },
      }),
      s("The window A, D, O, B has an A and a B, but no C.", {
        hl: [0, 1, 2, 3], aux: { label: "has", items: ["A:1", "B:1"] },
      }),
      s("Add the E. There is still no C.", {
        hl: [0, 1, 2, 3, 4], aux: { label: "has", items: ["A:1", "B:1"] },
      }),
      s("Add the C. The window now has A:1, B:1 and C:1.", {
        hl: [0, 1, 2, 3, 4, 5], aux: { label: "has", items: ["A:1", "B:1", "C:1"] },
      }),
      s("Now it has A, B and C. In general, when does a window cover t, duplicates included?", {
        ok: [0, 1, 2, 3, 4, 5], aux: { label: "has", items: ["A:1", "B:1", "C:1"] },
      }),
    ]),
    A(["B", "B", "A", "N", "C"], [
      s("The window B, B, A, N, C covers t = ABC. Its length is 5.", {
        hl: [0, 1, 2, 3, 4], ptrs: { l: 0, r: 4 }, aux: { label: "has", items: ["A:1", "B:2", "C:1"] },
      }),
      s("Look at the leftmost B. Dropping it leaves B, A, N, C.", {
        bad: [0], hl: [1, 2, 3, 4], ptrs: { l: 1, r: 4 }, aux: { label: "has", items: ["A:1", "B:1", "C:1"] },
      }),
      s("That shorter window still has A, B and C, so it still covers t.", {
        bad: [0], ok: [1, 2, 3, 4], ptrs: { l: 1, r: 4 }, aux: { label: "has", items: ["A:1", "B:1", "C:1"] },
      }),
      s("We cut a letter from the left and it still covers t. How do we keep looking for a smaller window?", {
        bad: [0], ok: [1, 2, 3, 4], ptrs: { l: 1, r: 4 }, aux: { label: "has", items: ["A:1", "B:1", "C:1"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Subarray Product Less Than K": [
    A([10, 5, 2, 6], [
      s("k = 100. The window 5, 2, 6 has product 60, which is less than 100.", {
        hl: [1, 2, 3], ptrs: { l: 1, r: 3 }, tags: { 3: "60 < 100" },
      }),
      s("Look at the subarrays that end at the 6. One is the 6 alone.", {
        ok: [3], ptrs: { l: 1, r: 3 },
      }),
      s("Another starts one place earlier: 2, 6.", {
        ok: [2, 3], ptrs: { l: 1, r: 3 },
      }),
      s("And one more starts at the left edge of the window: 5, 2, 6.", {
        ok: [1, 2, 3], ptrs: { l: 1, r: 3 },
      }),
      s("How many valid subarrays end at the right edge, in terms of left and right?", {
        ok: [1, 2, 3], ptrs: { l: 1, r: 3 },
      }),
    ]),
    A([10, 5, 2, 6], [
      s("The window 10, 5, 2 has product 100, but we need a product less than 100.", {
        hl: [0, 1, 2], ptrs: { l: 0, r: 2 }, tags: { 2: "product 100" },
      }),
      s("The product is not less than k, so this window is not allowed.", {
        bad: [0, 1, 2], ptrs: { l: 0, r: 2 }, tags: { 2: "product 100" },
      }),
      s("The right edge cannot go back. What should we do to bring the product below 100?", {
        bad: [0, 1, 2], ptrs: { l: 0, r: 2 }, tags: { 2: "product 100" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Contains Duplicate II": [
    A([1, 2, 3, 1], [
      s("k = 2. We look for two equal numbers that are at most 2 positions apart.", {}),
      s("Stand on the last 1. Which earlier elements are close enough to matter?", {
        hl: [3],
      }),
      s("The 2 and the 3 are within 2 positions of it.", {
        ok: [1, 2], hl: [3], tags: { 1: "2 away", 2: "1 away" },
      }),
      s("The first 1 is 3 positions back, too far to count.", {
        ok: [1, 2], hl: [3], bad: [0], tags: { 0: "3 away", 1: "2 away", 2: "1 away" },
      }),
      s("Only the last k elements can matter. What does that suggest we keep as we move along?", {
        ok: [1, 2], hl: [3], bad: [0], tags: { 0: "3 away", 1: "2 away", 2: "1 away" },
      }),
    ]),
    A([1, 2, 3, 1], [
      s("k = 2. We keep a set of recent elements. After the first two, it holds 1 and 2.", {
        hl: [0, 1], aux: { label: "set", items: ["1", "2"] },
      }),
      s("Next we add the 3. The set would now hold three elements, more than k = 2.", {
        ok: [0, 1], hl: [2], aux: { label: "set", items: ["1", "2", "3"] },
      }),
      s("The set has 3 elements and k is 2. One of them is now too old.", {
        bad: [0], ok: [1], hl: [2], aux: { label: "set", items: ["1", "2", "3"] },
      }),
      s("Which element should we remove from the set?", {
        bad: [0], ok: [1], hl: [2], aux: { label: "set", items: ["1", "2", "3"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Jump Game II": [
    A([2, 3, 1, 1, 4], [
      s("From index 0 we can jump up to 2 steps.", {
        hl: [0],
      }),
      s("With 1 jump we can land on index 1 or index 2.", {
        hl: [0], ok: [1, 2],
      }),
      s("A second jump can start from any index we could have landed on.", {
        ok: [1, 2], tags: { 1: "value 3", 2: "value 1" },
      }),
      s("Counting from index 1 and from index 2, where could a second jump land?", {
        hl: [1, 2], tags: { 1: "value 3", 2: "value 1" },
      }),
    ]),
    A([2, 3, 1, 1, 4], [
      s("We scan the indexes reachable with 1 jump: first index 1, then index 2.", {
        ok: [0], hl: [1, 2], aux: { label: "we keep", items: [] },
      }),
      s("At index 1 the value is 3, so a jump from there could land as far as index 4.", {
        ok: [0], hl: [1], aux: { label: "we keep", items: ["4"] },
      }),
      s("At index 2 the value is 1, so a jump from there could land at index 3.", {
        ok: [0, 1], hl: [2], aux: { label: "we keep", items: ["4"] },
      }),
      s("The scan reached the end of this range. What single number did we keep while scanning it?", {
        ok: [0, 1, 2], aux: { label: "we keep", items: ["4"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Assign Cookies": [
    A([1, 2, 3], [
      s("The cookies have sizes 1, 2 and 3. The least greedy child is happy with any cookie of size 1 or more.", {
        aux: { label: "child", items: ["greed 1"] },
      }),
      s("All three cookies would satisfy this child.", {
        ok: [0, 1, 2], aux: { label: "child", items: ["greed 1"] },
      }),
      s("Greedier children, with greed 2 and 3, are waiting too.", {
        ok: [0, 1, 2], aux: { label: "waiting", items: ["greed 1", "greed 2", "greed 3"] },
      }),
      s("Which cookie should the least greedy child receive?", {
        hl: [0, 1, 2], aux: { label: "waiting", items: ["greed 1", "greed 2", "greed 3"] },
      }),
    ]),
    A([1, 3], [
      s("The cookies are 1 and 3. The children still waiting have greed 2 and 3.", {
        aux: { label: "waiting", items: ["greed 2", "greed 3"] },
      }),
      s("Try the cookie of size 1 on the least greedy waiting child, who has greed 2.", {
        hl: [0], aux: { label: "waiting", items: ["greed 2", "greed 3"] },
      }),
      s("It is too small for that child.", {
        bad: [0], aux: { label: "waiting", items: ["greed 2", "greed 3"] },
      }),
      s("The other waiting child is at least as greedy. What should we do with this cookie?", {
        bad: [0], aux: { label: "waiting", items: ["greed 2", "greed 3"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Lemonade Change": [
    A([5, 5, 5, 10], [
      s("Our drawer holds the bills 5, 5, 5 and 10. A customer pays with $20, so we owe $15.", {}),
      s("One way to give $15: three $5 bills.", {
        ok: [0, 1, 2],
      }),
      s("Another way: the $10 bill and one $5 bill.", {
        ok: [3, 0],
      }),
      s("Both make $15. Which change should we prefer to give?", {
        hl: [0, 1, 2, 3],
      }),
    ]),
    A([10, 20], [
      s("Two kinds of customers need change: one paying $10 and one paying $20.", {
        tags: { 0: "pays 10", 1: "pays 20" },
      }),
      s("The customer paying $10 needs $5 back.", {
        hl: [0], tags: { 0: "needs $5", 1: "pays 20" },
      }),
      s("The customer paying $20 needs $15 back.", {
        hl: [1], tags: { 0: "needs $5", 1: "needs $15" },
      }),
      s("Which of our bills, $5 or $10, can help each customer? Which one is more valuable to keep?", {
        hl: [0, 1], tags: { 0: "needs $5", 1: "needs $15" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Reverse Bits": [
    A([0, 0, 1, 1], [
      s("We reverse the 4 bits of n = 0011. The last bit should come out first.", {}),
      s("Read the last bit of n. It is 1.", {
        hl: [3], aux: { label: "read", items: ["1"] },
      }),
      s("Drop that bit from n to expose the next one.", {
        values: [0, 0, 0, 1], hl: [3], aux: { label: "read", items: ["1"] },
      }),
      s("The next bit to read is again at the right end. It is 1.", {
        values: [0, 0, 0, 1], hl: [3], aux: { label: "read", items: ["1", "1"] },
      }),
      s("Which two operations read the last bit and then drop it?", {
        values: [0, 0, 0, 1], aux: { label: "read", items: ["1", "1"] },
      }),
    ]),
    A([0, 0, 0, 0], [
      s("The result starts as 0000. We read the bits 1, 1, 0, 0 from n, one after another.", {
        aux: { label: "bit read", items: [] },
      }),
      s("First bit read: 1. The result becomes 0001.", {
        values: [0, 0, 0, 1], hl: [3], aux: { label: "bit read", items: ["1"] },
      }),
      s("Second bit read: 1. The result becomes 0011.", {
        values: [0, 0, 1, 1], hl: [3], aux: { label: "bit read", items: ["1"] },
      }),
      s("Third bit read: 0. The result becomes 0110.", {
        values: [0, 1, 1, 0], hl: [3], aux: { label: "bit read", items: ["0"] },
      }),
      s("Fourth bit read: 0. The result becomes 1100. What did we do to the old bits before adding a new one?", {
        values: [1, 1, 0, 0], hl: [3], aux: { label: "bit read", items: ["0"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Sum of Two Integers": [
    A(["_", "_", "_"], [
      s("Add a = 1 (001) and b = 3 (011) one bit column at a time. Here are the columns.", {
        tags: { 0: "0 + 0", 1: "0 + 1", 2: "1 + 1" },
      }),
      s("XOR each column: 0 and 0 give 0, 0 and 1 give 1, 1 and 1 give 0.", {
        values: [0, 1, 0], ok: [0, 1, 2], tags: { 0: "0 + 0", 1: "0 + 1", 2: "1 + 1" },
      }),
      s("The true sum 1 + 3 is 4, which is 100 in binary. XOR gave 010. How do a XOR b and a + b compare?", {
        values: [0, 1, 0], hl: [0, 1, 2], out: "1 + 3 = 4 (100)",
      }),
    ]),
    A([0, 1, 2], [
      s("Add the columns of 001 and 011. The column sums are 0, 1 and 2.", {
        tags: { 0: "0 + 0", 1: "0 + 1", 2: "1 + 1" },
      }),
      s("A binary digit can only be 0 or 1. Look at the column with the sum 2.", {
        bad: [2], tags: { 0: "0 + 0", 1: "0 + 1", 2: "1 + 1" },
      }),
      s("When does a column produce a carry, and where does the carry go?", {
        bad: [2], hl: [1], tags: { 0: "0 + 0", 1: "0 + 1", 2: "1 + 1" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Range Sum Query - Immutable": [
    A([1, 2, 3, 4], [
      s("The prefix sums of 1, 2, 3, 4 are 0, 1, 3, 6, 10.", {
        aux: { label: "prefix", items: ["0", "1", "3", "6", "10"] },
      }),
      s("We want the sum of the elements from index 1 to index 2, which is 2 + 3.", {
        hl: [1, 2], aux: { label: "prefix", items: ["0", "1", "3", "6", "10"] },
      }),
      s("The prefix before index 1 is 1, and the prefix through index 2 is 6.", {
        hl: [1, 2], tags: { 1: "before: 1", 2: "through: 6" },
        aux: { label: "prefix", items: ["0", "1", "3", "6", "10"] },
      }),
      s("How can we get the sum of 2 and 3 from the prefix sums 1 and 6?", {
        hl: [1, 2], tags: { 1: "before: 1", 2: "through: 6" },
        aux: { label: "prefix", items: ["0", "1", "3", "6", "10"] },
      }),
    ]),
    A([1, 2, 3, 4], [
      s("Many queries ask for sums over ranges of the same array.", {}),
      s("Query 1: add up indexes 1 to 3. We touch 3 numbers.", {
        hl: [1, 2, 3], out: "numbers touched: 3",
      }),
      s("Query 2: add up indexes 0 to 3. We touch all 4 numbers.", {
        hl: [0, 1, 2, 3], out: "numbers touched: 7",
      }),
      s("Query 3: indexes 1 to 2. Each query repeats many of the same additions.", {
        hl: [1, 2], out: "numbers touched: 9",
      }),
      s("What could we compute once, up front, so that every query takes the same tiny amount of work?", {
        out: "numbers touched: 9",
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Subarray Sums Divisible by K": [
    A([4, 5, 0, 1], [
      s("k = 5. After each number we show the prefix sum and its remainder mod 5.", {
        tags: { 0: "4 → r4", 1: "9 → r4", 2: "9 → r4", 3: "10 → r0" },
      }),
      s("The prefix sums after the 4 and after the 5 are 4 and 9. Both leave remainder 4.", {
        hl: [0, 1], tags: { 0: "4 → r4", 1: "9 → r4", 2: "9 → r4", 3: "10 → r0" },
      }),
      s("The stretch between those two places is just the 5.", {
        ok: [1], hl: [0], tags: { 0: "4 → r4", 1: "9 → r4", 2: "9 → r4", 3: "10 → r0" },
      }),
      s("Two prefix sums share the same remainder. What does that say about the stretch between them?", {
        ok: [1], hl: [0], tags: { 0: "4 → r4", 1: "9 → r4", 2: "9 → r4", 3: "10 → r0" },
      }),
    ]),
    A([-1, 5], [
      s("k = 5. The array is -1, 5. The prefix sums are -1 and 4.", {
        tags: { 0: "prefix -1", 1: "prefix 4" },
      }),
      s("The stretch between them is 5, which is divisible by 5.", {
        hl: [1], tags: { 0: "prefix -1", 1: "prefix 4" },
      }),
      s("In some languages -1 % 5 gives -1, not 4. Then the two remainders look different.", {
        hl: [0, 1], tags: { 0: "prefix -1", 1: "prefix 4" }, aux: { label: "remainders", items: ["-1", "4"] },
      }),
      s("The two prefix sums should match, but the remainders -1 and 4 do not. What should we do?", {
        bad: [0, 1], tags: { 0: "prefix -1", 1: "prefix 4" }, aux: { label: "remainders", items: ["-1", "4"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Search a 2D Matrix": [
    G(M34, [
      s("Each row is sorted, and each row starts after the previous row ends.", {}),
      s("The first row ends with 7.", {
        hl: [[0, 3]],
      }),
      s("The next row starts with 10, which is bigger.", {
        hl: [[0, 3], [1, 0]],
      }),
      s("The second row ends with 20 and the third starts with 23. The same thing happens.", {
        hl: [[1, 3], [2, 0]],
      }),
      s("Read the cells row by row, left to right. What kind of list do you get?", {
        out: "1, 3, 5, 7, 10, 11, 16, 20, 23, 30, 34, 60",
      }),
    ]),
    G(M34, [
      s("Number the cells 0, 1, 2, ... going row by row. This number is the flat index.", {
        tags: FLAT_TAGS,
      }),
      s("Take the flat index 6. Which row and which column holds it?", {
        hl: [[1, 2]], tags: FLAT_TAGS,
      }),
      s("Index 4 is the first cell of the second row, and index 8 is the first cell of the third row.", {
        hl: [[1, 0], [2, 0]], tags: FLAT_TAGS,
      }),
      s("The matrix has n = 4 columns. How can the row and column be computed from a flat index mid?", {
        tags: FLAT_TAGS,
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "K Closest Points to Origin": [
    A(["P", "Q"], [
      s("Two points: P at (1, 3) and Q at (-2, 2). Which one is closer to the origin?", {
        tags: { 0: "(1,3)", 1: "(-2,2)" },
      }),
      s("The real distance of P is about 3.16.", {
        hl: [0], tags: { 0: "(1,3)", 1: "(-2,2)" }, aux: { label: "distance", items: ["P: 3.16"] },
      }),
      s("The real distance of Q is about 2.83, so Q is closer.", {
        hl: [1], tags: { 0: "(1,3)", 1: "(-2,2)" }, aux: { label: "distance", items: ["P: 3.16", "Q: 2.83"] },
      }),
      s("Square roots are slow. What simpler number could we compare to get the same winner?", {
        tags: { 0: "(1,3)", 1: "(-2,2)" }, aux: { label: "distance", items: ["P: 3.16", "Q: 2.83"] },
      }),
    ]),
    T([9, 4, 7], [
      s("The heap holds the 3 closest points so far, as squared distances. The farthest, 9, is on top.", {
        hl: [0], tags: { 0: "farthest" },
      }),
      s("A new point arrives with squared distance 2.", {
        hl: [0], tags: { 0: "farthest" }, out: "new point: 2",
      }),
      s("2 is less than 9, so the new point is closer than the farthest of our points.", {
        hl: [0], tags: { 0: "farthest" }, out: "new point: 2",
      }),
      s("The heap must hold exactly 3 points. What should we do with the new point and the top?", {
        hl: [0], tags: { 0: "farthest" }, out: "new point: 2",
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Task Scheduler": [
    A(["A", "A", "A", "B", "C"], [
      s("The tasks are A, A, A, B, C. Two time units must pass between two runs of the same task.", {}),
      s("Count how often each task appears.", {
        aux: { label: "counts", items: ["A:3", "B:1", "C:1"] },
      }),
      s("Each repeat of a task needs two other time units between it and the run before.", {
        hl: [0, 1, 2], aux: { label: "counts", items: ["A:3", "B:1", "C:1"] },
      }),
      s("Which task will force the most waiting between its runs?", {
        aux: { label: "counts", items: ["A:3", "B:1", "C:1"] },
      }),
    ]),
    A(["_", "_", "_", "_", "_", "_", "_", "_", "_"], [
      s("Place the first A. Then two time units must pass before the next A.", {
        values: ["A", "_", "_", "_", "_", "_", "_", "_", "_"], hl: [0],
      }),
      s("The next A can go in slot 3. That makes a block of 3 slots: an A and two waiting slots.", {
        values: ["A", "_", "_", "A", "_", "_", "_", "_", "_"], ok: [0, 1, 2], hl: [3],
      }),
      s("The third A goes in slot 6.", {
        values: ["A", "_", "_", "A", "_", "_", "A", "_", "_"], ok: [0, 1, 2, 3, 4, 5], hl: [6],
      }),
      s("With f = 3 runs of A and a gap of n = 2, how many slots do we need up to the last A?", {
        values: ["A", "_", "_", "A", "_", "_", "A", "_", "_"], ok: [0, 1, 2, 3, 4, 5], hl: [6],
      }),
    ]),
  ],

  // ===============================================================
  // BATCH 18: Intervals, Tries, Union Find (written from the real challenges)
  // Tries and union-find are drawn with the graph renderer.
  // ===============================================================

  // ---------------------------------------------------------------
  "Insert Interval": [
    I([[1, 2], [3, 5], [6, 7], [8, 10], [12, 16], [4, 8]], [
      s("The list is sorted by start. The new interval, [4, 8], is the bottom bar.", {
        hl: [5], tags: { 5: "new" },
      }),
      s("Draw a line where the new interval starts, at 4.", {
        hl: [5], marker: 4, markerLabel: "new starts", tags: { 5: "new" },
      }),
      s("And one where it ends, at 8.", {
        hl: [5], marker: 8, markerLabel: "new ends", tags: { 5: "new" },
      }),
      s("Look at where each existing interval sits against these lines. How are they related to the new one?", {
        hl: [5], marker: 8, markerLabel: "new ends", tags: { 5: "new" },
      }),
    ], { range: [0, 17] }),
    I([[3, 5], [4, 8]], [
      s("The existing interval [3, 5] overlaps the new interval [4, 8].", {
        hl: [0, 1], tags: { 0: "[3, 5]", 1: "[4, 8]" },
      }),
      s("We want one single interval that covers both of them.", {
        hl: [0, 1], tags: { 0: "[3, 5]", 1: "[4, 8]" },
      }),
      s("Which start and which end should the merged interval use?", {
        hl: [0, 1], tags: { 0: "[3, 5]", 1: "[4, 8]" },
      }),
    ], { range: [0, 10] }),
  ],

  // ---------------------------------------------------------------
  "Non-overlapping Intervals": [
    I([[1, 3], [2, 6], [4, 5]], [
      s("The intervals [1, 3] and [2, 6] overlap, so we must drop one of them.", {
        hl: [0, 1],
      }),
      s("A third interval, [4, 5], is waiting after them.", {
        hl: [2],
      }),
      s("If we keep [2, 6], then [4, 5] overlaps it too.", {
        ok: [1], bad: [2], marker: 6, markerLabel: "ends 6",
      }),
      s("Which of the first two should we keep, to leave the most room for the intervals that follow?", {
        hl: [0, 1],
      }),
    ], { range: [0, 7] }),
    I([[1, 2], [2, 3], [1, 3], [3, 4]], [
      s("The intervals are sorted by end time. We keep [1, 2] first. Its end is 2.", {
        ok: [0], marker: 2, markerLabel: "kept end 2",
      }),
      s("Next is [2, 3]. It starts at 2, just when the last kept interval ends.", {
        ok: [0], hl: [1], marker: 2, markerLabel: "kept end 2",
      }),
      s("We keep it. The last kept end is now 3.", {
        ok: [0, 1], marker: 3, markerLabel: "kept end 3",
      }),
      s("Next is [1, 3]. It starts at 1, before the last kept end.", {
        ok: [0, 1], hl: [2], marker: 3, markerLabel: "kept end 3",
      }),
      s("When should we keep the next interval, and when should we skip it?", {
        ok: [0, 1], hl: [2, 3], marker: 3, markerLabel: "kept end 3",
      }),
    ], { range: [0, 5] }),
  ],

  // ---------------------------------------------------------------
  "Meeting Rooms II": [
    I([[0, 6], [1, 3], [2, 5], [4, 8]], [
      s("Four meetings, drawn on a timeline.", {}),
      s("At time 2, three meetings are running: [0, 6], [1, 3] and [2, 5].", {
        hl: [0, 1, 2], marker: 2, markerLabel: "time 2",
      }),
      s("At time 7, only one meeting is running: [4, 8].", {
        hl: [3], marker: 7, markerLabel: "time 7",
      }),
      s("Meetings that run at the same moment each need a room. What number tells us how many rooms we need?", {
        hl: [0, 1, 2], marker: 2, markerLabel: "time 2",
      }),
    ], { range: [0, 9] }),
    I([[0, 6], [1, 3], [4, 8]], [
      s("Meetings in start order. [0, 6] and [1, 3] overlap, so they use two rooms.", {
        hl: [0, 1],
      }),
      s("The next meeting is [4, 8]. It starts at time 4.", {
        hl: [2], marker: 4, markerLabel: "start 4",
      }),
      s("At time 4, the meeting [1, 3] has ended but [0, 6] is still running.", {
        ok: [1], hl: [0, 2], marker: 4, markerLabel: "start 4", tags: { 0: "until 6", 1: "until 3" },
      }),
      s("When can the new meeting reuse a room that was already in use?", {
        hl: [2], marker: 4, markerLabel: "start 4", tags: { 0: "until 6", 1: "until 3" },
      }),
    ], { range: [0, 9] }),
  ],

  // ---------------------------------------------------------------
  "Minimum Number of Arrows to Burst Balloons": [
    I([[1, 6], [2, 8], [7, 12], [10, 16]], [
      s("Balloons are bars on a line, sorted by where they end. An arrow at x bursts every balloon covering x.", {}),
      s("The first balloon, [1, 6], must be burst by an arrow somewhere between 1 and 6.", {
        hl: [0],
      }),
      s("An arrow at 1 bursts this balloon, but no other balloon covers 1.", {
        ok: [0], marker: 1, markerLabel: "x = 1",
      }),
      s("Where along [1, 6] is the best place to shoot, to burst as many other balloons as possible?", {
        hl: [0],
      }),
    ], { range: [0, 17] }),
    I([[1, 6], [2, 8], [7, 12], [10, 16]], [
      s("The first arrow is at 6. It bursts [1, 6] and [2, 8].", {
        ok: [0, 1], marker: 6, markerLabel: "arrow 6",
      }),
      s("The next balloon is [7, 12]. The arrow at 6 does not touch it.", {
        ok: [0, 1], hl: [2], marker: 6, markerLabel: "arrow 6",
      }),
      s("The balloon starts after the arrow's position, so it is still floating.", {
        ok: [0, 1], bad: [2], marker: 6, markerLabel: "arrow 6",
      }),
      s("What should we do about this balloon?", {
        ok: [0, 1], bad: [2], marker: 6, markerLabel: "arrow 6",
      }),
    ], { range: [0, 17] }),
  ],

  // ---------------------------------------------------------------
  "Interval List Intersections": [
    I([[0, 2], [1, 5]], [
      s("Two intervals, [0, 2] and [1, 5]. Where do they overlap?", {
        tags: { 0: "first", 1: "second" },
      }),
      s("Their overlap is the interval [1, 2].", {
        intervals: [[0, 2], [1, 5], [1, 2]], ok: [2], tags: { 0: "first", 1: "second", 2: "overlap" },
      }),
      s("Another pair: [5, 10] and [1, 5] overlap in [5, 5], a single point.", {
        intervals: [[5, 10], [1, 5], [5, 5]], ok: [2], tags: { 0: "first", 1: "second", 2: "overlap" },
      }),
      s("How are the start and end of an overlap found from the starts and ends of the two intervals?", {
        intervals: [[0, 2], [1, 5], [1, 2]], ok: [2], tags: { 0: "first", 1: "second", 2: "overlap" },
      }),
    ], { range: [0, 11] }),
    I([[0, 2], [5, 10], [1, 5], [8, 12]], [
      s("Two sorted lists. A has [0, 2] and [5, 10], and B has [1, 5] and [8, 12].", {
        tags: { 0: "A first", 1: "A second", 2: "B first", 3: "B second" },
      }),
      s("We compare the first interval of A with the first interval of B. They overlap in [1, 2].", {
        hl: [0, 2], tags: { 0: "A first", 2: "B first" },
      }),
      s("The interval from A ends at 2, and the interval from B ends at 5.", {
        hl: [0, 2], tags: { 0: "ends 2", 2: "ends 5" },
      }),
      s("After handling this pair, which list should move on to its next interval?", {
        hl: [0, 2], tags: { 0: "ends 2", 2: "ends 5" },
      }),
    ], { range: [0, 13] }),
  ],

  // ---------------------------------------------------------------
  "Implement Trie (Prefix Tree)": [
    GR(TRIE_CAT.nodes, TRIE_CAT.edges, [
      s("A trie that stores cat and car. Words that start the same share the same path.", {}),
      s("Follow the path from the top: c, then a, then t spells cat.", {
        hl: [1, 2, 3], hlE: [[0, 1], [1, 2], [2, 3]],
      }),
      s("The path c, a, r spells car. The first two steps are shared.", {
        hl: [1, 2, 4], hlE: [[0, 1], [1, 2], [2, 4]],
      }),
      s("What does each single step down from a node in the trie stand for?", {
        hl: [1, 2, 3, 4], okE: [[0, 1], [1, 2], [2, 3], [2, 4]],
      }),
    ], { pos: TRIE_CAT.pos, directed: true, height: 230 }),
    GR(TRIE_APPLE.nodes, TRIE_APPLE.edges, [
      s("A trie holding only the word apple. The last letter, e, is marked as the end of a word.", {
        tags: { 5: "word end" },
      }),
      s("Check the path a, p, p. It exists in the trie.", {
        hl: [1, 2, 3], hlE: [[0, 1], [1, 2], [2, 3]], tags: { 5: "word end" },
      }),
      s("The node after the second p carries no end mark.", {
        hl: [3], tags: { 3: "no end mark", 5: "word end" },
      }),
      s("Is app a stored word, or only the start of one? How do search and startsWith differ?", {
        hl: [3], tags: { 3: "no end mark", 5: "word end" },
      }),
    ], { pos: TRIE_APPLE.pos, directed: true, height: 170 }),
  ],

  // ---------------------------------------------------------------
  "Design Add and Search Words Data Structure": [
    GR(TRIE_BDM.nodes, TRIE_BDM.edges, [
      s("The trie stores bad, dad and mad. We search for the pattern bad.", {}),
      s("The first letter is b. Look at where b leads from the top.", {
        hl: [1], hlE: [[0, 1]],
      }),
      s("Then a, then d.", {
        hl: [1, 4, 7], hlE: [[0, 1], [1, 4], [4, 7]],
      }),
      s("At each letter, which children of the current node does the search need to look at?", {
        ok: [1, 4, 7], okE: [[0, 1], [1, 4], [4, 7]],
      }),
    ], { pos: TRIE_BDM.pos, directed: true, height: 260 }),
    GR(TRIE_BDM.nodes, TRIE_BDM.edges, [
      s("Now search the pattern .ad. The dot can stand for any letter.", {}),
      s("The first character is a dot. The top node has three children: b, d and m.", {
        hl: [0],
      }),
      s("What should the search do at a dot?", {
        hl: [0], hlE: [[0, 1], [0, 2], [0, 3]],
      }),
    ], { pos: TRIE_BDM.pos, directed: true, height: 260 }),
  ],

  // ---------------------------------------------------------------
  "Replace Words": [
    GR(TRIE_ROOTS.nodes, TRIE_ROOTS.edges, [
      s("The roots ca and cat are stored in a trie. The word to replace is cattle.", {
        tags: { 2: "root: ca", 3: "root: cat" },
      }),
      s("cattle starts with ca.", {
        hl: [1, 2], hlE: [[0, 1], [1, 2]], tags: { 2: "root: ca", 3: "root: cat" },
      }),
      s("It also starts with cat.", {
        hl: [1, 2, 3], hlE: [[0, 1], [1, 2], [2, 3]], tags: { 2: "root: ca", 3: "root: cat" },
      }),
      s("Two roots match the same word. Which one should replace it?", {
        hl: [2, 3], tags: { 2: "root: ca", 3: "root: cat" },
      }),
    ], { pos: TRIE_ROOTS.pos, directed: true, height: 170 }),
    GR(TRIE_ROOTS.nodes, TRIE_ROOTS.edges, [
      s("We walk cattle down the trie one letter at a time, starting with c.", {
        hl: [1], hlE: [[0, 1]], tags: { 2: "root: ca", 3: "root: cat" },
      }),
      s("Then a. This node is marked as the end of a root.", {
        ok: [1], hl: [2], hlE: [[1, 2]], tags: { 2: "root: ca", 3: "root: cat" },
      }),
      s("The walk could go on with t and reach the end of another root.", {
        ok: [1, 2], hl: [3], hlE: [[2, 3]], tags: { 2: "root: ca", 3: "root: cat" },
      }),
      s("We want the shortest root. At which point of the walk can we stop?", {
        ok: [1, 2], tags: { 2: "root: ca", 3: "root: cat" },
      }),
    ], { pos: TRIE_ROOTS.pos, directed: true, height: 170 }),
  ],

  // ---------------------------------------------------------------
  "Number of Connected Components in an Undirected Graph": [
    GR(UF_FIVE.nodes, UF_FIVE.edges, [
      s("Every node starts as its own component. There are 5 components.", {
        aux: { label: "components", items: ["5"] },
      }),
      s("Process the edge between 0 and 1. They are in different components.", {
        hl: [0, 1], hlE: [[0, 1]], aux: { label: "components", items: ["5"] },
      }),
      s("Nodes 0 and 1 now belong to one component. What happens to the number of components?", {
        ok: [0, 1], okE: [[0, 1]], aux: { label: "components", items: ["?"] },
      }),
    ], { pos: UF_FIVE.pos, height: 190 }),
    GR(UF_TRIANGLE.nodes, UF_TRIANGLE.edges, [
      s("The edges 0-1 and 1-2 are processed. Nodes 0, 1 and 2 are in one component.", {
        ok: [0, 1, 2], okE: [[0, 1], [1, 2]], aux: { label: "components", items: ["1"] },
      }),
      s("Now the edge between 0 and 2 arrives.", {
        ok: [1], hl: [0, 2], hlE: [[0, 2]], okE: [[0, 1], [1, 2]], aux: { label: "components", items: ["1"] },
      }),
      s("Nodes 0 and 2 are already in the same component.", {
        ok: [1], hl: [0, 2], hlE: [[0, 2]], okE: [[0, 1], [1, 2]], aux: { label: "components", items: ["1"] },
      }),
      s("What happens to the number of components when this edge is processed?", {
        ok: [1], hl: [0, 2], hlE: [[0, 2]], okE: [[0, 1], [1, 2]], aux: { label: "components", items: ["1"] },
      }),
    ], { pos: UF_TRIANGLE.pos, height: 210 }),
  ],

  // ---------------------------------------------------------------
  "Redundant Connection": [
    GR(TREE_FOUR.nodes, TREE_FOUR.edges, [
      s("A tree on 4 nodes: four circles joined together with no cycle.", {
        out: "nodes: 4",
      }),
      s("Count the edges that hold it together.", {
        hlE: [[0, 1], [1, 2], [2, 3]], out: "nodes: 4, edges: 3",
      }),
      s("For n nodes, how many edges does a tree have?", {
        okE: [[0, 1], [1, 2], [2, 3]], out: "nodes: 4, edges: 3",
      }),
    ], { pos: TREE_FOUR.pos, height: 170 }),
    GR(RC_TRIANGLE.nodes, RC_TRIANGLE.edges, [
      s("Add the edge between 1 and 2.", {
        hl: [0, 1], hlE: [[0, 1]],
      }),
      s("Add the edge between 1 and 3. Nodes 1, 2 and 3 are now all connected.", {
        ok: [0, 1, 2], okE: [[0, 1], [0, 2]],
      }),
      s("Now the edge between 2 and 3 arrives.", {
        ok: [0], hl: [1, 2], okE: [[0, 1], [0, 2]], hlE: [[1, 2]],
      }),
      s("Nodes 2 and 3 are already connected through node 1. When is an edge the redundant one?", {
        ok: [0], hl: [1, 2], okE: [[0, 1], [0, 2]], hlE: [[1, 2]],
      }),
    ], { pos: RC_TRIANGLE.pos, height: 210 }),
  ],

  // ===============================================================
  // BATCH 19: Searching, Monotonic Stack, Dynamic Programming
  // (written from the real challenges)
  // ===============================================================

  // ---------------------------------------------------------------
  "Find Peak Element": [
    A([1, 2, 1, 3, 5, 6, 4], [
      s("We want any peak, a number bigger than both of its neighbours. Check the middle, at index 3.", {
        hl: [3], ptrs: { lo: 0, mid: 3, hi: 6 },
      }),
      s("The middle holds 3 and the next number is 5. The array slopes upward at this point.", {
        hl: [3, 4], ptrs: { lo: 0, mid: 3, hi: 6 },
      }),
      s("Given this upward slope at the middle, where must a peak exist?", {
        hl: [3, 4], ptrs: { lo: 0, mid: 3, hi: 6 },
      }),
    ]),
    A([1, 2, 1, 3, 5, 6, 4], [
      s("We keep the right half, from index 4 to the end: 5, 6, 4.", {
        ok: [4, 5, 6], ptrs: { lo: 4, hi: 6 },
      }),
      s("Beyond the last index we imagine negative infinity, lower than any number.", {
        ok: [4, 5, 6], ptrs: { lo: 4, hi: 6 }, tags: { 6: "then -inf" },
      }),
      s("Coming from the middle, the numbers rise from 3 to 5.", {
        hl: [3, 4], ok: [5, 6], ptrs: { lo: 4, hi: 6 }, tags: { 6: "then -inf" },
      }),
      s("Why must the half we keep contain a peak?", {
        hl: [3, 4], ok: [5, 6], ptrs: { lo: 4, hi: 6 }, tags: { 6: "then -inf" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Capacity To Ship Packages Within D Days": [
    A([3, 2, 2, 4, 1, 4], [
      s("The packages weigh 3, 2, 2, 4, 1 and 4. We want the smallest ship capacity that works.", {}),
      s("Try a capacity of 3. The first package, 3, fits.", {
        ok: [0], aux: { label: "capacity", items: ["3"] },
      }),
      s("The package of weight 4 does not fit on a ship with capacity 3.", {
        ok: [0], bad: [3], aux: { label: "capacity", items: ["3"] },
      }),
      s("So some capacities are too small to work at all. What is the smallest capacity that could possibly work?", {
        bad: [3], aux: { label: "capacity", items: ["3"] },
      }),
    ]),
    A([3, 2, 2, 4, 1, 4], [
      s("With capacity 6 the loads are (3,2), (2,4) and (1,4). That is 3 days.", {
        ok: [0, 1, 2, 3, 4, 5], tags: { 0: "day 1", 2: "day 2", 4: "day 3" }, out: "capacity 6: 3 days",
      }),
      s("With capacity 7 the loads are (3,2,2), (4,1) and (4). Again 3 days.", {
        ok: [0, 1, 2, 3, 4, 5], tags: { 0: "day 1", 3: "day 2", 5: "day 3" }, out: "capacity 7: 3 days",
      }),
      s("With capacity 10 the loads are (3,2,2) and (4,1,4). That is 2 days.", {
        ok: [0, 1, 2, 3, 4, 5], tags: { 0: "day 1", 3: "day 2" }, out: "capacity 10: 2 days",
      }),
      s("Compare the results. If a capacity ships everything within the days, what about a larger capacity?", {
        ok: [0, 1, 2, 3, 4, 5], tags: { 0: "day 1", 3: "day 2" }, out: "capacity 10: 2 days",
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Time Based Key-Value Store": [
    A(["-", "-", "-", "-"], [
      s("The key foo has no values stored yet. Each slot will hold a timestamp.", {}),
      s("set(foo, bar, 1) is called.", {
        values: [1, "-", "-", "-"], hl: [0], tags: { 0: "bar" },
      }),
      s("Later, set(foo, bar2, 4) is called.", {
        values: [1, 4, "-", "-"], ok: [0], hl: [1], tags: { 0: "bar", 1: "bar2" },
      }),
      s("Later still, set(foo, bar3, 7).", {
        values: [1, 4, 7, "-"], ok: [0, 1], hl: [2], tags: { 0: "bar", 1: "bar2", 2: "bar3" },
      }),
      s("In what order do the timestamps of one key arrive, and what does that mean for this list?", {
        values: [1, 4, 7, "-"], ok: [0, 1, 2], tags: { 0: "bar", 1: "bar2", 2: "bar3" },
      }),
    ]),
    A([1, 4, 7, 9], [
      s("The timestamps stored for foo are 1, 4, 7 and 9, in order. We call get(foo, 8).", {
        tags: { 0: "bar", 1: "bar2", 2: "bar3", 3: "bar4" },
      }),
      s("Scanning the whole list gets slower as the list grows. But the list is in order.", {
        hl: [0, 1, 2, 3], tags: { 0: "bar", 1: "bar2", 2: "bar3", 3: "bar4" },
      }),
      s("What fast search works on ordered data to find the largest timestamp that is at most 8?", {
        tags: { 0: "bar", 1: "bar2", 2: "bar3", 3: "bar4" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Online Stock Span": [
    A([100, 80, 60, 70], [
      s("The stack holds 100, 80 and 60, each with its span of 1. Today's price is 70.", {
        hl: [3], aux: { label: "stack", items: ["100:1", "80:1", "60:1"] },
      }),
      s("70 is higher than the price on top of the stack, 60.", {
        ok: [2], hl: [3], aux: { label: "stack", items: ["100:1", "80:1", "60:1"] },
      }),
      s("The 60 had a span of 1, covering only itself.", {
        ok: [2], hl: [3], aux: { label: "stack", items: ["100:1", "80:1", "60:1"] },
      }),
      s("Today's price is higher than the one on top. What does that tell us about today's span?", {
        ok: [2], hl: [3], aux: { label: "stack", items: ["100:1", "80:1", "60:1"] },
      }),
    ]),
    A([100, 80, 60, 70, 60, 75], [
      s("The stack holds (100, 1), (80, 1), (70, 2) and (60, 1). The 70 has a span of 2.", {
        hl: [3], aux: { label: "stack", items: ["100:1", "80:1", "70:2", "60:1"] },
      }),
      s("Today's price is 75.", {
        hl: [5], aux: { label: "stack", items: ["100:1", "80:1", "70:2", "60:1"] },
      }),
      s("The 70 on the stack stands for two days: the 60 before it, and itself.", {
        ok: [2, 3], hl: [5], tags: { 3: "span 2" }, aux: { label: "stack", items: ["100:1", "80:1", "70:2", "60:1"] },
      }),
      s("Why does each price on the stack carry its span?", {
        ok: [2, 3], hl: [5], tags: { 3: "span 2" }, aux: { label: "stack", items: ["100:1", "80:1", "70:2", "60:1"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Next Greater Element II": [
    A([1, 2, 1], [
      s("The array is circular: 1, 2, 1. We look for the next greater number after the last 1.", {
        hl: [2],
      }),
      s("After the last element there is nothing more on the right.", {
        hl: [2], tags: { 2: "last" },
      }),
      s("In a circular array, where does the scan go after the last element?", {
        hl: [2], tags: { 2: "last" },
      }),
    ]),
    A([1, 2, 1], [
      s("The scan goes from left to right. A stack keeps the numbers still waiting for a bigger one.", {
        ptrs: { i: 2 }, aux: { label: "waiting", items: ["2", "1"] },
      }),
      s("At the end of the scan, the last 1 never saw a bigger number after it. But the 2 sits before it.", {
        hl: [2], ok: [1], aux: { label: "waiting", items: ["2", "1"] },
      }),
      s("How can a single left-to-right scan with a stack let the last 1 find that 2?", {
        hl: [2], ok: [1], aux: { label: "waiting", items: ["2", "1"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Car Fleet": [
    A([1, 1, 7, 3, 12], [
      s("The cars are sorted from closest to the target. Each number is a car's time alone to reach it.", {
        tags: { 0: "pos 10", 1: "pos 8", 2: "pos 5", 3: "pos 3", 4: "pos 0" },
      }),
      s("The car at position 8 needs 1 hour. The car ahead of it, at position 10, also needs 1 hour.", {
        hl: [0, 1], tags: { 0: "pos 10", 1: "pos 8", 2: "pos 5", 3: "pos 3", 4: "pos 0" },
      }),
      s("The car at position 3 needs 3 hours. The car ahead of it, at position 5, needs 7 hours.", {
        hl: [2, 3], tags: { 0: "pos 10", 1: "pos 8", 2: "pos 5", 3: "pos 3", 4: "pos 0" },
      }),
      s("A car cannot pass the one ahead. When does a car end up in the same fleet as the car ahead of it?", {
        hl: [2, 3], tags: { 0: "pos 10", 1: "pos 8", 2: "pos 5", 3: "pos 3", 4: "pos 0" },
      }),
    ]),
    A([10, 8, 0, 5, 3], [
      s("The cars start at positions 10, 8, 0, 5 and 3, in the input order. The target is 12.", {
        tags: { 0: "speed 2", 1: "speed 4", 2: "speed 1", 3: "speed 1", 4: "speed 3" },
      }),
      s("Cars cannot pass each other, so the cars in front can hold a car back.", {
        hl: [0, 1], tags: { 0: "speed 2", 1: "speed 4", 2: "speed 1", 3: "speed 1", 4: "speed 3" },
      }),
      s("Sorted by position, the cars line up like this.", {
        values: [0, 3, 5, 8, 10], tags: { 0: "farthest", 4: "closest" },
      }),
      s("In which order should we go through the cars?", {
        values: [0, 3, 5, 8, 10], tags: { 0: "farthest", 4: "closest" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Remove K Digits": [
    A(["1", "4", "3", "2", "2", "1", "9"], [
      s("The number is 1432219, and we may remove 3 digits. We want the smallest result.", {}),
      s("Scanning from left to right: 1, then 4, then 3.", {
        ok: [0], hl: [1, 2],
      }),
      s("The 4 is bigger than the 3 that comes right after it.", {
        ok: [0], hl: [1, 2], tags: { 1: "4 > 3" },
      }),
      s("Which digit should we remove here, the 4 or the 3, to make the number smaller?", {
        ok: [0], hl: [1, 2], tags: { 1: "4 > 3" },
      }),
    ]),
    A(["1", "4", "3", "2", "2", "1", "9"], [
      s("Remove the 4. The number becomes 132219.", {
        values: ["1", "3", "2", "2", "1", "9", "-"], hl: [1],
      }),
      s("Remove the 3 instead. The number becomes 142219.", {
        values: ["1", "4", "2", "2", "1", "9", "-"], hl: [1],
      }),
      s("The two results differ only in the second digit: a 3 or a 4.", {
        values: ["1", "4", "2", "2", "1", "9", "-"], hl: [1], aux: { label: "results", items: ["132219", "142219"] },
      }),
      s("Which place decides which number is smaller, and why does that make removing the bigger digit pay off?", {
        values: ["1", "4", "2", "2", "1", "9", "-"], hl: [1], aux: { label: "results", items: ["132219", "142219"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "House Robber II": [
    A([2, 3, 2], [
      s("The houses are in a circle, so the last house sits next to the first one.", {
        hl: [0, 2], tags: { 0: "first", 2: "last" },
      }),
      s("Two houses that are next to each other cannot both be robbed.", {
        hl: [0, 1, 2], tags: { 0: "first", 2: "last" },
      }),
      s("The first and last houses are now neighbours. What does that mean for the robber?", {
        hl: [0, 2], tags: { 0: "first", 2: "last" },
      }),
    ]),
    A([2, 3, 2], [
      s("The first and last houses are neighbours, so they cannot both be robbed.", {
        hl: [0, 2], tags: { 0: "first", 2: "last" },
      }),
      s("So at least one of them is left out. Suppose we leave out the last house.", {
        ok: [0, 1], bad: [2], tags: { 0: "first", 2: "last" },
      }),
      s("What if we leave out the first house instead?", {
        bad: [0], ok: [1, 2], tags: { 0: "first", 2: "last" },
      }),
      s("In each case the houses form a straight line. How can we turn the circle into ordinary House Robber problems?", {
        hl: [0, 1, 2], tags: { 0: "first", 2: "last" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Minimum Path Sum": [
    G([[1, 3, 1], [1, 5, 1], [4, 2, 1]], [
      s("We want the cheapest way to reach each cell, moving only right or down.", {}),
      s("The cheapest cost to reach the cell on the left of the center is 2, which is 1 + 1.", {
        hl: [[1, 0]], tags: { "1,0": "cost 2" },
      }),
      s("The cheapest cost to reach the cell above the center is 4, which is 1 + 3.", {
        hl: [[0, 1]], ok: [[1, 0]], tags: { "1,0": "cost 2", "0,1": "cost 4" },
      }),
      s("The center cell holds 5. What makes up the cheapest cost to reach it?", {
        hl: [[1, 1]], ok: [[1, 0], [0, 1]], tags: { "1,0": "cost 2", "0,1": "cost 4" },
      }),
    ]),
    G([[1, 3, 1], [1, 5, 1], [4, 2, 1]], [
      s("Look at the first row: 1, 3, 1.", {
        hl: [[0, 0], [0, 1], [0, 2]],
      }),
      s("The first cell costs 1 to reach.", {
        ok: [[0, 0]], tags: { "0,0": "cost 1" },
      }),
      s("The next cell, 3, can only be reached from its left neighbour. It costs 4.", {
        ok: [[0, 0]], hl: [[0, 1]], tags: { "0,0": "cost 1", "0,1": "cost 4" },
      }),
      s("What does it cost to reach the last cell of the first row, the one holding 1?", {
        ok: [[0, 0], [0, 1]], hl: [[0, 2]], tags: { "0,0": "cost 1", "0,1": "cost 4" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Palindromic Substrings": [
    A(["a", "b", "a"], [
      s("A palindrome reads the same in both directions. It has a center in the middle.", {}),
      s("The palindrome aba has its center on the letter b.", {
        hl: [1], ok: [0, 2],
      }),
      s("In a different string, aab, the palindrome aa has its center between its two letters.", {
        values: ["a", "a", "b"], hl: [0, 1],
      }),
      s("Which centers must we try, for a string of any length?", {
        values: ["a", "a", "b"], hl: [0, 1],
      }),
    ]),
    A(["a", "b", "c", "a"], [
      s("Start at the center, the letter b.", {
        hl: [1],
      }),
      s("Expand one step to each side. The outer letters are a and c.", {
        ok: [1], hl: [0, 2],
      }),
      s("They differ, so a, b, c is not a palindrome.", {
        ok: [1], bad: [0, 2],
      }),
      s("From a center, when should we stop expanding?", {
        ok: [1], bad: [0, 2],
      }),
    ]),
  ],

  // ===============================================================
  // BATCH 20: Graphs, Trees, Recursion & Backtracking (written from the real challenges)
  // ===============================================================

  // ---------------------------------------------------------------
  "Max Area of Island": [
    G(MAI_GRID, [
      s("Land is 1 and water is 0. We explore the island, starting from the top land cell.", {
        hl: [[0, 2]],
      }),
      s("Step down to the land cell below.", {
        ok: [[0, 2]], hl: [[1, 2]],
      }),
      s("From this cell, the land cell above is a neighbour too. We already counted it.", {
        ok: [[0, 2]], hl: [[1, 2]], tags: { "0,2": "counted" },
      }),
      s("How do we avoid counting a cell twice when the search keeps meeting cells it has already seen?", {
        ok: [[0, 2]], hl: [[1, 2]], tags: { "0,2": "counted" },
      }),
    ], { dim: zeros(MAI_GRID) }),
    G(MAI_GRID, [
      s("We count the cells the search reaches. The first land cell counts 1.", {
        ok: [[0, 2]], out: "area: 1",
      }),
      s("Down from it: one more cell.", {
        ok: [[0, 2], [1, 2]], out: "area: 2",
      }),
      s("Left, and left again: two more cells.", {
        ok: [[0, 2], [1, 2], [1, 1], [1, 0]], out: "area: 4",
      }),
      s("Down from the middle cell: one more.", {
        ok: [[0, 2], [1, 2], [1, 1], [1, 0], [2, 1]], out: "area: 5",
      }),
      s("Each cell adds itself plus whatever its neighbours reach. How is the area worked out in the DFS?", {
        ok: [[0, 2], [1, 2], [1, 1], [1, 0], [2, 1]], out: "area: 5",
      }),
    ], { dim: zeros(MAI_GRID) }),
  ],

  // ---------------------------------------------------------------
  "Surrounded Regions": [
    G(SR_BOARD, [
      s("A region of O cells is captured when X cells surround it completely.", {}),
      s("The three connected O cells in the middle are enclosed by X cells.", {
        hl: [[1, 1], [1, 2], [2, 2]],
      }),
      s("The O on the bottom edge touches the border of the board.", {
        hl: [[3, 1]],
      }),
      s("Which O cells can never be captured?", {
        hl: [[1, 1], [1, 2], [2, 2], [3, 1]],
      }),
    ], { dim: xs(SR_BOARD) }),
    G(SR_BOARD, [
      s("Search from the O cells on the border. There is one, at the bottom.", {
        hl: [[3, 1]],
      }),
      s("Mark it as safe. No other O is connected to it.", {
        ok: [[3, 1]],
      }),
      s("The other three O cells were not reached from the border.", {
        ok: [[3, 1]], hl: [[1, 1], [1, 2], [2, 2]],
      }),
      s("Why is it enough to search only from the border cells, instead of from every O?", {
        ok: [[3, 1]], hl: [[1, 1], [1, 2], [2, 2]],
      }),
    ], { dim: xs(SR_BOARD) }),
  ],

  // ---------------------------------------------------------------
  "Cheapest Flights Within K Stops": [
    GR(FLIGHTS.nodes, FLIGHTS.edges, [
      s("We want a trip from city 0 to city 3. Stops are the cities in between.", {
        hl: [0, 3], tags: { 0: "start", 3: "end" },
      }),
      s("The trip 0, 1, 3 stops once, at city 1.", {
        hl: [0, 1, 3], hlE: [[0, 1], [1, 3]], tags: { 0: "start", 1: "1 stop", 3: "end" },
      }),
      s("The trip 0, 1, 2, 3 stops twice, at cities 1 and 2.", {
        hl: [0, 1, 2, 3], hlE: [[0, 1], [1, 2], [2, 3]], tags: { 0: "start", 1: "stop", 2: "stop", 3: "end" },
      }),
      s("If a trip may make at most k stops, how many flights can it use?", {
        hl: [0, 3], tags: { 0: "start", 3: "end" },
      }),
    ], { pos: FLIGHTS.pos, directed: true, height: 230 }),
    GR(FLIGHTS.nodes, FLIGHTS.edges, [
      s("The price to reach city 0 is 0. The other cities are unknown.", {
        hl: [0], tags: { 0: "0" }, aux: { label: "round", items: ["0"] },
      }),
      s("Round 1: try every flight once from the known cities. City 1 costs 100.", {
        ok: [0], hl: [1], hlE: [[0, 1]], tags: { 0: "0", 1: "100" }, aux: { label: "round", items: ["1"] },
      }),
      s("Round 2: flights from city 1 give city 2 for 200 and city 3 for 700.", {
        ok: [0, 1], hl: [2, 3], hlE: [[1, 2], [1, 3]], tags: { 0: "0", 1: "100", 2: "200", 3: "700" },
        aux: { label: "round", items: ["2"] },
      }),
      s("Each round used one more flight than the round before. What does one round of relaxation represent?", {
        ok: [0, 1, 2, 3], tags: { 0: "0", 1: "100", 2: "200", 3: "700" }, aux: { label: "round", items: ["2"] },
      }),
    ], { pos: FLIGHTS.pos, directed: true, height: 230 }),
  ],

  // ---------------------------------------------------------------
  "Min Cost to Connect All Points": [
    GR(MST_POINTS.nodes, MST_POINTS.edges, [
      s("Five points. Each line shows the cost of connecting two of them.", {}),
      s("Every point must be connected, with exactly one path between any two points.", {
        hl: [0, 1, 2, 3, 4],
      }),
      s("The loop A, B, D, E and back to A gives two different paths between some points.", {
        badE: [[0, 1], [1, 3], [3, 4], [0, 4]],
      }),
      s("What do we call the cheapest set of connections that links all points and has no loops?", {
        hl: [0, 1, 2, 3, 4],
      }),
    ], { pos: MST_POINTS.pos, height: 230 }),
    GR(MST_POINTS.nodes, MST_POINTS.edges, [
      s("Start from point A. The tree contains only A.", {
        ok: [0], aux: { label: "tree", items: ["A"] },
      }),
      s("The edges leaving the tree are A-B (4) and A-E (7).", {
        ok: [0], hlE: [[0, 1], [0, 4]], aux: { label: "tree", items: ["A"] },
      }),
      s("The tree adds A-B and grows to hold A and B.", {
        ok: [0, 1], okE: [[0, 1]], aux: { label: "tree", items: ["A", "B"] },
      }),
      s("Now the edges leaving the tree are B-D (3), B-C (9) and A-E (7). Which connection do we add next?", {
        ok: [0, 1], okE: [[0, 1]], hlE: [[1, 3], [1, 2], [0, 4]], aux: { label: "tree", items: ["A", "B"] },
      }),
    ], { pos: MST_POINTS.pos, height: 230 }),
  ],

  // ---------------------------------------------------------------
  "Binary Tree Right Side View": [
    T([1, 2, 3, N, 5, N, 4], [
      s("Imagine standing on the right side of the tree, looking left.", {
        hl: [0],
      }),
      s("The second level has two nodes: 2 and 3.", {
        hl: [1, 2],
      }),
      s("The third level has two nodes: 5 and 4.", {
        hl: [4, 6],
      }),
      s("Which node of each level can you see from the right?", {
        hl: [0, 1, 2, 4, 6],
      }),
    ]),
    T([1, 2, 3, N, 5, N, 4], [
      s("Level order reads each level from left to right. Level 1 holds just the 1.", {
        hl: [0], aux: { label: "level", items: ["1"] },
      }),
      s("Level 2 holds 2 and 3, in that order.", {
        ok: [0], hl: [1, 2], aux: { label: "level", items: ["2", "3"] },
      }),
      s("Level 3 holds 5 and 4, in that order.", {
        ok: [0, 1, 2], hl: [4, 6], aux: { label: "level", items: ["5", "4"] },
      }),
      s("From each level's list, which node should we record for the right side view?", {
        ok: [0, 1, 2], hl: [4, 6], aux: { label: "level", items: ["5", "4"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Lowest Common Ancestor of a Binary Tree": [
    T([3, 5, 1, 6, 2, 0, 8, N, N, 7, 4], [
      s("We look for the lowest common ancestor of p = 5 and q = 1, starting from the root, 3.", {
        hl: [0], tags: { 1: "p", 2: "q" },
      }),
      s("The search of the left subtree finds p = 5 and returns it.", {
        ok: [1], tags: { 1: "p", 2: "q" },
      }),
      s("The search of the right subtree finds q = 1 and returns it.", {
        ok: [1, 2], tags: { 1: "p", 2: "q" },
      }),
      s("At the root, both searches returned a node. What does that mean?", {
        hl: [0], ok: [1, 2], tags: { 1: "p", 2: "q" },
      }),
    ]),
    T([3, 5, 1, 6, 2, 0, 8, N, N, 7, 4], [
      s("Now p = 7 and q = 4. We search the subtree of node 5.", {
        hl: [1], tags: { 9: "p", 10: "q" },
      }),
      s("Below node 5, the left child, 6, contains neither p nor q.", {
        hl: [1], bad: [3], tags: { 9: "p", 10: "q" },
      }),
      s("The right child, 2, has both p and q below it, so its search returns the node 2.", {
        hl: [1], bad: [3], ok: [4, 9, 10], tags: { 9: "p", 10: "q" },
      }),
      s("At node 5 the left search found nothing and the right search returned a node. What does node 5 return?", {
        hl: [1], bad: [3], ok: [4, 9, 10], tags: { 9: "p", 10: "q" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Count Good Nodes in Binary Tree": [
    T([3, 1, 4, 3, N, 1, 5], [
      s("A node is good if nothing larger is on the path from the root to it. Start at the root, 3.", {
        hl: [0], tags: { 0: "path: 3" },
      }),
      s("Go down to the child 1. To judge it, we need to know something about the path above it.", {
        ok: [0], hl: [1], tags: { 0: "path: 3" },
      }),
      s("And go down to the child 4.", {
        ok: [0], hl: [2], tags: { 0: "path: 3" },
      }),
      s("What do we need to pass down from a node to its children, so that they can be judged?", {
        ok: [0], hl: [1, 2], tags: { 0: "path: 3" },
      }),
    ]),
    T([3, 1, 4, 3, N, 1, 5], [
      s("Look at the 3 at the bottom left. The path to it is 3, 1, 3.", {
        hl: [3], tags: { 3: "path 3,1,3" },
      }),
      s("Now look at the 1 below the 4. The path to it is 3, 4, 1.", {
        hl: [5], tags: { 3: "path 3,1,3", 5: "path 3,4,1" },
      }),
      s("Compare each of these two nodes with the biggest value above it on its path.", {
        hl: [3, 5], tags: { 3: "path 3,1,3", 5: "path 3,4,1" },
      }),
      s("Which of the two nodes is good, and when exactly is a node good?", {
        hl: [3, 5], tags: { 3: "path 3,1,3", 5: "path 3,4,1" },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Subsets II": [
    A([2, 1, 2], [
      s("The array has duplicates: 2, 1, 2. We want every distinct subset exactly once.", {}),
      s("The two 2s are not next to each other, so spotting that they are equal takes extra work.", {
        hl: [0, 2],
      }),
      s("Sorted, the array reads 1, 2, 2.", {
        values: [1, 2, 2], hl: [1, 2],
      }),
      s("Why does sorting the array help us avoid duplicate subsets?", {
        values: [1, 2, 2], hl: [1, 2],
      }),
    ]),
    A([1, 2, 2], [
      s("We have chosen 1. Now we pick the next element to add, from the numbers after it.", {
        ok: [0], aux: { label: "subset", items: ["1"] },
      }),
      s("Pick the first 2. The subset is 1, 2.", {
        ok: [0], hl: [1], aux: { label: "subset", items: ["1", "2"] },
      }),
      s("Pick the second 2 instead. The subset is 1, 2 again.", {
        ok: [0], hl: [2], aux: { label: "subset", items: ["1", "2"] },
      }),
      s("Both choices at this level built the same subset. When should we skip an element?", {
        ok: [0], hl: [1, 2], aux: { label: "subset", items: ["1", "2"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Combination Sum II": [
    A([1, 1, 2, 5, 6, 7, 10], [
      s("The sorted candidates are 1, 1, 2, 5, 6, 7, 10 and the target is 8. Each number may be used once.", {}),
      s("Choose the first 1. We still need 7.", {
        ok: [0], tags: { 0: "need 7" }, aux: { label: "chosen", items: ["1"] },
      }),
      s("That first 1 is now used up.", {
        bad: [0], tags: { 0: "need 7" }, aux: { label: "chosen", items: ["1"] },
      }),
      s("Where in the list should the next choice start?", {
        bad: [0], tags: { 0: "need 7" }, aux: { label: "chosen", items: ["1"] },
      }),
    ]),
    A([1, 1, 2, 5, 6, 7, 10], [
      s("At the first level we choose the first number to add. Try the first 1.", {
        hl: [0], aux: { label: "found", items: [] },
      }),
      s("It leads to the combination 1, 7.", {
        ok: [0, 5], aux: { label: "found", items: ["1, 7"] },
      }),
      s("Now try the second 1 as the first number. It also leads to 1, 7.", {
        hl: [1], ok: [5], aux: { label: "found", items: ["1, 7", "1, 7"] },
      }),
      s("The same combination appeared twice, yet 1, 1, 6 (using both 1s) must stay. How do we avoid the repeat?", {
        hl: [0, 1], aux: { label: "found", items: ["1, 7", "1, 7"] },
      }),
    ]),
  ],

  // ---------------------------------------------------------------
  "Palindrome Partitioning": [
    A(["a", "a", "b"], [
      s("We cut aab into pieces, and every piece must be a palindrome.", {}),
      s("The first piece could be a. That is a palindrome.", {
        hl: [0], aux: { label: "piece", items: ["a"] },
      }),
      s("The first piece could be aa. That is a palindrome too.", {
        hl: [0, 1], aux: { label: "piece", items: ["aa"] },
      }),
      s("The first piece could be aab. Read backwards it is baa, which is different.", {
        bad: [0, 1, 2], aux: { label: "piece", items: ["aab"] },
      }),
      s("Which pieces may we choose at each step?", {
        aux: { label: "piece", items: ["aab"] },
      }),
    ]),
    A(["a", "a", "b"], [
      s("We cut aab into the pieces a, a, b, one piece at a time.", {
        aux: { label: "pieces", items: [] },
      }),
      s("First piece: a.", {
        ok: [0], aux: { label: "pieces", items: ["a"] },
      }),
      s("Second piece: a.", {
        ok: [0, 1], aux: { label: "pieces", items: ["a", "a"] },
      }),
      s("Third piece: b. The cut now stands at the end of the string.", {
        ok: [0, 1, 2], aux: { label: "pieces", items: ["a", "a", "b"] },
      }),
      s("When can we say a partition is complete?", {
        ok: [0, 1, 2], aux: { label: "pieces", items: ["a", "a", "b"] },
      }),
    ]),
  ],

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
      if (!["tree", "array", "list", "grid", "graph", "intervals"].includes(v.type)) throw new Error(`${where}: bad type`);
      if (!Array.isArray(v.steps) || v.steps.length === 0)
        throw new Error(`${where}: needs steps`);
      if (v.type === "tree" && v.values.length > 15)
        throw new Error(`${where}: tree too big (max 15 slots)`);
      if (v.type === "grid") {
        const R = v.values.length;
        const C = R ? (v.values[0] || []).length : 0;
        if (R === 0 || R > 8 || C === 0 || C > 8 || v.values.some((row) => !Array.isArray(row) || row.length !== C))
          throw new Error(`${where}: grid must be a rectangle, at most 8 x 8`);
        if (v.rowLabels && v.rowLabels.length !== R) throw new Error(`${where}: rowLabels length`);
        if (v.colLabels && v.colLabels.length !== C) throw new Error(`${where}: colLabels length`);
        const inGrid = (p) =>
          Array.isArray(p) && p.length === 2 && Number.isInteger(p[0]) && Number.isInteger(p[1]) &&
          p[0] >= 0 && p[0] < R && p[1] >= 0 && p[1] < C;
        const checkCells = (list, label) =>
          (list || []).forEach((p) => {
            if (!inGrid(p)) throw new Error(`${where}: bad cell in ${label}`);
          });
        checkCells(v.dim, "dim");
        v.steps.forEach((st, k) => {
          if (!st.caption) throw new Error(`${where} step ${k + 1}: missing caption`);
          if (st.values && (st.values.length !== R || st.values.some((row) => !Array.isArray(row) || row.length !== C)))
            throw new Error(`${where} step ${k + 1}: values must keep the grid size`);
          ["hl", "ok", "bad", "dim"].forEach((key) => checkCells(st[key], `step ${k + 1} ${key}`));
          Object.keys(st.tags || {}).forEach((key) => {
            const [r, c] = key.split(",").map(Number);
            if (!inGrid([r, c])) throw new Error(`${where} step ${k + 1}: bad tag key ${key}`);
          });
        });
        return;
      }
      if (v.type === "graph") {
        const NN = (v.nodes || []).length;
        if (!Array.isArray(v.nodes) || NN < 1 || NN > 10)
          throw new Error(`${where}: graph needs 1 to 10 nodes`);
        if (v.pos && (v.pos.length !== NN || v.pos.some((p) => !Array.isArray(p) || p.length !== 2 || p.some((x) => typeof x !== "number" || x < 0 || x > 1))))
          throw new Error(`${where}: pos needs [x, y] between 0 and 1 for every node`);
        const edgeOk = (e) =>
          Array.isArray(e) && Number.isInteger(e[0]) && Number.isInteger(e[1]) &&
          e[0] >= 0 && e[0] < NN && e[1] >= 0 && e[1] < NN && e[0] !== e[1];
        if (!Array.isArray(v.edges) || !v.edges.every(edgeOk))
          throw new Error(`${where}: bad edge`);
        const has = (a, b) =>
          v.edges.some((e) => (e[0] === a && e[1] === b) || (!v.directed && e[0] === b && e[1] === a));
        v.steps.forEach((st, k) => {
          if (!st.caption) throw new Error(`${where} step ${k + 1}: missing caption`);
          ["hl", "ok", "bad"].forEach((key) =>
            (st[key] || []).forEach((idx) => {
              if (!Number.isInteger(idx) || idx < 0 || idx >= NN)
                throw new Error(`${where} step ${k + 1}: bad node in ${key}`);
            })
          );
          ["hlE", "okE", "badE"].forEach((key) =>
            (st[key] || []).forEach((pr) => {
              if (!Array.isArray(pr) || pr.length !== 2 || !has(pr[0], pr[1]))
                throw new Error(`${where} step ${k + 1}: ${key} names an edge that does not exist`);
            })
          );
          Object.keys(st.tags || {}).forEach((key) => {
            const i = Number(key);
            if (!Number.isInteger(i) || i < 0 || i >= NN)
              throw new Error(`${where} step ${k + 1}: bad tag key ${key}`);
          });
        });
        return;
      }
      if (v.type === "intervals") {
        const okList = (list) =>
          Array.isArray(list) && list.length >= 1 && list.length <= 7 &&
          list.every((p) => Array.isArray(p) && p.length === 2 && typeof p[0] === "number" && typeof p[1] === "number" && p[0] <= p[1]);
        if (!okList(v.intervals)) throw new Error(`${where}: intervals need 1 to 7 [start, end] pairs`);
        if (v.range && (!Array.isArray(v.range) || v.range.length !== 2 || !(v.range[1] > v.range[0])))
          throw new Error(`${where}: range must be [low, high] with high > low`);
        const all = [v.intervals, ...v.steps.map((st) => st.intervals).filter(Boolean)];
        if (v.range) {
          all.forEach((list) => {
            if (!okList(list)) throw new Error(`${where}: a step has bad intervals`);
            list.forEach((p) => {
              if (p[0] < v.range[0] || p[1] > v.range[1])
                throw new Error(`${where}: an interval falls outside range`);
            });
          });
        }
        v.steps.forEach((st, k) => {
          if (!st.caption) throw new Error(`${where} step ${k + 1}: missing caption`);
          const cur = st.intervals || v.intervals;
          if (!okList(cur)) throw new Error(`${where} step ${k + 1}: bad intervals`);
          ["hl", "ok", "bad"].forEach((key) =>
            (st[key] || []).forEach((idx) => {
              if (!Number.isInteger(idx) || idx < 0 || idx >= cur.length)
                throw new Error(`${where} step ${k + 1}: bad index in ${key}`);
            })
          );
          Object.keys(st.tags || {}).forEach((key) => {
            const i = Number(key);
            if (!Number.isInteger(i) || i < 0 || i >= cur.length)
              throw new Error(`${where} step ${k + 1}: bad tag key ${key}`);
          });
          if (st.marker !== undefined && typeof st.marker !== "number")
            throw new Error(`${where} step ${k + 1}: marker must be a number`);
        });
        return;
      }
      if (v.type === "list") {
        const sizes = { next: v.values.length, next2: (v.values2 || []).length };
        const checkNext = (m, size, label) => {
          Object.entries(m || {}).forEach(([k, t]) => {
            const ki = Number(k);
            if (!Number.isInteger(ki) || ki < 0 || ki >= size)
              throw new Error(`${where}: bad node index in ${label}`);
            if (t !== null && (!Number.isInteger(t) || t < 0 || t > size))
              throw new Error(`${where}: bad target in ${label}`);
          });
        };
        checkNext(v.next, sizes.next, "next");
        checkNext(v.next2, sizes.next2, "next2");
        v.steps.forEach((st, k) => {
          checkNext(st.next, sizes.next, `step ${k + 1} next`);
          checkNext(st.next2, sizes.next2, `step ${k + 1} next2`);
          Object.values(st.ptrs || {}).forEach((idx) => {
            if (!Number.isInteger(idx) || idx < 0 || idx > sizes.next)
              throw new Error(`${where} step ${k + 1}: bad pointer in ptrs`);
          });
          Object.values(st.ptrs2 || {}).forEach((idx) => {
            if (!Number.isInteger(idx) || idx < 0 || idx > sizes.next2)
              throw new Error(`${where} step ${k + 1}: bad pointer in ptrs2`);
          });
        });
      }
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