// Seeds DSA World problems. This batch: Sorting (8) + 3Sum + Find All Numbers Disappeared (2).
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
  // ARRAYS (leftovers)
  // ====================================================

  p({
    slug: "3sum",
    title: "3Sum",
    difficulty: "Medium",
    topics: ["Arrays", "Two Pointers", "Sorting"],
    patterns: ["Sort + Two Pointers"],
    problem:
      "Given an integer array nums, return all unique triplets [nums[i], nums[j], nums[k]] with i, j and k all different, such that the three numbers add up to 0. The answer must not contain duplicate triplets.",
    examples: [
      {
        input: "nums = [-1,0,1,2,-1,-4]",
        output: "[[-1,-1,2],[-1,0,1]]",
        explanation: "Both triplets sum to 0, and no triplet is repeated.",
      },
    ],
    intuitionChallenges: [
      ch(
        "If you fix one number, the rest becomes finding two numbers with a given sum. What helps when the array is sorted?",
        [
          "Two pointers moving in from both ends",
          "A third nested loop",
          "Binary search on the total of all numbers",
          "Reversing the array",
        ],
        0,
        "Exactly! A sorted array lets two pointers home in on the target sum.",
        "Think about how sortedness tells you which pointer to move."
      ),
      ch(
        "How do you avoid reporting duplicate triplets?",
        [
          "Skip repeated values after sorting",
          "Ignore the problem",
          "Use only positive numbers",
          "Shuffle the array",
        ],
        0,
        "Right! After sorting, equal values sit next to each other and can be skipped.",
        "Where do equal values end up after sorting?"
      ),
    ],
    hints: [
      "Sorting makes duplicates easy to spot and enables pointer tricks.",
      "Fix the first number, then look for two numbers that add up to its negative.",
      "For the rest of the array, use one pointer at each end and move them based on the sum.",
      "After finding a triplet or moving a pointer, skip equal neighbours to avoid duplicates.",
    ],
    keyInsight:
      "Sort, fix one number, then use two pointers to find the other two, skipping repeated values.",
    bruteForceApproach: ap("Check every group of three numbers", "O(n³)", "O(1) extra"),
    optimalApproach: ap(
      "Sort, fix one number, then sweep two pointers over the rest",
      "O(n²)",
      "O(1) extra"
    ),
    patternName: "Sort + Two Pointers",
    transferQuestions: [
      tq(
        "Sorted nums = [-4,-1,-1,0,1,2]. The fixed number is -1 (index 1), left is at index 2 (value -1) and right is at index 5 (value 2).",
        "The sum is -1 + -1 + 2 = 0. What do you do next?",
        [
          "Record the triplet and move both pointers inward, skipping duplicates",
          "Stop, the answer is complete",
          "Move only the right pointer outward",
          "Discard the triplet as a duplicate",
        ],
        0
      ),
    ],
  }),

  p({
    slug: "find-all-numbers-disappeared-in-an-array",
    title: "Find All Numbers Disappeared in an Array",
    difficulty: "Easy",
    topics: ["Arrays", "Hashing"],
    patterns: ["In-Place Index Marking"],
    problem:
      "Given an array nums of n integers where every nums[i] is in the range [1, n], return all the integers in [1, n] that do not appear in nums.",
    examples: [
      {
        input: "nums = [4,3,2,7,8,2,3,1]",
        output: "[5,6]",
        explanation: "The numbers 5 and 6 are missing from the array.",
      },
    ],
    intuitionChallenges: [
      ch(
        "Every value is between 1 and n. What does that let you do?",
        [
          "Use the array's own indexes to mark which values were seen",
          "Sort using only comparisons",
          "Binary search for each missing number",
          "Ignore the range",
        ],
        0,
        "Exactly! The values 1..n line up with the indexes 0..n-1.",
        "What do the allowed values have in common with the array's indexes?"
      ),
      ch(
        "How can you mark that value v was seen without any extra space?",
        [
          "Make the number at index v - 1 negative",
          "Delete the number v",
          "Add v to a second array",
          "Swap v with the first element every time",
        ],
        0,
        "Right! A negative sign records a visit while keeping the original value readable.",
        "You need a flag stored in the array itself."
      ),
    ],
    hints: [
      "The values 1..n line up perfectly with the indexes 0..n-1.",
      "A value v can point to index v - 1.",
      "Mark the pointed-to position, for example by making it negative.",
      "After marking, any index that is still positive means the number index + 1 is missing.",
    ],
    keyInsight:
      "Treat each value as a pointer to an index and mark it; unmarked positions reveal the missing numbers.",
    bruteForceApproach: ap(
      "For each number from 1 to n, search the array for it",
      "O(n²)",
      "O(1)"
    ),
    optimalApproach: ap(
      "Mark seen values by negating positions, then collect the positive ones",
      "O(n)",
      "O(1) extra"
    ),
    patternName: "In-Place Index Marking",
    transferQuestions: [
      tq(
        "nums = [2,2,3]. After marking, index 0 is still positive while indexes 1 and 2 are negative.",
        "Which number is missing?",
        ["0", "1", "2", "3"],
        1
      ),
    ],
  }),

  // ====================================================
  // SORTING
  // ====================================================

  p({
    slug: "sort-colors",
    title: "Sort Colors",
    difficulty: "Medium",
    topics: ["Sorting", "Arrays", "Two Pointers"],
    patterns: ["Dutch National Flag"],
    problem:
      "Given an array nums containing only 0, 1 and 2 (red, white and blue), sort it in place so that equal values are next to each other in the order 0, 1, 2. Do not use the library sort function.",
    examples: [
      {
        input: "nums = [2,0,2,1,1,0]",
        output: "[0,0,1,1,2,2]",
        explanation: "All 0s come first, then the 1s, then the 2s.",
      },
    ],
    intuitionChallenges: [
      ch(
        "There are only three distinct values. What does that allow?",
        [
          "A single pass that keeps three regions",
          "Needing a full comparison sort",
          "Binary search",
          "Hashing every element",
        ],
        0,
        "Exactly! With only three values you can sort by sending each element to its region.",
        "Fewer distinct values means you can do better than a general sort."
      ),
      ch(
        "You see a 2 at the current position. What do you do?",
        [
          "Swap it into the end region and do not advance, because the swapped-in value is unchecked",
          "Swap it to the front",
          "Skip it",
          "Remove it",
        ],
        0,
        "Right! The value you swap in from the end has not been examined yet.",
        "The element you bring in from the back is still unknown."
      ),
    ],
    hints: [
      "Only 0, 1 and 2 exist, so you do not need a general sort.",
      "Think of three zones: zeros at the front, twos at the back, ones in the middle.",
      "Use three pointers: low (next slot for 0), mid (current) and high (next slot for 2).",
      "Swap 0s to low, 2s to high, and move mid past 1s.",
    ],
    keyInsight:
      "Maintain three zones with pointers and swap each element into its zone in a single pass.",
    bruteForceApproach: ap("Use a general comparison sort", "O(n log n)", "O(1)"),
    optimalApproach: ap("Dutch national flag: one pass with three pointers", "O(n)", "O(1)"),
    patternName: "Dutch National Flag",
    transferQuestions: [
      tq(
        "nums = [2,0,1] with low = 0, mid = 0, high = 2, and nums[mid] is 2.",
        "After swapping nums[mid] with nums[high], what is the array and what happens to mid?",
        [
          "[1,0,2], and mid stays at 0",
          "[1,0,2], and mid moves to 1",
          "[2,0,1], and mid moves to 1",
          "[0,2,1], and mid stays at 0",
        ],
        0
      ),
    ],
  }),

  p({
    slug: "merge-intervals",
    title: "Merge Intervals",
    difficulty: "Medium",
    topics: ["Sorting", "Arrays"],
    patterns: ["Sort by Start"],
    problem:
      "Given an array of intervals where intervals[i] = [start, end], merge all overlapping intervals and return an array of non-overlapping intervals that cover all the input intervals.",
    examples: [
      {
        input: "intervals = [[1,3],[2,6],[8,10],[15,18]]",
        output: "[[1,6],[8,10],[15,18]]",
        explanation: "[1,3] and [2,6] overlap, so they merge into [1,6].",
      },
    ],
    intuitionChallenges: [
      ch(
        "Before merging, what should you do with the intervals?",
        [
          "Sort them by start time",
          "Sort them by length",
          "Reverse them",
          "Remove the shortest ones",
        ],
        0,
        "Exactly! Sorted by start, overlapping intervals end up next to each other.",
        "Overlaps are easiest to spot when intervals appear in order."
      ),
      ch(
        "When do two intervals, in sorted order, overlap?",
        [
          "The next start is at most the current end",
          "The next end is larger than the current end",
          "They have the same length",
          "The next start is greater than the current end",
        ],
        0,
        "Right! If the next one starts before the current one ends, they touch or overlap.",
        "Compare where one interval begins with where the previous one finishes."
      ),
    ],
    hints: [
      "Overlaps are easier to see when intervals appear in order.",
      "Sort the intervals by their start value.",
      "Compare each interval with the last merged one.",
      "If it starts before the last merged interval ends, extend that end; otherwise start a new merged interval.",
    ],
    keyInsight:
      "After sorting by start, you only need to compare each interval with the last merged one.",
    bruteForceApproach: ap(
      "Compare every pair and keep merging until nothing overlaps",
      "O(n²)",
      "O(n)"
    ),
    optimalApproach: ap("Sort by start, then merge in one pass", "O(n log n)", "O(n)"),
    patternName: "Sort by Start",
    transferQuestions: [
      tq(
        "Sorted intervals: [1,3] and [2,6]",
        "What does the merged interval look like?",
        ["[1,3]", "[2,6]", "[1,6]", "[1,2]"],
        2
      ),
    ],
  }),

  p({
    slug: "kth-largest-element-in-an-array",
    title: "Kth Largest Element in an Array",
    difficulty: "Medium",
    topics: ["Sorting", "Arrays", "Heap"],
    patterns: ["Min-Heap of Size k"],
    problem:
      "Given an integer array nums and an integer k, return the kth largest element in the array. It is the kth largest in sorted order, not the kth distinct value.",
    examples: [
      {
        input: "nums = [3,2,1,5,6,4], k = 2",
        output: "5",
        explanation: "Sorted in descending order the array is 6, 5, 4, 3, 2, 1, so the 2nd largest is 5.",
      },
    ],
    intuitionChallenges: [
      ch(
        "Which element are you looking for when k = 1?",
        ["The largest", "The smallest", "The median", "The first element"],
        0,
        "Exactly! The 1st largest is simply the maximum.",
        "k = 1 means the very top of the ranking."
      ),
      ch(
        "A min-heap of size k holds the k largest values seen so far. Which value sits on top?",
        [
          "The kth largest",
          "The largest",
          "The smallest of the whole array",
          "The median",
        ],
        0,
        "Right! The smallest of the k largest is exactly the kth largest.",
        "The top of a min-heap is the smallest value it holds."
      ),
    ],
    hints: [
      "You do not need the whole array sorted, only the kth position.",
      "Sorting works, but it does more work than necessary.",
      "Keep track of only the k largest values seen so far.",
      "Use a min-heap of size k: push each number, pop when the size exceeds k, and the top is the answer.",
    ],
    keyInsight:
      "Keep a min-heap of the k largest values; its smallest element is the kth largest overall.",
    bruteForceApproach: ap(
      "Sort the whole array and take the kth from the end",
      "O(n log n)",
      "O(1)"
    ),
    optimalApproach: ap("Min-heap of size k", "O(n log k)", "O(k)"),
    patternName: "Min-Heap of Size k",
    transferQuestions: [
      tq(
        "nums = [3,2,1,5,6,4], k = 2. After processing every number, the heap holds 5 and 6.",
        "Which value is on top of the min-heap?",
        ["5", "6", "4", "2"],
        0
      ),
    ],
  }),

  p({
    slug: "top-k-frequent-elements",
    title: "Top K Frequent Elements",
    difficulty: "Medium",
    topics: ["Sorting", "Arrays", "Hashing"],
    patterns: ["Frequency Map", "Bucket Sort"],
    problem:
      "Given an integer array nums and an integer k, return the k most frequent elements. You may return the answer in any order.",
    examples: [
      {
        input: "nums = [1,1,1,2,2,3], k = 2",
        output: "[1,2]",
        explanation: "1 appears three times and 2 appears twice, the two highest counts.",
      },
    ],
    intuitionChallenges: [
      ch(
        "What must you know about each value before you can rank them?",
        [
          "How many times it appears",
          "Its position",
          "Whether it is even",
          "Its square",
        ],
        0,
        "Exactly! Ranking by frequency needs a count for every value.",
        "The word 'frequent' tells you what to measure."
      ),
      ch(
        "A count can never be larger than n. What does that suggest?",
        [
          "Group values into buckets indexed by frequency",
          "Use recursion",
          "Use binary search",
          "Sort the values alphabetically",
        ],
        0,
        "Right! Frequencies live in the range 1 to n, so bucket indexes work.",
        "Small, bounded numbers can act as array indexes."
      ),
    ],
    hints: [
      "'Most frequent' needs counts first.",
      "Count every value with a hash map.",
      "Now you need the k values with the highest counts.",
      "Sort by count, use a heap of size k, or place values into buckets indexed by frequency and read from the top.",
    ],
    keyInsight:
      "Count frequencies first, then pick the k largest counts using a heap or frequency buckets.",
    bruteForceApproach: ap(
      "Count, then sort every distinct value by frequency",
      "O(n log n)",
      "O(n)"
    ),
    optimalApproach: ap("Count, then bucket values by frequency", "O(n)", "O(n)"),
    patternName: "Frequency Map + Buckets",
    transferQuestions: [
      tq(
        "nums = [4,4,4,5,5,6]",
        "After counting, which value goes into the bucket for frequency 2?",
        ["4", "5", "6", "None"],
        1
      ),
    ],
  }),

  p({
    slug: "meeting-rooms",
    title: "Meeting Rooms",
    difficulty: "Easy",
    topics: ["Sorting", "Arrays"],
    patterns: ["Sort by Start"],
    problem:
      "Given an array of meeting time intervals where intervals[i] = [start, end], determine whether a person could attend all the meetings, meaning no two meetings overlap.",
    examples: [
      {
        input: "intervals = [[0,30],[5,10],[15,20]]",
        output: "false",
        explanation: "The meeting [0,30] overlaps with both of the others.",
      },
    ],
    intuitionChallenges: [
      ch(
        "You sort the meetings by start time. What do you compare next?",
        [
          "Each meeting's start with the previous meeting's end",
          "Each meeting's length",
          "Only the first and last meetings",
          "The meeting names",
        ],
        0,
        "Exactly! Only neighbours in the sorted order can conflict.",
        "After sorting, which pairs could possibly overlap?"
      ),
      ch(
        "When does a person fail to attend all meetings?",
        [
          "A meeting starts before the previous one ends",
          "Two meetings have the same length",
          "The first meeting is long",
          "There are more than three meetings",
        ],
        0,
        "Right! An early start means they would need to be in two places at once.",
        "A conflict means two meetings share some time."
      ),
    ],
    hints: [
      "Overlaps only happen between meetings that are close together in time.",
      "Sort by start time so that neighbours are the only ones that can conflict.",
      "Compare each meeting with the one before it.",
      "If a start time is earlier than the previous end time, return false.",
    ],
    keyInsight: "After sorting by start time, only adjacent meetings can overlap.",
    bruteForceApproach: ap("Compare every pair of meetings", "O(n²)", "O(1)"),
    optimalApproach: ap("Sort by start, then check neighbours", "O(n log n)", "O(1) extra"),
    patternName: "Sort by Start",
    transferQuestions: [
      tq(
        "Sorted meetings: [1,4] and [3,6]",
        "Can the person attend both?",
        [
          "Yes, because 4 is greater than 3",
          "No, the second starts (3) before the first ends (4)",
          "Yes, because they are the same length",
          "No, the day is too long",
        ],
        1
      ),
    ],
  }),

  p({
    slug: "sort-an-array",
    title: "Sort an Array",
    difficulty: "Medium",
    topics: ["Sorting", "Arrays", "Divide and Conquer"],
    patterns: ["Merge Sort"],
    problem:
      "Given an array of integers nums, sort it in ascending order and return it. Do not use built-in sorting functions, and solve it in O(n log n) time.",
    examples: [
      {
        input: "nums = [5,2,3,1]",
        output: "[1,2,3,5]",
        explanation: "The array in ascending order.",
      },
    ],
    intuitionChallenges: [
      ch(
        "Merge sort splits the array in half, sorts each half, and then...",
        [
          "Merges the two sorted halves",
          "Reverses them",
          "Deletes duplicates",
          "Picks the median",
        ],
        0,
        "Exactly! Combining two sorted halves is the key step.",
        "What do you do once both halves are already sorted?"
      ),
      ch(
        "Why is merge sort O(n log n)?",
        [
          "It halves the array log n times, and each level does O(n) merging work",
          "It compares every pair of elements",
          "It sorts in a single pass",
          "It uses a hash map",
        ],
        0,
        "Right! log n levels, each costing about n work.",
        "Count the number of levels and the work done on each level."
      ),
    ],
    hints: [
      "An array of 0 or 1 elements is already sorted.",
      "Split the array into two halves and sort each half recursively.",
      "Two sorted halves can be combined in a single pass.",
      "Merge by repeatedly taking the smaller front element from either half.",
    ],
    keyInsight:
      "Divide the array in half, sort each half, then merge the two sorted halves in linear time.",
    bruteForceApproach: ap(
      "Bubble sort: repeatedly swap adjacent out-of-order pairs",
      "O(n²)",
      "O(1)"
    ),
    optimalApproach: ap("Merge sort", "O(n log n)", "O(n)"),
    patternName: "Merge Sort",
    transferQuestions: [
      tq(
        "The sorted halves are [1,4] and [2,3].",
        "What is the merged result?",
        ["[1,2,3,4]", "[1,4,2,3]", "[4,3,2,1]", "[1,2,4,3]"],
        0
      ),
    ],
  }),

  p({
    slug: "largest-number",
    title: "Largest Number",
    difficulty: "Medium",
    topics: ["Sorting", "Strings", "Arrays"],
    patterns: ["Custom Comparator"],
    problem:
      "Given a list of non-negative integers nums, arrange them so that they form the largest possible number, and return it as a string.",
    examples: [
      {
        input: "nums = [3,30,34,5,9]",
        output: '"9534330"',
        explanation: "Ordering the numbers as 9, 5, 34, 3, 30 gives the biggest result.",
      },
    ],
    intuitionChallenges: [
      ch(
        "Which of 3 and 30 should come first to build the biggest number?",
        [
          "3, because 330 is bigger than 303",
          "30, because it is the bigger number",
          "They are equal",
          "30, because it has more digits",
        ],
        0,
        "Exactly! Try both orders and keep the one that gives the larger result.",
        "Write out both combinations: 3 then 30, and 30 then 3."
      ),
      ch(
        "How should you compare two numbers a and b while sorting?",
        [
          "By comparing the strings a+b and b+a",
          "By their numeric values",
          "By their lengths",
          "By their last digits",
        ],
        0,
        "Right! Concatenate both ways and see which is larger.",
        "Plain numeric order fails, so compare the combined results instead."
      ),
    ],
    hints: [
      "Sorting by plain numeric value does not work: 3 should come before 30.",
      "Compare two numbers by trying both orders.",
      "Join them as strings: is a followed by b bigger than b followed by a?",
      "Sort with that rule and join the result; handle the all-zeros case by returning 0.",
    ],
    keyInsight:
      "Order two numbers a and b by whichever of a+b or b+a (as strings) is larger.",
    bruteForceApproach: ap(
      "Try every permutation of the numbers",
      "O(n! · n)",
      "O(n)"
    ),
    optimalApproach: ap("Sort with a custom string comparator", "O(n log n · k)", "O(n · k)"),
    patternName: "Custom Comparator",
    transferQuestions: [
      tq(
        "a = 9 and b = 34",
        "Which concatenation is bigger?",
        [
          "934 (9 before 34)",
          "349 (34 before 9)",
          "They are equal",
          "Cannot be compared",
        ],
        0
      ),
    ],
  }),

  p({
    slug: "insertion-sort-list",
    title: "Insertion Sort List",
    difficulty: "Medium",
    topics: ["Sorting", "Linked List"],
    patterns: ["Insertion Sort", "Dummy Node"],
    problem:
      "Given the head of a singly linked list, sort the list using insertion sort and return the head of the sorted list.",
    examples: [
      {
        input: "head = 4 -> 2 -> 1 -> 3",
        output: "1 -> 2 -> 3 -> 4",
        explanation: "Each node is inserted into its correct place in the sorted part.",
      },
    ],
    intuitionChallenges: [
      ch(
        "Insertion sort keeps part of the list sorted. What does each new node do?",
        [
          "It is inserted into the correct place in the sorted part",
          "It replaces the head",
          "It is deleted",
          "It swaps with the tail",
        ],
        0,
        "Exactly! Each node finds its spot in the already sorted section.",
        "The sorted part grows by one node each step. How does it grow?"
      ),
      ch(
        "Why is a dummy node useful here?",
        [
          "It lets you insert before the first real node without special cases",
          "It stores the answer",
          "It makes the algorithm O(n)",
          "It sorts the list for you",
        ],
        0,
        "Right! The dummy head removes the special case of inserting at the front.",
        "What is awkward about inserting a node before the current head?"
      ),
    ],
    hints: [
      "Build a new sorted list one node at a time.",
      "Take the next node from the original list.",
      "Find where it belongs in the sorted list by scanning from the front.",
      "Use a dummy head and relink pointers instead of moving values.",
    ],
    keyInsight:
      "Take nodes one at a time and relink each one into its correct position in a growing sorted list.",
    bruteForceApproach: ap(
      "Copy values into an array, sort it, and rebuild the list",
      "O(n log n)",
      "O(n)"
    ),
    optimalApproach: ap(
      "Insertion sort that relinks the nodes in place",
      "O(n²)",
      "O(1)"
    ),
    patternName: "Insertion Sort with a Dummy Node",
    transferQuestions: [
      tq(
        "The sorted part is 1 -> 3, and the next node to insert has value 2.",
        "Where does 2 go?",
        ["Before 1", "Between 1 and 3", "After 3", "It replaces 3"],
        1
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