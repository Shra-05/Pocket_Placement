// Seeds DSA World problems. This batch: Graphs (4), Trees (3), Recursion & Backtracking (3) = 10 problems.
// Run from the pocket_placement_backend folder:  node seedProblems.js
// Safe to re-run: problems are matched by title and updated, never duplicated.
// To add the next batch, paste the new batch's file over this one and run it again.

// Same DNS workaround your server uses (needed for the Atlas mongodb+srv lookup)
try {
  require("./src/dns-fix");
} catch (e) {
  require("dns").setServers(["8.8.8.8", "8.8.4.4"]);
}

const DB_NAME = "Pocket_Placement_DSA";
const COLLECTION = "dsaproblems";

const XP = {
  noHint: 100,
  hint1: 80,
  hint2: 60,
  hint3: 40,
  reveal: 20,
  transferCorrect: 50,
};

const lc = (slug) => `https://leetcode.com/problems/${slug}/`;

// helpers to keep the data short
const p = ({ slug, ...rest }) => ({
  source: "LeetCode",
  sourceUrl: lc(slug),
  ...rest,
  xpReward: XP,
});
const ch = (question, options, correct, good, bad) => ({
  question,
  options,
  correct,
  feedback: { correct: good, incorrect: bad },
});
const tq = (scenario, question, options, correct) => ({
  scenario,
  question,
  options,
  correct,
});
const ap = (description, timeComplexity, spaceComplexity) => ({
  description,
  timeComplexity,
  spaceComplexity,
});

