// Seeds DSA World problems. This batch: Trees (12).
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
  // TREES
  // ====================================================

  p({
    slug: "maximum-depth-of-binary-tree",
    title: "Maximum Depth of Binary Tree",
    difficulty: "Easy",
    topics: ["Trees", "Binary Tree", "DFS"],
    patterns: ["Recursive DFS"],
    problem:
      "Given the root of a binary tree, return its maximum depth: the number of nodes along the longest path from the root down to the farthest leaf.",
    examples: [
      {
        input: "root = [3,9,20,null,null,15,7]",
        output: "3",
        explanation: "The longest path is 3 -> 20 -> 15 (or 7), which has 3 nodes.",
      },
    ],
    intuitionChallenges: [
      ch(
        "The depth of a tree depends on the depths of its subtrees. How?",
        [
          "1 plus the larger of the left and right depths",
          "The sum of both depths",
          "The smaller of the two depths",
          "The number of leaves",
        ],
        0,
        "Exactly! The deeper subtree decides the depth, plus one for the root.",
        "The longest path goes through whichever side is deeper."
      ),
      ch(
        "What is the depth of an empty tree (null)?",
        ["0", "1", "-1", "Undefined"],
        0,
        "Right! An empty tree has no nodes, so its depth is 0.",
        "How many nodes does an empty tree have?"
      ),
    ],
    hints: [
      "A tree is a root plus a left subtree and a right subtree.",
      "The depth of the whole tree comes from its deeper subtree.",
      "An empty tree has depth 0.",
      "Return 1 + max(depth(left), depth(right)).",
    ],
    keyInsight:
      "A tree's depth is one more than the depth of its deeper subtree, with an empty tree having depth 0.",
    bruteForceApproach: ap(
      "List every root-to-leaf path and take the longest",
      "O(n · h)",
      "O(n)"
    ),
    optimalApproach: ap("Recursive depth-first search", "O(n)", "O(h)"),
    patternName: "Recursive DFS",
    transferQuestions: [
      tq(
        "Node 1 has a left child 2 and a right child 3. Node 2 has a left child 4.",
        "What is the maximum depth?",
        ["2", "3", "4", "1"],
        1
      ),
    ],
  }),

  p({
    slug: "invert-binary-tree",
    title: "Invert Binary Tree",
    difficulty: "Easy",
    topics: ["Trees", "Binary Tree", "DFS"],
    patterns: ["Recursive Swap"],
    problem:
      "Given the root of a binary tree, invert the tree (swap the left and right children at every node) and return its root.",
    examples: [
      {
        input: "root = [4,2,7,1,3,6,9]",
        output: "[4,7,2,9,6,3,1]",
        explanation: "The tree becomes a mirror image of itself.",
      },
    ],
    intuitionChallenges: [
      ch(
        "To mirror a tree, what do you do at every node?",
        [
          "Swap its left and right children",
          "Delete its children",
          "Swap its value with the root",
          "Sort its children",
        ],
        0,
        "Exactly! A mirror image swaps left and right everywhere.",
        "What changes between a tree and its mirror image?"
      ),
      ch(
        "After swapping at a node, what about the subtrees below it?",
        [
          "They must be inverted too",
          "They stay as they are",
          "They are removed",
          "Only the left one is inverted",
        ],
        0,
        "Right! Every subtree needs the same treatment.",
        "A mirror image must be mirrored all the way down."
      ),
    ],
    hints: [
      "A mirror image swaps left and right everywhere.",
      "Swap the two children of the current node.",
      "Every subtree must be mirrored as well.",
      "Recursively invert the left and right subtrees, and swap them.",
    ],
    keyInsight: "Swap the children of every node, recursively, to mirror the whole tree.",
    bruteForceApproach: ap("Build a brand-new mirrored tree by copying every node", "O(n)", "O(n)"),
    optimalApproach: ap("Swap the children in place, recursively", "O(n)", "O(h)"),
    patternName: "Recursive Swap",
    transferQuestions: [
      tq(
        "Node 2 has a left child 1 and a right child 3.",
        "After inverting this subtree, what are node 2's children?",
        ["Left 3, right 1", "Left 1, right 3", "Both 2", "No children"],
        0
      ),
    ],
  }),

  p({
    slug: "same-tree",
    title: "Same Tree",
    difficulty: "Easy",
    topics: ["Trees", "Binary Tree", "DFS"],
    patterns: ["Parallel DFS"],
    problem:
      "Given the roots of two binary trees p and q, check whether they are the same. Two trees are the same if they have identical structure and the nodes have the same values.",
    examples: [
      {
        input: "p = [1,2,3], q = [1,2,3]",
        output: "true",
        explanation: "Both trees have the same shape and the same values.",
      },
    ],
    intuitionChallenges: [
      ch(
        "Two trees are the same when their roots match and...",
        [
          "their left subtrees match and their right subtrees match",
          "only their left subtrees match",
          "they have the same height",
          "they have the same number of leaves",
        ],
        0,
        "Exactly! Same roots plus the same left and right subtrees.",
        "Every part of the structure must match, not just a summary of it."
      ),
      ch(
        "One node is null and the other is not. What does that mean?",
        [
          "The trees are different",
          "The trees are the same",
          "Keep comparing",
          "Swap them",
        ],
        0,
        "Right! A missing node in one tree means the structures differ.",
        "Structure must match exactly, including missing children."
      ),
    ],
    hints: [
      "Compare the trees node by node, in the same positions.",
      "If both nodes are null, they match.",
      "If only one is null, or the values differ, the trees differ.",
      "Recurse on the left pair and the right pair; both must match.",
    ],
    keyInsight:
      "Compare the two trees in lockstep: equal values at the roots and both pairs of subtrees equal.",
    bruteForceApproach: ap(
      "Convert both trees to lists with null markers and compare the lists",
      "O(n)",
      "O(n)"
    ),
    optimalApproach: ap("Recursive parallel DFS", "O(n)", "O(h)"),
    patternName: "Parallel DFS",
    transferQuestions: [
      tq(
        "Tree p: node 1 with a left child 2. Tree q: node 1 with a right child 2.",
        "Are they the same tree?",
        [
          "No, the child is on a different side",
          "Yes, the values are the same",
          "Yes, the size is the same",
          "Cannot tell",
        ],
        0
      ),
    ],
  }),

  p({
    slug: "symmetric-tree",
    title: "Symmetric Tree",
    difficulty: "Easy",
    topics: ["Trees", "Binary Tree", "DFS"],
    patterns: ["Mirror Comparison"],
    problem:
      "Given the root of a binary tree, check whether it is a mirror of itself (symmetric around its center).",
    examples: [
      {
        input: "root = [1,2,2,3,4,4,3]",
        output: "true",
        explanation: "The left and right halves are mirror images.",
      },
    ],
    intuitionChallenges: [
      ch(
        "In a symmetric tree, which two subtrees must mirror each other?",
        [
          "The left and right subtrees of the root",
          "The left subtree and itself",
          "Two leaves",
          "The root and its left child",
        ],
        0,
        "Exactly! Symmetry means the root's two sides are mirror images.",
        "A mirror splits the tree down the middle."
      ),
      ch(
        "To compare two mirrored nodes, whose children do you pair up?",
        [
          "The left child of one with the right child of the other",
          "Left with left",
          "Right with right",
          "Parents with children",
        ],
        0,
        "Right! In a mirror, left and right are reversed.",
        "Mirroring reverses left and right."
      ),
    ],
    hints: [
      "Mirror means left-right reversal.",
      "Compare the left subtree with the right subtree.",
      "Their root values must match, and the outside children must match each other, as must the inside children.",
      "Check (left.left, right.right) and (left.right, right.left) recursively.",
    ],
    keyInsight:
      "Two subtrees are mirrors if their roots match and each one's left child mirrors the other's right child.",
    bruteForceApproach: ap(
      "Copy and invert one side, then compare it to the other",
      "O(n)",
      "O(n)"
    ),
    optimalApproach: ap("Recursive mirror comparison", "O(n)", "O(h)"),
    patternName: "Mirror Comparison",
    transferQuestions: [
      tq(
        "The root has two children, both 2. The left 2 has a left child 3, and the right 2 has a right child 3.",
        "Is this tree symmetric?",
        [
          "Yes, the 3s are in mirror positions",
          "No, the 3s are on different sides",
          "No, the 2s differ",
          "Cannot tell",
        ],
        0
      ),
    ],
  }),

  p({
    slug: "binary-tree-level-order-traversal",
    title: "Binary Tree Level Order Traversal",
    difficulty: "Medium",
    topics: ["Trees", "Binary Tree", "BFS"],
    patterns: ["BFS with a Queue"],
    problem:
      "Given the root of a binary tree, return the level order traversal of its nodes' values: level by level, from left to right.",
    examples: [
      {
        input: "root = [3,9,20,null,null,15,7]",
        output: "[[3],[9,20],[15,7]]",
        explanation: "The nodes are grouped by their depth in the tree.",
      },
    ],
    intuitionChallenges: [
      ch(
        "Which structure processes nodes in the order they were discovered?",
        ["A queue", "A stack", "A hash map", "A heap"],
        0,
        "Exactly! A queue is first in, first out, which gives level-by-level order.",
        "Which structure serves the earliest item first?"
      ),
      ch(
        "How do you know where one level ends and the next begins?",
        [
          "Process exactly as many nodes as the queue held at the start of the level",
          "Count the leaves",
          "Look for null values",
          "Sort the queue",
        ],
        0,
        "Right! Freezing the queue size marks the level boundary.",
        "The queue mixes levels as you add children. How can you separate them?"
      ),
    ],
    hints: [
      "Level order means visiting all nodes at depth d before depth d + 1.",
      "A queue gives first-in, first-out order.",
      "Start with the root in the queue.",
      "For each level, take the current queue size, process that many nodes, and add their children.",
    ],
    keyInsight:
      "Use a queue and process it one level at a time by freezing the queue's size at the start of each level.",
    bruteForceApproach: ap(
      "Compute every node's depth with DFS, then group the nodes by depth",
      "O(n)",
      "O(n)"
    ),
    optimalApproach: ap("Breadth-first search with a queue", "O(n)", "O(n)"),
    patternName: "BFS with a Queue",
    transferQuestions: [
      tq(
        "Node 3 is the root and has children 9 and 20. The queue starts as [3].",
        "After processing the root level, which nodes are in the queue?",
        ["9 and 20", "3", "9 only", "20 and 3"],
        0
      ),
    ],
  }),

  p({
    slug: "validate-binary-search-tree",
    title: "Validate Binary Search Tree",
    difficulty: "Medium",
    topics: ["Trees", "Binary Search Tree", "DFS"],
    patterns: ["DFS with Bounds"],
    problem:
      "Given the root of a binary tree, determine whether it is a valid binary search tree: every node's left subtree contains only smaller keys, its right subtree contains only larger keys, and both subtrees are also valid.",
    examples: [
      {
        input: "root = [5,1,4,null,null,3,6]",
        output: "false",
        explanation: "The node 3 sits in the right subtree of 5 but is smaller than 5.",
      },
    ],
    intuitionChallenges: [
      ch(
        "Checking only that each node is bigger than its left child and smaller than its right child is not enough. Why?",
        [
          "A deeper node can still violate an ancestor's bound",
          "It is too slow",
          "Children can be equal",
          "Trees have no ancestors",
        ],
        0,
        "Exactly! The whole left subtree must be smaller, not just the direct child.",
        "Think about a node several levels down in the right subtree."
      ),
      ch(
        "As you go to the left child, what new bound do you pass down?",
        [
          "An upper bound equal to the current node's value",
          "A lower bound only",
          "Nothing",
          "The root's value always",
        ],
        0,
        "Right! Everything in the left subtree must be smaller than this node.",
        "Values on the left must stay below the current node."
      ),
    ],
    hints: [
      "Every node must fit within a range of allowed values.",
      "The root can be any value.",
      "Going left, nodes must be smaller than the parent; going right, larger.",
      "Pass (min, max) bounds down: the left child gets max = node.val, the right child gets min = node.val.",
    ],
    keyInsight:
      "Every node must lie strictly between the bounds inherited from all of its ancestors.",
    bruteForceApproach: ap(
      "For every node, check that all values in its left subtree are smaller and all in its right are larger",
      "O(n²)",
      "O(h)"
    ),
    optimalApproach: ap("DFS passing down min and max bounds", "O(n)", "O(h)"),
    patternName: "DFS with Bounds",
    transferQuestions: [
      tq(
        "Tree [5,1,4,null,null,3,6]. The node 3 is the left child of 4, and 4 is the right child of 5.",
        "Which rule makes the node 3 invalid?",
        [
          "It must be greater than 5, because it is in the right subtree of 5",
          "It must be less than 4",
          "It must be less than 1",
          "It must equal 4",
        ],
        0
      ),
    ],
  }),

  p({
    slug: "lowest-common-ancestor-of-a-binary-search-tree",
    title: "Lowest Common Ancestor of a BST",
    difficulty: "Medium",
    topics: ["Trees", "Binary Search Tree"],
    patterns: ["BST Property"],
    problem:
      "Given a binary search tree and two of its nodes p and q, find their lowest common ancestor: the lowest node that has both p and q as descendants (a node can be a descendant of itself).",
    examples: [
      {
        input: "root = [6,2,8,0,4,7,9,null,null,3,5], p = 2, q = 8",
        output: "6",
        explanation: "The nodes 2 and 8 are on different sides of 6, so 6 is their lowest common ancestor.",
      },
    ],
    intuitionChallenges: [
      ch(
        "At a node, both p and q are smaller than its value. Where is their lowest common ancestor?",
        [
          "In the left subtree",
          "In the right subtree",
          "At this node",
          "At the root, always",
        ],
        0,
        "Exactly! Smaller values live in the left subtree, so move left.",
        "A BST keeps smaller values on the left."
      ),
      ch(
        "When is the current node the lowest common ancestor?",
        [
          "When p and q are on different sides (or one of them equals the node)",
          "When both are smaller",
          "When both are larger",
          "Never",
        ],
        0,
        "Right! That is the point where the two paths split.",
        "What happens to the paths to p and q at their lowest common ancestor?"
      ),
    ],
    hints: [
      "A BST keeps smaller values on the left and larger values on the right.",
      "Compare p and q with the current node's value.",
      "If both are smaller, go left; if both are larger, go right.",
      "The first node where p and q split, or where one equals the node, is the answer.",
    ],
    keyInsight:
      "Walk down from the root; the first node where p and q fall on different sides is the lowest common ancestor.",
    bruteForceApproach: ap(
      "Ignore the BST ordering and search every node like a general tree",
      "O(n)",
      "O(h)"
    ),
    optimalApproach: ap("Walk down using the BST ordering", "O(h)", "O(1)"),
    patternName: "BST Property",
    transferQuestions: [
      tq(
        "The BST root is 6, with p = 2 and q = 8.",
        "Where do p and q lie compared with 6, and what is the answer?",
        [
          "On different sides, so 6 is the answer",
          "Both on the left, so go left",
          "Both on the right, so go right",
          "Both equal to 6",
        ],
        0
      ),
    ],
  }),

  p({
    slug: "diameter-of-binary-tree",
    title: "Diameter of Binary Tree",
    difficulty: "Easy",
    topics: ["Trees", "Binary Tree", "DFS"],
    patterns: ["DFS with a Global Maximum"],
    problem:
      "Given the root of a binary tree, return the length of its diameter: the longest path between any two nodes, which may or may not pass through the root. The length is measured in edges.",
    examples: [
      {
        input: "root = [1,2,3,4,5]",
        output: "3",
        explanation: "The path 4 -> 2 -> 1 -> 3 (or 5 -> 2 -> 1 -> 3) has 3 edges.",
      },
    ],
    intuitionChallenges: [
      ch(
        "The longest path that bends at a node uses...",
        [
          "The deepest path on its left plus the deepest path on its right",
          "Only its left depth",
          "The height of the whole tree",
          "The number of leaves",
        ],
        0,
        "Exactly! The path goes down on both sides of the node.",
        "A path that turns at a node goes down on both sides."
      ),
      ch(
        "Why track a global maximum while computing depths?",
        [
          "The best path might not pass through the root",
          "To count nodes",
          "To sort the tree",
          "To find leaves",
        ],
        0,
        "Right! Every node is a candidate for the path's turning point.",
        "The longest path could bend at any node, not just the root."
      ),
    ],
    hints: [
      "A path bends at some node, going down on both sides.",
      "At each node, the path length through it is left depth + right depth.",
      "Compute depths bottom-up, and update the best answer at every node.",
      "Return 1 + max(left, right) as the depth, and track the maximum of left + right.",
    ],
    keyInsight:
      "At every node, the longest path through it is its left depth plus its right depth; track the best over all nodes.",
    bruteForceApproach: ap(
      "For every node, compute the depths of both subtrees separately",
      "O(n²)",
      "O(h)"
    ),
    optimalApproach: ap(
      "A single DFS that returns depths and updates a global best",
      "O(n)",
      "O(h)"
    ),
    patternName: "DFS with a Global Maximum",
    transferQuestions: [
      tq(
        "The root 1 has a left subtree of depth 2 (node 2 with children 4 and 5) and a right subtree of depth 1 (node 3).",
        "What is the length, in edges, of the longest path through the root?",
        ["2", "3", "4", "5"],
        1
      ),
    ],
  }),

  p({
    slug: "binary-tree-inorder-traversal",
    title: "Binary Tree Inorder Traversal",
    difficulty: "Easy",
    topics: ["Trees", "Binary Tree", "DFS"],
    patterns: ["Inorder Traversal"],
    problem:
      "Given the root of a binary tree, return the inorder traversal of its nodes' values: left subtree first, then the node itself, then the right subtree.",
    examples: [
      {
        input: "root = [1,null,2,3]",
        output: "[1,3,2]",
        explanation: "Node 1 has no left child, then comes 1, then the right subtree gives 3, 2.",
      },
    ],
    intuitionChallenges: [
      ch(
        "In an inorder traversal, when is a node's value visited?",
        [
          "After its left subtree and before its right subtree",
          "Before both subtrees",
          "After both subtrees",
          "Only for leaves",
        ],
        0,
        "Exactly! Inorder means left, node, right.",
        "The name tells you where the node sits relative to its subtrees."
      ),
      ch(
        "What does an inorder traversal of a binary search tree produce?",
        [
          "Values in sorted order",
          "Values in reverse order",
          "Values level by level",
          "Values in random order",
        ],
        0,
        "Right! A BST's ordering makes inorder traversal come out sorted.",
        "Smaller values are on the left and larger on the right."
      ),
    ],
    hints: [
      "Inorder means left, then node, then right.",
      "Recursion handles it naturally: traverse left, record the value, traverse right.",
      "An iterative version uses a stack.",
      "Push nodes while going left, pop and record, then move to the right child.",
    ],
    keyInsight:
      "Visit the left subtree, then the node, then the right subtree; a stack can replace the recursion.",
    bruteForceApproach: ap("Recursive traversal using the call stack", "O(n)", "O(h)"),
    optimalApproach: ap(
      "Iterative traversal with an explicit stack (or Morris traversal for O(1) space)",
      "O(n)",
      "O(h)"
    ),
    patternName: "Inorder Traversal",
    transferQuestions: [
      tq(
        "The root 2 has a left child 1 and a right child 3.",
        "What is the inorder traversal?",
        ["[1,2,3]", "[2,1,3]", "[1,3,2]", "[3,2,1]"],
        0
      ),
    ],
  }),

  p({
    slug: "kth-smallest-element-in-a-bst",
    title: "Kth Smallest Element in a BST",
    difficulty: "Medium",
    topics: ["Trees", "Binary Search Tree", "DFS"],
    patterns: ["Inorder Traversal on a BST"],
    problem:
      "Given the root of a binary search tree and an integer k, return the kth smallest value (counting from 1) among all the nodes' values.",
    examples: [
      {
        input: "root = [3,1,4,null,2], k = 1",
        output: "1",
        explanation: "The smallest value in the tree is 1.",
      },
    ],
    intuitionChallenges: [
      ch(
        "Which traversal visits the values of a BST in increasing order?",
        ["Inorder", "Preorder", "Postorder", "Level order"],
        0,
        "Exactly! Inorder gives sorted order for a BST.",
        "Which traversal visits left, then node, then right?"
      ),
      ch(
        "When can you stop the traversal?",
        [
          "As soon as you have visited k nodes",
          "After visiting all nodes",
          "At the first leaf",
          "Never",
        ],
        0,
        "Right! The kth visited node is the answer, so there is no need to go further.",
        "You only need the kth value in order."
      ),
    ],
    hints: [
      "A BST has a built-in ordering.",
      "Inorder traversal produces the values in sorted order.",
      "You only need the kth value visited.",
      "Do an inorder traversal, count nodes as you visit them, and return when the count reaches k.",
    ],
    keyInsight:
      "Inorder traversal of a BST gives sorted order, so the kth visited node is the kth smallest.",
    bruteForceApproach: ap(
      "Collect all values, sort them, and take the kth",
      "O(n log n)",
      "O(n)"
    ),
    optimalApproach: ap("Inorder traversal that stops at the kth node", "O(h + k)", "O(h)"),
    patternName: "Inorder Traversal on a BST",
    transferQuestions: [
      tq(
        "The BST has root 3, left child 1 (with a right child 2) and right child 4. Its inorder order is 1, 2, 3, 4.",
        "For k = 3, which value is returned?",
        ["2", "3", "4", "1"],
        1
      ),
    ],
  }),

  p({
    slug: "path-sum",
    title: "Path Sum",
    difficulty: "Easy",
    topics: ["Trees", "Binary Tree", "DFS"],
    patterns: ["DFS with a Remaining Sum"],
    problem:
      "Given the root of a binary tree and an integer targetSum, return true if the tree has a root-to-leaf path whose node values add up to targetSum. Otherwise return false.",
    examples: [
      {
        input: "root = [5,4,8,11,null,13,4,7,2,null,null,null,1], targetSum = 22",
        output: "true",
        explanation: "The path 5 -> 4 -> 11 -> 2 sums to 22.",
      },
    ],
    intuitionChallenges: [
      ch(
        "At each node, how do you update the target as you walk down?",
        [
          "Subtract the node's value from the remaining target",
          "Add the node's value",
          "Multiply it",
          "Keep it unchanged",
        ],
        0,
        "Exactly! The remaining target shrinks by each value you use.",
        "How much sum is still needed after using this node?"
      ),
      ch(
        "When is a path successful?",
        [
          "At a leaf, when the remaining target equals that leaf's value",
          "At any node with value 0",
          "At the root",
          "When the tree is empty",
        ],
        0,
        "Right! A valid path must end at a leaf and use up the target exactly.",
        "The path must go from the root all the way to a leaf."
      ),
    ],
    hints: [
      "A path must go from the root to a leaf.",
      "Track how much sum is still needed as you walk down.",
      "At a leaf, check whether the remaining amount equals the leaf's value.",
      "Recurse on both children and return true if either side succeeds.",
    ],
    keyInsight:
      "Subtract each node from the target as you descend; a leaf that uses up exactly the remaining amount completes a valid path.",
    bruteForceApproach: ap(
      "List every root-to-leaf path and add up each one",
      "O(n · h)",
      "O(n)"
    ),
    optimalApproach: ap("DFS carrying the remaining sum", "O(n)", "O(h)"),
    patternName: "DFS with a Remaining Sum",
    transferQuestions: [
      tq(
        "targetSum = 7. The path starts at the root 5 and its next node is the leaf 2.",
        "After visiting 5, what remaining target do you carry to the child 2?",
        ["2", "7", "12", "5"],
        0
      ),
    ],
  }),

  p({
    slug: "kth-largest-element-in-a-stream",
    title: "Kth Largest Element in a Stream",
    difficulty: "Easy",
    topics: ["Trees", "Heap", "Design"],
    patterns: ["Min-Heap of Size k"],
    problem:
      "Design a class KthLargest that is created with an integer k and an initial array nums. Its method add(val) adds val to the stream and returns the kth largest element among all numbers added so far.",
    examples: [
      {
        input: "k = 3, nums = [4,5,8,2], then add(3), add(5), add(10), add(9), add(4)",
        output: "4, 5, 5, 8, 8",
        explanation: "After each add, the third largest value of the stream is returned.",
      },
    ],
    intuitionChallenges: [
      ch(
        "You only care about the k largest values seen. What can you discard?",
        [
          "Everything smaller than the kth largest",
          "Everything larger",
          "Every other value",
          "Nothing",
        ],
        0,
        "Exactly! Smaller values can never become the kth largest again.",
        "Which values can never matter for the top k?"
      ),
      ch(
        "In a min-heap that holds the k largest values, which value is the kth largest?",
        [
          "The smallest one, at the top",
          "The largest",
          "The median",
          "The newest",
        ],
        0,
        "Right! The smallest of the k largest is the kth largest.",
        "The top of a min-heap is its smallest value."
      ),
    ],
    hints: [
      "The kth largest only depends on the k biggest values.",
      "Keep just those k values.",
      "A min-heap keeps its smallest value at the top.",
      "Add each new value; if the heap grows beyond k, remove the smallest; the top is the answer.",
    ],
    keyInsight:
      "Keep a min-heap of the k largest values; its top is always the kth largest.",
    bruteForceApproach: ap(
      "Store all values and sort them on every add",
      "O(n log n) per add",
      "O(n)"
    ),
    optimalApproach: ap("Min-heap of size k", "O(log k) per add", "O(k)"),
    patternName: "Min-Heap of Size k",
    transferQuestions: [
      tq(
        "k = 3 and the heap holds [4,5,8] (top is 4). The value 3 is added.",
        "What happens?",
        [
          "3 is discarded and the answer stays 4",
          "The answer becomes 3",
          "The heap grows to size 4",
          "The answer is 8",
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