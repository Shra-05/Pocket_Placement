// Seeds DSA World problems. This batch: Recursion & Backtracking (10).
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
  // RECURSION & BACKTRACKING
  // ====================================================

  p({
    slug: "fibonacci-number",
    title: "Fibonacci Number",
    difficulty: "Easy",
    topics: ["Recursion & Backtracking", "Recursion", "Dynamic Programming"],
    patterns: ["Recursion with Memoization"],
    problem:
      "The Fibonacci numbers are defined by F(0) = 0, F(1) = 1 and F(n) = F(n - 1) + F(n - 2) for n greater than 1. Given n, return F(n).",
    examples: [
      {
        input: "n = 4",
        output: "3",
        explanation: "F(4) = F(3) + F(2) = 2 + 1 = 3.",
      },
    ],
    intuitionChallenges: [
      ch(
        "To compute F(n), which smaller problems do you need?",
        [
          "F(n - 1) and F(n - 2)",
          "Only F(n - 1)",
          "F(n / 2)",
          "F(n + 1)",
        ],
        0,
        "Exactly! Each Fibonacci number is the sum of the previous two.",
        "Look at the definition: which two earlier values does F(n) use?"
      ),
      ch(
        "Plain recursion recomputes the same values many times. How can you avoid that?",
        [
          "Remember results you have already computed (memoization)",
          "Use a bigger stack",
          "Sort the values",
          "Start from n + 1",
        ],
        0,
        "Right! Storing each result means every F(k) is computed only once.",
        "What could you save so the same work is never repeated?"
      ),
    ],
    hints: [
      "The definition of F(n) refers to two smaller values.",
      "The base cases are F(0) = 0 and F(1) = 1.",
      "Plain recursion calls the same F(k) many times.",
      "Store computed results (memoize) or build upward from the bottom using two variables.",
    ],
    keyInsight:
      "Each Fibonacci number depends only on the two before it, so store results to avoid recomputing them.",
    bruteForceApproach: ap("Plain recursion without remembering results", "O(2^n)", "O(n)"),
    optimalApproach: ap("Iterate upward, keeping only the last two values", "O(n)", "O(1)"),
    patternName: "Recursion with Memoization",
    transferQuestions: [
      tq(
        "F(0) = 0, F(1) = 1 and F(2) = 1.",
        "What is F(5)?",
        ["3", "5", "8", "13"],
        1
      ),
    ],
  }),

  p({
    slug: "climbing-stairs",
    title: "Climbing Stairs",
    difficulty: "Easy",
    topics: ["Recursion & Backtracking", "Recursion", "Dynamic Programming"],
    patterns: ["Recursion with Memoization", "Fibonacci Pattern"],
    problem:
      "You are climbing a staircase with n steps. Each time you can climb either 1 or 2 steps. In how many distinct ways can you climb to the top?",
    examples: [
      {
        input: "n = 3",
        output: "3",
        explanation: "The ways are 1+1+1, 1+2 and 2+1.",
      },
    ],
    intuitionChallenges: [
      ch(
        "To reach step n, what was your last move?",
        [
          "A 1-step from n - 1, or a 2-step from n - 2",
          "Always a 2-step",
          "Always a 1-step",
          "A jump from the top",
        ],
        0,
        "Exactly! Only those two steps can lead to step n.",
        "Which steps can you stand on right before reaching step n?"
      ),
      ch(
        "So the number of ways to reach step n equals...",
        [
          "ways(n - 1) + ways(n - 2)",
          "ways(n - 1) × 2",
          "n × 2",
          "ways(n) - 1",
        ],
        0,
        "Right! Add the ways to reach each of the two possible previous steps.",
        "Each last move gives a separate set of ways. Add them."
      ),
    ],
    hints: [
      "Think about the very last move before reaching step n.",
      "It came from step n - 1 or step n - 2.",
      "Add the number of ways to reach each of those steps.",
      "This is the Fibonacci pattern; compute it iteratively using the previous two values.",
    ],
    keyInsight:
      "The ways to reach step n are the ways to reach n - 1 plus the ways to reach n - 2.",
    bruteForceApproach: ap(
      "Recursively try every sequence of 1-steps and 2-steps",
      "O(2^n)",
      "O(n)"
    ),
    optimalApproach: ap("Iterate with two variables", "O(n)", "O(1)"),
    patternName: "Fibonacci Pattern",
    transferQuestions: [
      tq(
        "ways(1) = 1, ways(2) = 2 and ways(3) = 3.",
        "What is ways(4)?",
        ["4", "5", "6", "8"],
        1
      ),
    ],
  }),

  p({
    slug: "powx-n",
    title: "Pow(x, n)",
    difficulty: "Medium",
    topics: ["Recursion & Backtracking", "Recursion", "Math"],
    patterns: ["Fast Exponentiation"],
    problem:
      "Implement pow(x, n), which raises the number x to the integer power n. The exponent n may be negative.",
    examples: [
      {
        input: "x = 2.0, n = 10",
        output: "1024.0",
        explanation: "2 multiplied by itself 10 times equals 1024.",
      },
    ],
    intuitionChallenges: [
      ch(
        "How can x^10 be computed using x^5?",
        [
          "x^10 = x^5 × x^5",
          "x^10 = x^5 + x^5",
          "x^10 = x^5 × 2",
          "x^10 = (x^5)^10",
        ],
        0,
        "Exactly! Squaring a half-power doubles the exponent.",
        "Exponents add when you multiply powers of the same base."
      ),
      ch(
        "How do you handle a negative exponent n?",
        [
          "Compute x^|n| and take its reciprocal",
          "Return 0",
          "Ignore the sign",
          "Multiply by -1",
        ],
        0,
        "Right! x^(-n) is 1 divided by x^n.",
        "What does a negative exponent mean mathematically?"
      ),
    ],
    hints: [
      "Multiplying x by itself n times is slow for large n.",
      "x^n can be built from half of the exponent.",
      "If n is even, x^n = (x^(n/2))². If n is odd, multiply by one extra x.",
      "For negative n, compute with |n| and return 1 divided by the result.",
    ],
    keyInsight:
      "Halve the exponent each time: x^n = (x^(n/2))², with one extra factor of x when n is odd.",
    bruteForceApproach: ap("Multiply x by itself n times", "O(n)", "O(1)"),
    optimalApproach: ap("Fast exponentiation by squaring", "O(log n)", "O(log n) recursion"),
    patternName: "Fast Exponentiation",
    transferQuestions: [
      tq(
        "x = 3 and n = 5, using 3² = 9.",
        "How is 3^5 built from 3²?",
        ["3² × 3² × 3", "3² × 3² × 3²", "3² + 3² + 3", "3² × 3"],
        0
      ),
    ],
  }),

  p({
    slug: "subsets",
    title: "Subsets",
    difficulty: "Medium",
    topics: ["Recursion & Backtracking", "Backtracking", "Arrays"],
    patterns: ["Include / Exclude Backtracking"],
    problem:
      "Given an integer array nums of unique elements, return all possible subsets (the power set). The solution must not contain duplicate subsets, and you may return them in any order.",
    examples: [
      {
        input: "nums = [1,2,3]",
        output: "[[],[1],[2],[1,2],[3],[1,3],[2,3],[1,2,3]]",
        explanation: "Every combination of elements, including the empty one, appears once.",
      },
    ],
    intuitionChallenges: [
      ch(
        "For each element, how many choices do you have?",
        [
          "Two: include it or leave it out",
          "One: include it",
          "Three",
          "It depends on the value",
        ],
        0,
        "Exactly! Each element is either in the subset or not.",
        "Think about what you can do with a single element."
      ),
      ch(
        "How many subsets does an array of n unique numbers have?",
        ["2^n", "n²", "n!", "2n"],
        0,
        "Right! Two choices for each of n elements gives 2^n.",
        "Multiply the number of choices for each element."
      ),
    ],
    hints: [
      "Every element is either in a subset or not.",
      "Make that choice for the first element, then solve the rest.",
      "Each choice splits the problem into two smaller ones.",
      "Recurse over indexes: add the current element, recurse, remove it (backtrack), and recurse again without it.",
    ],
    keyInsight:
      "At each element make two choices, include or exclude, and recurse on the rest of the array.",
    bruteForceApproach: ap(
      "Generate every bitmask from 0 to 2^n - 1 and build a subset from each",
      "O(n · 2^n)",
      "O(n)"
    ),
    optimalApproach: ap(
      "Backtracking with include / exclude choices",
      "O(n · 2^n)",
      "O(n) recursion depth"
    ),
    patternName: "Include / Exclude Backtracking",
    transferQuestions: [
      tq(
        "nums = [1,2]",
        "Which subsets does the recursion produce?",
        [
          "[], [1], [2], [1,2]",
          "[1], [2]",
          "[], [1,2]",
          "[1], [2], [1,2]",
        ],
        0
      ),
    ],
  }),

  p({
    slug: "permutations",
    title: "Permutations",
    difficulty: "Medium",
    topics: ["Recursion & Backtracking", "Backtracking", "Arrays"],
    patterns: ["Backtracking with a Used Marker"],
    problem:
      "Given an array nums of distinct integers, return all the possible permutations. You may return the answer in any order.",
    examples: [
      {
        input: "nums = [1,2,3]",
        output: "[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]",
        explanation: "Every ordering of the three numbers appears exactly once.",
      },
    ],
    intuitionChallenges: [
      ch(
        "To build a permutation position by position, which numbers can fill the next position?",
        [
          "Any number that has not been used yet",
          "Any number",
          "Only the largest",
          "Only the smallest",
        ],
        0,
        "Exactly! Each number must appear exactly once.",
        "A permutation cannot repeat a number."
      ),
      ch(
        "How many permutations does an array of 3 distinct numbers have?",
        ["6", "3", "9", "8"],
        0,
        "Right! 3 × 2 × 1 = 6.",
        "Count the choices for each position: 3, then 2, then 1."
      ),
    ],
    hints: [
      "A permutation uses every number exactly once.",
      "Fill the positions one at a time.",
      "At each position, try every number that has not been used.",
      "Mark a number as used, recurse, then unmark it (backtrack) and try the next one.",
    ],
    keyInsight:
      "Build the permutation one position at a time, trying every unused number and undoing the choice after each attempt.",
    bruteForceApproach: ap(
      "Generate all sequences of length n and filter out those with repeats",
      "O(n^n · n)",
      "O(n)"
    ),
    optimalApproach: ap("Backtracking with a used marker", "O(n · n!)", "O(n)"),
    patternName: "Backtracking with a Used Marker",
    transferQuestions: [
      tq(
        "nums = [1,2,3], and the first position is fixed to 1.",
        "Which permutations start with 1?",
        [
          "[1,2,3] and [1,3,2]",
          "[1,2,3] only",
          "[2,1,3] and [3,1,2]",
          "[1,1,2] and [1,1,3]",
        ],
        0
      ),
    ],
  }),

  p({
    slug: "combination-sum",
    title: "Combination Sum",
    difficulty: "Medium",
    topics: ["Recursion & Backtracking", "Backtracking", "Arrays"],
    patterns: ["Backtracking with Reuse"],
    problem:
      "Given an array of distinct integers candidates and a target integer, return all unique combinations of candidates whose chosen numbers sum to the target. The same number may be chosen an unlimited number of times.",
    examples: [
      {
        input: "candidates = [2,3,6,7], target = 7",
        output: "[[2,2,3],[7]]",
        explanation: "2 + 2 + 3 = 7 and 7 = 7.",
      },
    ],
    intuitionChallenges: [
      ch(
        "A number can be reused. What do you do right after choosing a number?",
        [
          "Recurse again starting from the same index",
          "Move on to the next index only",
          "Remove it from the array",
          "Restart from the beginning",
        ],
        0,
        "Exactly! Staying on the same index allows the number to be chosen again.",
        "Reuse means the same candidate stays available."
      ),
      ch(
        "When should a branch of the search stop?",
        [
          "When the remaining target is 0 (success) or negative (failure)",
          "Only when the array ends",
          "After exactly 3 numbers",
          "Never",
        ],
        0,
        "Right! A zero remainder is a solution and a negative one can never recover.",
        "What does it mean when the remaining target reaches 0, or goes below 0?"
      ),
    ],
    hints: [
      "Each number can be used more than once.",
      "Pick a number, subtract it from the target, and solve the smaller problem.",
      "To avoid repeated combinations, only consider candidates from the current index onward.",
      "Stop when the remaining target is 0 (record the combination) or below 0 (abandon); backtrack after each choice.",
    ],
    keyInsight:
      "Choose a candidate, subtract it from the target, and recurse from the same index; stop when the target reaches 0 or goes below it.",
    bruteForceApproach: ap(
      "Generate every possible multiset of candidates and test its sum",
      "Exponential",
      "O(target)"
    ),
    optimalApproach: ap(
      "Backtracking that prunes when the remaining target goes negative",
      "Exponential (pruned)",
      "O(target / smallest candidate)"
    ),
    patternName: "Backtracking with Reuse",
    transferQuestions: [
      tq(
        "candidates = [2,3] and target = 5. The first choice is 2.",
        "After choosing 2, what is the remaining target?",
        ["3", "7", "2", "5"],
        0
      ),
    ],
  }),

  p({
    slug: "generate-parentheses",
    title: "Generate Parentheses",
    difficulty: "Medium",
    topics: ["Recursion & Backtracking", "Backtracking", "Strings"],
    patterns: ["Backtracking with Constraints"],
    problem:
      "Given n pairs of parentheses, write a function that generates all combinations of well-formed parentheses.",
    examples: [
      {
        input: "n = 3",
        output: '["((()))","(()())","(())()","()(())","()()()"]',
        explanation: "These are all the valid strings that use 3 pairs.",
      },
    ],
    intuitionChallenges: [
      ch(
        "When can you add an opening parenthesis?",
        [
          "While fewer than n opening parentheses have been used",
          "Only at the start",
          "Never",
          "Only after a closing one",
        ],
        0,
        "Exactly! You may open as long as you have not used all n.",
        "How many opening parentheses are allowed in total?"
      ),
      ch(
        "When can you add a closing parenthesis?",
        [
          "Only when there are more opening than closing ones so far",
          "Always",
          "Only at the end",
          "Only when n is even",
        ],
        0,
        "Right! A closing parenthesis needs an open one to match.",
        "A closing parenthesis must have something to close."
      ),
    ],
    hints: [
      "A string is well-formed if no prefix has more closing than opening parentheses.",
      "Track how many opening and closing parentheses you have used so far.",
      "Add an opening parenthesis if you have used fewer than n.",
      "Add a closing parenthesis only if it would not exceed the number of opening ones; record the string when its length is 2n.",
    ],
    keyInsight:
      "Build the string character by character, adding an opening parenthesis while under n and a closing one only when it keeps the string valid.",
    bruteForceApproach: ap(
      "Generate all strings of 2n parentheses and test each one for validity",
      "O(2^(2n) · n)",
      "O(n)"
    ),
    optimalApproach: ap(
      "Backtracking that only builds valid prefixes",
      "O(4^n / √n)",
      "O(n)"
    ),
    patternName: "Backtracking with Constraints",
    transferQuestions: [
      tq(
        'n = 2, and the current string is "(".',
        "Which characters can be added next?",
        [
          "Either an opening or a closing parenthesis",
          "Only a closing parenthesis",
          "Only an opening parenthesis",
          "Neither",
        ],
        0
      ),
    ],
  }),

  p({
    slug: "letter-combinations-of-a-phone-number",
    title: "Letter Combinations of a Phone Number",
    difficulty: "Medium",
    topics: ["Recursion & Backtracking", "Backtracking", "Strings"],
    patterns: ["Backtracking over Choices"],
    problem:
      "Given a string containing digits from 2 to 9, return all the letter combinations that the number could represent, using the standard telephone keypad mapping (2 = abc, 3 = def, 4 = ghi, 5 = jkl, 6 = mno, 7 = pqrs, 8 = tuv, 9 = wxyz). Digit 1 maps to no letters.",
    examples: [
      {
        input: 'digits = "23"',
        output: '["ad","ae","af","bd","be","bf","cd","ce","cf"]',
        explanation: "Each letter of 2 is paired with each letter of 3.",
      },
    ],
    intuitionChallenges: [
      ch(
        "For each digit, how many letters can you choose from?",
        [
          "The 3 or 4 letters mapped to that digit",
          "Only one",
          "All 26 letters",
          "None",
        ],
        0,
        "Exactly! Each digit offers its own small set of letters.",
        "Look at the keypad: how many letters sit on each key?"
      ),
      ch(
        'How many combinations does "23" produce?',
        ["9", "6", "5", "12"],
        0,
        "Right! 3 letters for the digit 2 times 3 letters for the digit 3.",
        "Multiply the number of letters for each digit."
      ),
    ],
    hints: [
      "Each digit maps to a few letters.",
      "Choose one letter for the first digit, then solve the rest of the digits.",
      "The number of combinations is the product of the letter counts.",
      "Recurse by position: loop over the letters of the current digit, append one, recurse, and backtrack.",
    ],
    keyInsight:
      "Treat each digit as a decision point and try every mapped letter, building the combination one digit at a time.",
    bruteForceApproach: ap(
      "Generate every string of the right length from all 26 letters and filter",
      "O(26^n · n)",
      "O(n)"
    ),
    optimalApproach: ap("Backtracking over the digit positions", "O(4^n · n)", "O(n)"),
    patternName: "Backtracking over Choices",
    transferQuestions: [
      tq(
        'digits = "23", and the letter a has been chosen for the digit 2.',
        "Which letters can be chosen for the digit 3?",
        ["d, e or f", "a, b or c", "g, h or i", "Only d"],
        0
      ),
    ],
  }),

  p({
    slug: "n-queens",
    title: "N-Queens",
    difficulty: "Hard",
    topics: ["Recursion & Backtracking", "Backtracking"],
    patterns: ["Backtracking with Constraint Sets"],
    problem:
      "Place n queens on an n × n chessboard so that no two queens attack each other, meaning no two share a row, a column or a diagonal. Return all distinct solutions.",
    examples: [
      {
        input: "n = 4",
        output: "2 distinct solutions",
        explanation: "There are exactly two ways to place 4 queens safely on a 4 × 4 board.",
      },
    ],
    intuitionChallenges: [
      ch(
        "How many queens can be in each row?",
        ["Exactly one", "Up to n", "Zero or two", "Any number"],
        0,
        "Exactly! n queens in n rows with no row shared means one per row.",
        "Two queens in one row would attack each other."
      ),
      ch(
        "What do you need to track to know whether a square is attacked?",
        [
          "The used columns and both diagonals",
          "Only the row",
          "Only the column",
          "The board's colors",
        ],
        0,
        "Right! Rows are handled by placing one queen per row, so columns and diagonals remain.",
        "Which lines can a queen attack besides its row?"
      ),
    ],
    hints: [
      "Each row must have exactly one queen, so place queens row by row.",
      "For each row, try every column.",
      "A square is unsafe if its column or either diagonal already has a queen.",
      "Track used columns and diagonals (row - col and row + col) in sets; place, recurse, then remove the queen.",
    ],
    keyInsight:
      "Place one queen per row and track used columns and both diagonals, so conflicting squares are rejected immediately.",
    bruteForceApproach: ap(
      "Try every placement of n queens on the board and check all pairs",
      "O(C(n², n))",
      "O(n)"
    ),
    optimalApproach: ap(
      "Backtracking row by row with column and diagonal sets",
      "O(n!)",
      "O(n)"
    ),
    patternName: "Backtracking with Constraint Sets",
    transferQuestions: [
      tq(
        "A queen is placed at row 0, column 1 (counting from 0).",
        "Which diagonal values are now blocked?",
        [
          "row - col = -1 and row + col = 1",
          "row - col = 1 and row + col = -1",
          "row - col = 0 and row + col = 0",
          "row - col = 1 and row + col = 1",
        ],
        0
      ),
    ],
  }),

  p({
    slug: "word-search",
    title: "Word Search",
    difficulty: "Medium",
    topics: ["Recursion & Backtracking", "Backtracking", "Arrays"],
    patterns: ["DFS Backtracking on a Grid"],
    problem:
      "Given an m × n grid of characters board and a string word, return true if word exists in the grid. The word is built from letters of sequentially adjacent cells (horizontally or vertically neighbouring), and the same cell may not be used more than once in a word.",
    examples: [
      {
        input: 'board = [["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], word = "ABCCED"',
        output: "true",
        explanation: "The path A, B, C, C, E, D uses adjacent cells without reusing any.",
      },
    ],
    intuitionChallenges: [
      ch(
        "From a matching cell, which cells can you move to next?",
        [
          "Its up, down, left and right neighbours",
          "Any cell in the grid",
          "Only the cell to the right",
          "Diagonal cells only",
        ],
        0,
        "Exactly! Adjacent means the four side-by-side neighbours.",
        "Re-read how the word is formed from adjacent cells."
      ),
      ch(
        "Why must you mark a cell as visited while exploring a path?",
        [
          "So the same cell is not used twice in one word",
          "To speed up sorting",
          "To change the letter",
          "To count the cells",
        ],
        0,
        "Right! A cell can appear at most once in a path.",
        "The problem forbids reusing a cell within one word."
      ),
    ],
    hints: [
      "The word must be traced through adjacent cells.",
      "Try every cell as a starting point.",
      "From a cell, check that its letter matches, then explore the four neighbours for the next letter.",
      "Mark the cell visited before recursing and unmark it afterward (backtrack); return true when all letters match.",
    ],
    keyInsight:
      "Run a depth-first search from each cell, marking cells used on the current path and un-marking them when backtracking.",
    bruteForceApproach: ap(
      "Enumerate every path through the grid and compare it with the word",
      "Exponential",
      "O(m · n)"
    ),
    optimalApproach: ap(
      "DFS with backtracking that stops as soon as a letter mismatches",
      "O(m · n · 3^L) for a word of length L",
      "O(L)"
    ),
    patternName: "DFS Backtracking on a Grid",
    transferQuestions: [
      tq(
        'word = "ABC". The search has explored a path from a matching A and returned from a dead end.',
        "When do you un-mark a visited cell?",
        [
          "After exploring all neighbours from it (backtracking)",
          "Never",
          "Before checking its letter",
          "Only at the very end of the program",
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