const problems = [
  // ====================================================
  // GRAPHS
  // ====================================================

  p({
    slug: "max-area-of-island",
    title: "Max Area of Island",
    difficulty: "Medium",
    topics: ["Graphs", "DFS", "Matrix"],
    patterns: ["DFS Area Count"],
    problem:
      "You are given an m × n binary grid where 1 is land and 0 is water. An island is a group of 1s connected up, down, left or right. Return the maximum area (number of cells) of an island in the grid, or 0 if there is no island.",
    examples: [
      {
        input: "grid = [[0,0,1,0],[1,1,1,0],[0,1,0,0]]",
        output: "5",
        explanation: "All five land cells are connected, so the only island has area 5.",
      },
    ],
    intuitionChallenges: [
      ch(
        "While exploring an island, how do you avoid counting a cell twice?",
        [
          "Mark each visited land cell (for example set it to 0)",
          "Count only the corner cells",
          "Sort the cells",
          "Use recursion without any marks",
        ],
        0,
        "Exactly! Once a cell is marked, no other path counts it again.",
        "Without marks, neighbouring cells would keep sending the search back and forth."
      ),
      ch(
        "How is the area of one island computed during a DFS?",
        [
          "1 for the current cell plus the areas found from its four neighbours",
          "The number of rows times the number of columns",
          "The number of water cells around it",
          "The longest path inside the island",
        ],
        0,
        "Right! Each cell adds itself and then everything reachable through its neighbours.",
        "The area is simply the count of land cells the search reaches."
      ),
    ],
    hints: [
      "An island is a group of connected land cells.",
      "Start a search from every unvisited land cell.",
      "The area of an island is the number of land cells the search visits.",
      "DFS: if the cell is out of bounds or water return 0; otherwise mark it visited and return 1 plus the results of its four neighbours; keep the maximum.",
    ],
    keyInsight:
      "Run a DFS from each unvisited land cell, counting the cells it visits, and keep the largest count.",
    bruteForceApproach: ap(
      "For each land cell, re-scan the whole grid for connected cells",
      "O((m · n)²)",
      "O(m · n)"
    ),
    optimalApproach: ap("DFS that marks visited cells", "O(m · n)", "O(m · n)"),
    patternName: "DFS Area Count",
    transferQuestions: [
      tq(
        "grid = [[1,1],[0,1]]. The land cells (0,0), (0,1) and (1,1) are connected.",
        "What area does the DFS return for this island?",
        ["3", "2", "4", "1"],
        0
      ),
    ],
  }),

  p({
    slug: "surrounded-regions",
    title: "Surrounded Regions",
    difficulty: "Medium",
    topics: ["Graphs", "DFS", "Matrix"],
    patterns: ["Reverse Search from the Borders"],
    problem:
      "You are given an m × n board containing 'X' and 'O'. Capture every region of 'O' cells that is completely surrounded by 'X' by flipping all of its 'O' cells to 'X'. An 'O' on the border, or connected to an 'O' on the border, is not captured.",
    examples: [
      {
        input: 'board = [["X","X","X","X"],["X","O","O","X"],["X","X","O","X"],["X","O","X","X"]]',
        output: '[["X","X","X","X"],["X","X","X","X"],["X","X","X","X"],["X","O","X","X"]]',
        explanation: "The three connected O cells in the middle are captured; the O on the bottom border stays.",
      },
    ],
    intuitionChallenges: [
      ch(
        "Which 'O' cells can never be captured?",
        [
          "Those on the border, and those connected to a border 'O'",
          "Those in the middle of the board",
          "Those that touch an 'X'",
          "Every 'O'",
        ],
        0,
        "Exactly! A region touching the border is not surrounded.",
        "A region is only captured if it is completely surrounded by X cells."
      ),
      ch(
        "Why start the search from the border instead of from every 'O'?",
        [
          "Only the safe cells need to be found; every other 'O' is captured",
          "Border cells are always 'X'",
          "It avoids using DFS",
          "Searches are faster at the edges",
        ],
        0,
        "Right! Mark the safe regions first, and everything else must be captured.",
        "It is easier to find the few safe cells than to test every region."
      ),
    ],
    hints: [
      "Think about which O cells are safe instead of which are captured.",
      "An O is safe if it touches the border directly or through other O cells.",
      "Mark every O reachable from a border O as safe.",
      "Run DFS from each border 'O' to mark safe cells; then flip the unmarked 'O' to 'X' and restore the marked ones.",
    ],
    keyInsight:
      "Find the safe 'O' regions by searching inward from the border, then capture everything else.",
    bruteForceApproach: ap(
      "From every 'O', search to see whether it can reach the border",
      "O((m · n)²)",
      "O(m · n)"
    ),
    optimalApproach: ap("Mark safe cells from the border, then flip the rest", "O(m · n)", "O(m · n)"),
    patternName: "Reverse Search from the Borders",
    transferQuestions: [
      tq(
        "In the example board, there is an 'O' at row 3, column 1, on the bottom edge.",
        "Is that 'O' captured?",
        [
          "No, it is on the border, so it is safe",
          "Yes, it is surrounded on three sides",
          "Yes, every 'O' is captured",
          "Only if the row above is all 'X'",
        ],
        0
      ),
    ],
  }),

  p({
    slug: "cheapest-flights-within-k-stops",
    title: "Cheapest Flights Within K Stops",
    difficulty: "Medium",
    topics: ["Graphs", "Shortest Path", "Dynamic Programming"],
    patterns: ["Bellman-Ford with Limited Rounds"],
    problem:
      "There are n cities connected by flights, where flights[i] = [from, to, price]. Given a source city src, a destination dst and an integer k, return the cheapest price from src to dst with at most k stops. If there is no such route, return -1.",
    examples: [
      {
        input: "n = 4, flights = [[0,1,100],[1,2,100],[2,0,100],[1,3,600],[2,3,200]], src = 0, dst = 3, k = 1",
        output: "700",
        explanation: "The cheapest route with at most 1 stop is 0 -> 1 -> 3, costing 100 + 600.",
      },
    ],
    intuitionChallenges: [
      ch(
        "With at most k stops, how many flights can the trip use?",
        ["k + 1", "k", "k - 1", "As many as you like"],
        0,
        "Exactly! Stops are the cities in between, so there is one more flight than stops.",
        "A trip with 1 stop uses 2 flights. What is the pattern?"
      ),
      ch(
        "What does one round of Bellman-Ford relaxation represent here?",
        [
          "Allowing the trip to use one more flight",
          "Visiting every city once",
          "Sorting the prices",
          "Removing one city",
        ],
        0,
        "Right! After r rounds you know the cheapest prices using at most r flights.",
        "Each round extends every known route by one flight."
      ),
    ],
    hints: [
      "At most k stops means at most k + 1 flights.",
      "Keep the cheapest known price to every city.",
      "Repeat k + 1 rounds; in each round use the previous round's prices to try every flight.",
      "Copy the prices before each round so that one round only adds a single flight.",
    ],
    keyInsight:
      "Run Bellman-Ford for k + 1 rounds, using the previous round's prices each time, so every round allows exactly one more flight.",
    bruteForceApproach: ap(
      "Try every route with at most k stops using DFS",
      "O(n^(k + 1))",
      "O(k)"
    ),
    optimalApproach: ap("Bellman-Ford limited to k + 1 rounds", "O((k + 1) · E)", "O(n)"),
    patternName: "Bellman-Ford with Limited Rounds",
    transferQuestions: [
      tq(
        "A trip is allowed at most k = 1 stop.",
        "How many flights can it use at most?",
        ["2", "1", "3", "4"],
        0
      ),
    ],
  }),

  p({
    slug: "min-cost-to-connect-all-points",
    title: "Min Cost to Connect All Points",
    difficulty: "Medium",
    topics: ["Graphs", "Minimum Spanning Tree", "Heap & Priority Queue"],
    patterns: ["Prim's Algorithm"],
    problem:
      "You are given an array points of coordinates on a 2D plane. The cost of connecting two points is their Manhattan distance, |x1 - x2| + |y1 - y2|. Return the minimum total cost to connect all the points so that there is exactly one simple path between any two points.",
    examples: [
      {
        input: "points = [[0,0],[2,2],[3,10],[5,2],[7,0]]",
        output: "20",
        explanation: "The cheapest set of connections that links all five points costs 20 in total.",
      },
    ],
    intuitionChallenges: [
      ch(
        "Connecting all points so that there is exactly one path between any two of them means building...",
        [
          "A minimum spanning tree",
          "A shortest path",
          "A cycle through every point",
          "A sorted list of points",
        ],
        0,
        "Exactly! A spanning tree links everything with no cycles, and you want the cheapest one.",
        "Exactly one path between any two points means no cycles."
      ),
      ch(
        "In Prim's algorithm, which connection do you add next?",
        [
          "The cheapest edge from the connected set to a point outside it",
          "The cheapest edge in the whole graph, anywhere",
          "The longest edge",
          "A random edge",
        ],
        0,
        "Right! The tree grows by always taking the cheapest way to reach a new point.",
        "The tree must stay connected as it grows."
      ),
    ],
    hints: [
      "You need the cheapest set of connections that links every point.",
      "That set is a minimum spanning tree.",
      "Start from any point and grow the tree one point at a time.",
      "Always add the cheapest edge that reaches a new point (use a min-heap or an array of best costs).",
    ],
    keyInsight:
      "Grow a tree from one point, always adding the cheapest edge that reaches a point not yet connected (Prim's algorithm).",
    bruteForceApproach: ap(
      "Try every possible set of connections and keep the cheapest tree",
      "Exponential",
      "O(n²)"
    ),
    optimalApproach: ap("Prim's algorithm", "O(n²)", "O(n)"),
    patternName: "Prim's Algorithm",
    transferQuestions: [
      tq(
        "Two points are (0,0) and (2,2).",
        "What is the cost of connecting them?",
        ["4", "2", "8", "3"],
        0
      ),
    ],
  }),

  // ====================================================
  // TREES
  // ====================================================

  p({
    slug: "binary-tree-right-side-view",
    title: "Binary Tree Right Side View",
    difficulty: "Medium",
    topics: ["Trees", "Binary Tree", "BFS"],
    patterns: ["Last Node of Each Level"],
    problem:
      "Given the root of a binary tree, imagine standing on its right side. Return the values of the nodes you can see, ordered from top to bottom.",
    examples: [
      {
        input: "root = [1,2,3,null,5,null,4]",
        output: "[1,3,4]",
        explanation: "From the right you see 1 on the first level, 3 on the second and 4 on the third.",
      },
    ],
    intuitionChallenges: [
      ch(
        "Which node on each level is visible from the right?",
        [
          "The rightmost node of that level",
          "The leftmost node of that level",
          "The node with the largest value",
          "The first node reached going down the left side",
        ],
        0,
        "Exactly! The rightmost node on a level hides everything to its left.",
        "Nodes further right block your view of nodes to their left."
      ),
      ch(
        "In a level-order traversal, which node of each level do you record?",
        [
          "The last one",
          "The first one",
          "All of them",
          "The middle one",
        ],
        0,
        "Right! Level order goes left to right, so the last node is the rightmost.",
        "Level order visits each level from left to right."
      ),
    ],
    hints: [
      "Looking from the right, each level shows exactly one node.",
      "That node is the last one of the level when read from left to right.",
      "Use BFS and process one level at a time.",
      "For each level, add the value of its last node to the answer.",
    ],
    keyInsight:
      "In a level-order traversal, the last node of each level is the one visible from the right.",
    bruteForceApproach: ap(
      "Collect every node of every level, then take the last of each",
      "O(n)",
      "O(n)"
    ),
    optimalApproach: ap("BFS that keeps only the last node of each level", "O(n)", "O(w) for the widest level w"),
    patternName: "Last Node of Each Level",
    transferQuestions: [
      tq(
        "On the third level of a tree, the nodes from left to right are 5 and 4.",
        "Which one is visible from the right?",
        ["4", "5", "Both", "Neither"],
        0
      ),
    ],
  }),

  p({
    slug: "lowest-common-ancestor-of-a-binary-tree",
    title: "Lowest Common Ancestor of a Binary Tree",
    difficulty: "Medium",
    topics: ["Trees", "Binary Tree", "DFS"],
    patterns: ["Post-Order Search for Two Nodes"],
    problem:
      "Given a binary tree (not necessarily a search tree) and two nodes p and q, find their lowest common ancestor: the lowest node that has both p and q as descendants (a node can be a descendant of itself).",
    examples: [
      {
        input: "root = [3,5,1,6,2,0,8,null,null,7,4], p = 5, q = 1",
        output: "3",
        explanation: "The node 3 is the lowest node that has both 5 and 1 below it.",
      },
    ],
    intuitionChallenges: [
      ch(
        "A recursive search returns a node when it finds p or q. The left and the right searches both return a node. What does that mean?",
        [
          "The current node is the lowest common ancestor",
          "Both p and q are in the left subtree",
          "Neither p nor q was found",
          "The tree is a search tree",
        ],
        0,
        "Exactly! p is on one side and q on the other, so this node is where they split.",
        "If the two targets are found on different sides, where do their paths meet?"
      ),
      ch(
        "The left search finds nothing and the right search returns a node. What do you return?",
        [
          "The node found by the right search",
          "null",
          "The current node",
          "The root",
        ],
        0,
        "Right! Both targets (or the one found) lie in the right subtree.",
        "Pass up whatever the side that found something returned."
      ),
    ],
    hints: [
      "There is no value ordering to guide you, so search both sides.",
      "If the current node is p or q, return it.",
      "Search the left and the right subtrees.",
      "If both sides return a node, the current node is the answer; otherwise return whichever side found something.",
    ],
    keyInsight:
      "Search both subtrees; the first node where the left and right searches each find one of the targets is the lowest common ancestor.",
    bruteForceApproach: ap(
      "Find the root-to-node path for p and for q, then compare the paths",
      "O(n)",
      "O(n)"
    ),
    optimalApproach: ap("A single recursive DFS", "O(n)", "O(h)"),
    patternName: "Post-Order Search for Two Nodes",
    transferQuestions: [
      tq(
        "The root is 3, with p = 5 in its left subtree and q = 1 in its right subtree. The left search returns 5 and the right search returns 1.",
        "What does the search return at the root?",
        ["3", "5", "1", "null"],
        0
      ),
    ],
  }),

  p({
    slug: "count-good-nodes-in-binary-tree",
    title: "Count Good Nodes in Binary Tree",
    difficulty: "Medium",
    topics: ["Trees", "Binary Tree", "DFS"],
    patterns: ["DFS Carrying the Path Maximum"],
    problem:
      "In a binary tree, a node X is called good if, on the path from the root to X, there is no node with a value greater than X. Given the root, return the number of good nodes.",
    examples: [
      {
        input: "root = [3,1,4,3,null,1,5]",
        output: "4",
        explanation: "The good nodes are the root 3, the node 4, the 3 below the 1, and the node 5.",
      },
    ],
    intuitionChallenges: [
      ch(
        "What do you pass down as you move from a node to its children?",
        [
          "The largest value seen on the path so far",
          "The smallest value on the path",
          "The number of nodes visited",
          "The sum of the values",
        ],
        0,
        "Exactly! A node is judged against the biggest value above it.",
        "A node is good if nothing bigger is on its path. What do you need to remember?"
      ),
      ch(
        "When is a node good?",
        [
          "When its value is at least the largest value on the path above it",
          "When it is a leaf",
          "When it is smaller than its parent",
          "When it is a left child",
        ],
        0,
        "Right! Equal values count as good too.",
        "Re-read the definition of a good node."
      ),
    ],
    hints: [
      "Whether a node is good depends only on the nodes above it.",
      "Carry the maximum value of the path down the tree.",
      "Compare each node with that maximum.",
      "If node.val is at least the maximum, count it and pass node.val as the new maximum; otherwise pass the old maximum.",
    ],
    keyInsight:
      "Walk down the tree carrying the largest value on the path; a node is good when its value reaches that maximum.",
    bruteForceApproach: ap(
      "For every node, collect its path from the root and check it",
      "O(n · h)",
      "O(h)"
    ),
    optimalApproach: ap("DFS with a running maximum", "O(n)", "O(h)"),
    patternName: "DFS Carrying the Path Maximum",
    transferQuestions: [
      tq(
        "The path from the root so far has a maximum of 3, and you reach a node with the value 1.",
        "Is that node good?",
        [
          "No, because 3 is greater than 1",
          "Yes, because it is a child",
          "Yes, because 1 is odd",
          "Only if it is a leaf",
        ],
        0
      ),
    ],
  }),

  // ====================================================
  // RECURSION & BACKTRACKING
  // ====================================================

  p({
    slug: "subsets-ii",
    title: "Subsets II",
    difficulty: "Medium",
    topics: ["Recursion & Backtracking", "Backtracking", "Arrays"],
    patterns: ["Backtracking with Duplicate Skipping"],
    problem:
      "Given an integer array nums that may contain duplicates, return all possible subsets (the power set). The result must not contain duplicate subsets, and you may return the subsets in any order.",
    examples: [
      {
        input: "nums = [1,2,2]",
        output: "[[],[1],[1,2],[1,2,2],[2],[2,2]]",
        explanation: "Without the duplicate check, [1,2] and [2] would each appear twice.",
      },
    ],
    intuitionChallenges: [
      ch(
        "Why do you sort the array first?",
        [
          "So equal numbers sit next to each other and can be skipped",
          "To make the output easier to print",
          "To find the maximum",
          "To remove the negative numbers",
        ],
        0,
        "Exactly! Duplicates become neighbours, so one comparison detects them.",
        "How could you easily tell that two numbers are equal?"
      ),
      ch(
        "At one level of the recursion you are choosing the next element to add. When do you skip an element?",
        [
          "When it equals the previous element tried at this same level",
          "When it is the first element",
          "When it is larger than the last element chosen",
          "When the subset is empty",
        ],
        0,
        "Right! Trying the same value twice at one level builds the same subsets again.",
        "Choosing a second equal value as the next element repeats the earlier work."
      ),
    ],
    hints: [
      "Duplicate numbers can create duplicate subsets.",
      "Sort the array so equal numbers are neighbours.",
      "At each level of the recursion, try each distinct value only once.",
      "In the loop over choices, skip nums[i] when i is greater than the start index and nums[i] equals nums[i - 1].",
    ],
    keyInsight:
      "Sort the array and, at each level of choices, skip a number that equals the one just tried, so every distinct subset is built exactly once.",
    bruteForceApproach: ap(
      "Generate all subsets and remove the duplicates with a set",
      "O(n · 2^n)",
      "O(n · 2^n)"
    ),
    optimalApproach: ap("Backtracking with duplicate skipping", "O(n · 2^n)", "O(n)"),
    patternName: "Backtracking with Duplicate Skipping",
    transferQuestions: [
      tq(
        "nums = [1,2,2] (sorted). You have chosen 1, tried the first 2, and now reach the second 2 at the same level.",
        "What do you do with the second 2?",
        [
          "Skip it, since it equals the previous number at this level",
          "Use it, since it is a different index",
          "Stop the recursion",
          "Remove the first 2",
        ],
        0
      ),
    ],
  }),

  p({
    slug: "combination-sum-ii",
    title: "Combination Sum II",
    difficulty: "Medium",
    topics: ["Recursion & Backtracking", "Backtracking", "Arrays"],
    patterns: ["Backtracking without Reuse"],
    problem:
      "Given a collection of candidate numbers (which may contain duplicates) and a target number, return all unique combinations of candidates that sum to the target. Each number in candidates may be used at most once in a combination, and the result must not contain duplicate combinations.",
    examples: [
      {
        input: "candidates = [10,1,2,7,6,1,5], target = 8",
        output: "[[1,1,6],[1,2,5],[1,7],[2,6]]",
        explanation: "Each combination sums to 8, uses each position at most once, and none repeats.",
      },
    ],
    intuitionChallenges: [
      ch(
        "Each number may be used once. After choosing candidates[i], where does the next choice start?",
        [
          "At index i + 1",
          "At index i",
          "At index 0",
          "At the last index",
        ],
        0,
        "Exactly! Moving forward guarantees the same position is not used twice.",
        "To use each number only once, the next choice must come after the current one."
      ),
      ch(
        "How do you avoid duplicate combinations when the input has repeated numbers?",
        [
          "Sort, and skip a number that equals the previous one at the same level",
          "Use a bigger target",
          "Remove all duplicates from the input first",
          "Only ever use the first number",
        ],
        0,
        "Right! You still allow equal numbers in one combination (like 1, 1, 6), but not as two equal first choices at the same level.",
        "Removing duplicates entirely would lose answers such as [1,1,6]."
      ),
    ],
    hints: [
      "Unlike Combination Sum, each number can be used only once.",
      "Sort the candidates so duplicates are neighbours.",
      "Recurse from i + 1 after choosing candidates[i].",
      "Skip candidates[i] if it equals candidates[i - 1] and i is beyond the start of this level; stop a branch when the remaining target is negative.",
    ],
    keyInsight:
      "Sort, move forward after each choice, and skip repeated values within the same level so every combination appears once.",
    bruteForceApproach: ap(
      "Generate every subset and keep those that add up to the target",
      "O(2^n · n)",
      "O(n)"
    ),
    optimalApproach: ap(
      "Backtracking with pruning and duplicate skipping",
      "Exponential (pruned)",
      "O(n)"
    ),
    patternName: "Backtracking without Reuse",
    transferQuestions: [
      tq(
        "The sorted candidates are [1,1,2,5,6,7,10] and the target is 8. You have chosen the first 1, so the remaining target is 7.",
        "Which candidates can you choose next?",
        [
          "Those after it that are at most 7: 1, 2, 5, 6 and 7",
          "Only 7",
          "Any candidate, including the first 1 again",
          "Only 10",
        ],
        0
      ),
    ],
  }),

  p({
    slug: "palindrome-partitioning",
    title: "Palindrome Partitioning",
    difficulty: "Medium",
    topics: ["Recursion & Backtracking", "Backtracking", "Strings"],
    patterns: ["Backtracking over Cut Points"],
    problem:
      "Given a string s, partition it so that every substring of the partition is a palindrome. Return all possible palindrome partitions of s.",
    examples: [
      {
        input: 's = "aab"',
        output: '[["a","a","b"],["aa","b"]]',
        explanation: 'Both partitions consist only of palindromes. "aab" itself is not a palindrome.',
      },
    ],
    intuitionChallenges: [
      ch(
        "At each position you choose where the next piece ends. Which pieces may you choose?",
        [
          "Only pieces that are palindromes",
          "Any piece at all",
          "Only single letters",
          "Only pieces of even length",
        ],
        0,
        "Exactly! Every piece in the final partition has to be a palindrome.",
        "Re-read what a valid partition requires of each piece."
      ),
      ch(
        "When is a partition complete?",
        [
          "When the cut reaches the end of the string",
          "When the first piece is a palindrome",
          "When all the letters are different",
          "After two pieces",
        ],
        0,
        "Right! The pieces must cover the whole string.",
        "Every character must belong to some piece."
      ),
    ],
    hints: [
      "A partition cuts the string into consecutive pieces.",
      "Choose the first piece, which must be a palindrome.",
      "Then partition the rest of the string in the same way.",
      "Recurse from a start index: for each end index where s[start..end] is a palindrome, add the piece, recurse from end + 1, then remove the piece.",
    ],
    keyInsight:
      "Try every palindromic first piece, partition the rest recursively, and backtrack after each choice.",
    bruteForceApproach: ap(
      "Generate every way of cutting the string and check each piece",
      "O(2^n · n)",
      "O(n)"
    ),
    optimalApproach: ap(
      "Backtracking with a palindrome check (optionally precomputed)",
      "O(n · 2^n)",
      "O(n)"
    ),
    patternName: "Backtracking over Cut Points",
    transferQuestions: [
      tq(
        's = "aab".',
        "Which first pieces are possible?",
        [
          '"a" and "aa"',
          '"a", "aa" and "aab"',
          'Only "aab"',
          'Only "b"',
        ],
        0
      ),
    ],
  }),

];

