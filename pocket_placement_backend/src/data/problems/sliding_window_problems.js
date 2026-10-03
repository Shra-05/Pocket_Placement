// Original Signal Stream problem - Intuition-First Design
// NO LeetCode/HackerRank reproduction - 100% original Pocket Placement content

const signalStreamProblem = {
  title: "Signal Stream",
  description:
    "A real-time signal monitoring system receives a continuous stream of integer signals. Your task is to identify the longest contiguous sequence of signals where each signal appears at most once. This represents finding stable periods in the signal without noise interference.",

  algorithmTopic: "sliding_window",
  difficulty: "beginner",

  problemStatement: {
    scenario:
      "Imagine you're monitoring a telecommunications network. Signals come in as a stream of integers (1-100). A 'clean signal' is one where consecutive readings don't repeat. You need to find the longest continuous period of clean signal for quality assessment.",

    constraints: [
      "Signals are integers between 1 and 100",
      "Stream length ranges from 1 to 1,000 signals",
      "Each signal is received sequentially (real-time)",
      "You must process signals once, in order",
    ],

    examples: [
      {
        input: "[1, 2, 3, 2, 1]",
        output: "3",
        explanation:
          "The longest subarray with no repeating signals is [1, 2, 3]. When we encounter the second 2, we must break the sequence.",
      },
      {
        input: "[5, 5, 5]",
        output: "1",
        explanation:
          "Each individual signal is valid, but as soon as we see a repeat, the clean signal ends.",
      },
      {
        input: "[1, 2, 3, 4, 5]",
        output: "5",
        explanation:
          "All signals are unique, so the entire stream is one clean signal period.",
      },
      {
        input: "[2, 1, 3, 2, 4, 3]",
        output: "3",
        explanation:
          "Subarray [1, 3, 2] or [3, 2, 4] both have length 3 with no repeats. We need to find the maximum.",
      },
    ],
  },

  intuitiveApproach:
    "Instead of checking every possible subarray (slow!), imagine a sliding window that expands as we add clean signals and shrinks when we encounter a repeat. We track which signals we've seen in our current window using a set. When a repeat appears, we remove signals from the left until the repeat is gone. This single pass through the stream gives us the answer efficiently.",

  keyInsights: [
    "A 'window' of signals moves through the stream—expand it when we can, shrink it when we hit a repeat",
    "Expanding the window adds one signal; shrinking removes one from the left",
    "We never move backward—each signal is processed once",
    "A set tracks which signals are currently in our window for O(1) lookup",
    "The answer is the largest window size we ever achieve",
  ],

  patternName: "Sliding Window with Hash Set",
  relatedPatterns: [
    "two_pointers",
    "hash_map_tracking",
    "greedy_expansion",
  ],

  timeComplexity: "O(n)",
  spaceComplexity: "O(min(n, k))",
  complexityExplanation:
    "Time: Each signal is visited at most twice (once by right pointer, once by left). Space: We store at most k unique signals in the window, where k is the alphabet size (100 signals). In the worst case, we store all n signals if they're all unique, so it's O(min(n, k)).",

  hints: [
    {
      level: 1,
      hint: "Think about this problem as a window that moves across the stream. You have two boundaries: left and right. Start both at position 0.",
      focusArea: "window_initialization",
    },
    {
      level: 2,
      hint: "Use a data structure (like a Set) to track which signals are currently visible in your window. This helps you instantly know if a signal is a repeat.",
      focusArea: "duplicate_detection",
    },
    {
      level: 3,
      hint: "When you encounter a repeated signal, shrink the window from the left until the duplicate is removed. Then you can safely expand again on the right.",
      focusArea: "window_shrinking",
    },
  ],

  commonMistakes: [
    {
      mistake: "Using a nested loop to check all subarrays (brute force)",
      why: "This takes O(n²) time. You'd check every possible subarray, which is slow for large streams.",
      correction:
        "Use a sliding window approach. Expand and shrink in a single pass—O(n) is much faster.",
    },
    {
      mistake: "Forgetting to shrink the window when you see a repeat",
      why: "If you just skip ahead, you miss potential longer windows and may process signals incorrectly.",
      correction:
        "Always shrink from the left when a duplicate appears. Move the left pointer until the duplicate is gone.",
    },
    {
      mistake: "Using a list to track seen signals instead of a set",
      why: "Checking if a signal is in a list is O(n) for each check. A set is O(1).",
      correction:
        "Use a Set (or HashSet) to store signals in the current window for O(1) duplicate detection.",
    },
    {
      mistake: "Not updating your answer (max window length) after each expansion",
      why: "You might find a long window but forget to record it as the maximum.",
      correction:
        "After every right expansion, compare the current window size to your max and update if needed.",
    },
  ],

  optimalApproach: {
    name: "Sliding Window with Two Pointers",
    steps: [
      "Initialize two pointers (left = 0, right = 0) and an empty set to track signals in the window",
      "Expand right: Add the signal at position right to your set, move right pointer forward",
      "If the signal is a duplicate (already in set), shrink from left by removing signals one by one until the duplicate is gone",
      "After each expansion, update your maximum window length",
      "Continue until right reaches the end of the stream",
      "Return the maximum window length found",
    ],
    pseudocode: `
function longestCleanSignal(signals):
    left = 0
    maxLength = 0
    seenSignals = empty Set
    
    for right from 0 to length(signals) - 1:
        while signals[right] is in seenSignals:
            remove signals[left] from seenSignals
            left = left + 1
        
        add signals[right] to seenSignals
        maxLength = max(maxLength, right - left + 1)
    
    return maxLength
    `,
  },

  visualizationData: {
    exampleInput: [1, 2, 3, 2, 1],
    windowSteps: [
      {
        step: 1,
        left: 0,
        right: 0,
        window: [1],
        seenSignals: [1],
        maxLength: 1,
        action: "Expand: add signal 1",
      },
      {
        step: 2,
        left: 0,
        right: 1,
        window: [1, 2],
        seenSignals: [1, 2],
        maxLength: 2,
        action: "Expand: add signal 2",
      },
      {
        step: 3,
        left: 0,
        right: 2,
        window: [1, 2, 3],
        seenSignals: [1, 2, 3],
        maxLength: 3,
        action: "Expand: add signal 3 (NEW MAX!)",
      },
      {
        step: 4,
        left: 0,
        right: 3,
        window: "[1, 2, 3] → DUPLICATE 2 DETECTED",
        seenSignals: null,
        maxLength: 3,
        action: "Shrink: remove signal 1 (left++)",
      },
      {
        step: 5,
        left: 1,
        right: 3,
        window: "[2, 3] → DUPLICATE 2 DETECTED",
        seenSignals: null,
        maxLength: 3,
        action: "Shrink: remove signal 2 (left++)",
      },
      {
        step: 6,
        left: 2,
        right: 3,
        window: [3, 2],
        seenSignals: [3, 2],
        maxLength: 3,
        action: "Expand: now safe to add 2",
      },
      {
        step: 7,
        left: 2,
        right: 4,
        window: "[3, 2, 1]",
        seenSignals: "[3, 2, 1]",
        maxLength: 3,
        action: "Expand: add signal 1 (safe, no duplicate)",
      },
    ],
  },

  followUpQuestions: [
    {
      question:
        "What if the stream is very large (millions of signals)? Can we optimize further?",
      approach:
        "The O(n) sliding window is already optimal for this problem. You process each signal once. If you need to answer multiple queries on the same stream, consider caching results.",
    },
    {
      question:
        "What if we allow at most k repeated signals instead of 0 repeats?",
      approach:
        "Modify the approach: instead of shrinking when you see a duplicate, count occurrences. Shrink only when a signal appears more than k times. Use a frequency map instead of a set.",
    },
    {
      question:
        "How would you find all the longest clean signal periods (not just the length)?",
      approach:
        "Track the start and end indices of each window when you update maxLength. Store all windows with that maximum length.",
    },
    {
      question:
        "What if signals come as a stream and you must answer queries in real-time without storing the entire stream?",
      approach:
        "Use a sliding window as described, but only keep the current window in memory. Trade off: you can answer the query for signals up to the current position, but can't re-query past signals.",
    },
  ],

  createdBy: "Pocket Placement",
  isActive: true,
  version: 1,
};

module.exports = {
  signalStreamProblem,
};