// ----------------------------------------------------
// Sanity checks so bad data never reaches the database
// ----------------------------------------------------
function validate() {
  const titles = new Set();
  for (const d of problems) {
    const where = `"${d.title}"`;
    if (titles.has(d.title)) throw new Error(`${where}: duplicate title`);
    titles.add(d.title);
    if (!["Easy", "Medium", "Hard"].includes(d.difficulty))
      throw new Error(`${where}: bad difficulty`);
    if (!d.hints || d.hints.length !== 4)
      throw new Error(`${where}: needs exactly 4 hints`);
    const checkQuestion = (q, label) => {
      if (!q.options || q.options.length !== 4)
        throw new Error(`${where} ${label}: needs 4 options`);
      if (new Set(q.options).size !== 4)
        throw new Error(`${where} ${label}: options must all be different`);
      if (!Number.isInteger(q.correct) || q.correct < 0 || q.correct > 3)
        throw new Error(`${where} ${label}: correct index out of range`);
    };
    d.intuitionChallenges.forEach((q, i) => checkQuestion(q, `challenge ${i + 1}`));
    d.transferQuestions.forEach((q, i) => checkQuestion(q, `transfer ${i + 1}`));
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
    console.error(
      "No MongoDB connection string found. Open .env, find the variable that holds your Atlas URI, and add its name to the URI list in this file."
    );
    process.exit(1);
  }

  const client = new MongoClient(URI);
  try {
    await client.connect();
    const col = client.db(DB_NAME).collection(COLLECTION);

    let inserted = 0;
    let updated = 0;
    for (const doc of problems) {
      const now = new Date();
      const res = await col.updateOne(
        { title: doc.title },
        { $set: { ...doc, updatedAt: now }, $setOnInsert: { createdAt: now } },
        { upsert: true }
      );
      if (res.upsertedCount) inserted++;
      else updated++;
      console.log(`${res.upsertedCount ? "Inserted" : "Updated "}: ${doc.title}`);
    }

    const total = await col.countDocuments();
    console.log(
      `\nDone. Inserted ${inserted}, updated ${updated}. dsaproblems now has ${total} documents.`
    );
  } catch (err) {
    console.error("Seeding failed:", err.message);
    process.exitCode = 1;
  } finally {
    await client.close();
  }
}

if (require.main === module) {
  main();
}

module.exports = { problems, validate };