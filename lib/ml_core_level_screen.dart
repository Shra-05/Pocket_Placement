import 'package:flutter/material.dart';
import 'theme_selection_screen.dart';
import 'core_subject_level_screen.dart';

class MLCoreLevelScreen extends StatelessWidget {
  final int level;
  final String title;
  final String subtitle;
  final String topic;
  final Color accentColor;
  final AppTheme theme;

  const MLCoreLevelScreen({
    super.key,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.topic,
    required this.accentColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final i = (level - 1).clamp(0, _levels.length - 1);
    final data = _levels[i];
    return CoreSubjectLevelScreen(
      theme: theme,
      level: level,
      subject: 'ML',
      title: title.isEmpty ? data.$1 : title,
      subtitle: subtitle.isEmpty ? data.$2 : subtitle,
      accentColor: accentColor,
      questions: data.$3,
      nextTitle: level < _levels.length ? 'Level ${level + 1}' : 'Complete',
    );
  }

  static const List<(String, String, List<CoreLearningQuestion>)> _levels = <(String, String, List<CoreLearningQuestion>)>[
    ("BIAS-VARIANCE", "Overfitting • Regularization", [ CoreLearningQuestion(
      title: "Bias-Variance Tradeoff", concept: "Bias-Variance Tradeoff", type: 'mcq',
      question: "If training accuracy is very high but testing accuracy is poor, which description and remedy is correct?", options: ["High bias, low variance; increase complexity.", "Low bias, high variance; use L1/L2 regularization or collect more data.", "High bias, high variance; disable scaling.", "Low bias, low variance; terminate training early."], correctOption: 1,
      explanation: "This is overfitting: low bias and high variance. Regularization, more data, or a simpler model can improve generalization.", animationTitle: "Bias-Variance Tradeoff",
      animationSteps: ["Training Fits", "High Variance", "Validation Error", "Regularization"],
    )]),
    ("MODEL EVALUATION", "Recall • False Negatives", [ CoreLearningQuestion(
      title: "Recall", concept: "Recall", type: 'mcq',
      question: "For a high-stakes binary classification task where minimizing false negatives is the priority, which metric should be optimized?", options: ["Precision", "Recall (Sensitivity)", "Accuracy", "Specificity"], correctOption: 1,
      explanation: "Recall focuses on identifying actual positives and is the appropriate metric when false negatives are especially costly.", animationTitle: "Recall",
      animationSteps: ["Actual Positive", "Prediction", "True Positive", "Recall"],
    )]),
    ("GRADIENT DESCENT", "Learning Rate • Convergence", [ CoreLearningQuestion(
      title: "Learning Rate", concept: "Learning Rate", type: 'mcq',
      question: "If the learning rate is set too high during gradient descent, what is likely to happen?", options: ["The cost decreases rapidly and always converges.", "The cost oscillates and may diverge instead of finding a minimum.", "The cost stays perfectly flat.", "The model becomes a random forest."], correctOption: 1,
      explanation: "A large learning rate can overshoot the minimum repeatedly, causing oscillation or divergence.", animationTitle: "Learning Rate",
      animationSteps: ["Loss Valley", "Step Too Large", "Overshoot", "Divergence"],
    )]),
    ("PCA", "Dimensionality Reduction • Variance", [ CoreLearningQuestion(
      title: "PCA Objective", concept: "PCA Objective", type: 'mcq',
      question: "What is the primary mathematical objective of PCA during dimensionality reduction?", options: ["Maximize class separation margin.", "Find orthogonal axes that maximize variance of projected data.", "Minimize the L1 norm of weights.", "Cluster data into exclusive centroids."], correctOption: 1,
      explanation: "PCA chooses orthogonal principal components that capture as much variance, and therefore information content, as possible.", animationTitle: "PCA Objective",
      animationSteps: ["High-D Data", "Principal Axis", "Maximum Variance", "Lower Dimension"],
    )]),
    ("L1 VS L2", "Regularization • Sparsity", [ CoreLearningQuestion(
      title: "L1 Regularization", concept: "L1 Regularization", type: 'mcq',
      question: "Why does L1 regularization tend to make some model coefficients exactly zero?", options: ["It uses a quadratic penalty with a smooth boundary.", "Its absolute-value penalty has sharp corners on axes, making solutions likely to hit zero-weight corners.", "It only applies to clustering.", "L2 is only for deep networks."], correctOption: 1,
      explanation: "L1 has a diamond-like constraint in two dimensions with corners on the axes, promoting sparse weights and feature selection.", animationTitle: "L1 Regularization",
      animationSteps: ["Weights", "L1 Diamond", "Axis Corner", "Zero Weight"],
    )]),
    ("LINEAR REGRESSION", "Fit • Predict • Evaluate", [ CoreLearningQuestion(
      title: "Simple Linear Regression", concept: "Simple Linear Regression", type: 'code',
      question: "Fill the blanks to train a linear regression model and generate predictions.", code: "from sklearn.linear_model import ____\n\nmodel = ____()\nmodel.____(X, y)\n\npredictions = model.____(X)\n", answers: ["LinearRegression", "LinearRegression", "fit", "predict"],
      explanation: "The source instantiates LinearRegression, fits it on X and y, then predicts with the trained model.", animationTitle: "Simple Linear Regression",
      animationSteps: ["Data", "Linear Model", "Fit", "Prediction"],
    )]),
    ("RANDOM FOREST PIPELINE", "Split • Scale • Classify", [ CoreLearningQuestion(
      title: "Classification Pipeline", concept: "Classification Pipeline", type: 'code',
      question: "Fill the blanks for the core steps of the Random Forest pipeline.", code: "X_train, X_test, y_train, y_test = train_test_split(\n    X, y, test_size=0.2, random_state=42\n)\n\nscaler = ____()\nX_train_scaled = scaler.____(X_train)\n\nrf_model = ____(\n    n_estimators=100, max_depth=6, random_state=42\n)\nrf_model.fit(X_train_scaled, y_train)\n", answers: ["StandardScaler", "fit_transform", "RandomForestClassifier"],
      explanation: "The source splits the data, standardizes features with StandardScaler, and trains a RandomForestClassifier.", animationTitle: "Classification Pipeline",
      animationSteps: ["Train/Test Split", "Scaling", "Random Forest", "Evaluation"],
    )]),
    ("GRADIENT DESCENT FROM SCRATCH", "NumPy • Loss • Updates", [ CoreLearningQuestion(
      title: "Batch Gradient Descent", concept: "Batch Gradient Descent", type: 'code',
      question: "Fill the blanks for prediction, MSE loss, and the weight update step.", code: "y_pred = np.____(X, self.weights) + self.bias\n\nloss = np.____((y_pred - y) ** 2)\n\nself.weights -= self.lr * dw\nself.bias -= self.lr * ____\n", answers: ["dot", "mean", "db"],
      explanation: "The source calculates predictions with np.dot, MSE with np.mean, and updates weights and bias using the computed gradients and learning rate.", animationTitle: "Batch Gradient Descent",
      animationSteps: ["Forward Pass", "MSE Loss", "Gradient", "Parameter Update"],
    )]),
    ("INTEGRATED CHALLENGE", "Review • Apply • Connect", [ CoreLearningQuestion(
      title: "Integrated Subject Challenge", concept: "Integrated Review", type: 'mcq',
      question: "Which approach best demonstrates that you can connect the key ideas from the completed levels of this subject?", options: ["Recall one isolated definition only.", "Apply the relevant concepts together to solve a problem.", "Skip the concepts and guess.", "Use an unrelated topic."], correctOption: 1,
      explanation: "This level revisits the ideas already covered in Levels 1–8 and checks whether they can be applied together.", animationTitle: "Integrated Challenge",
      animationSteps: ["Recall", "Connect", "Apply", "Verify"],
    )]),
    ("MASTER DEMO", "Progress • Completion • Next Level", [ CoreLearningQuestion(
      title: "Level 10 Demo", concept: "FINAL DEMO", type: 'mcq',
      question: "What does reaching Level 10 demonstrate in this project?", options: ["Only that the first level was opened.", "That the subject progression can continue through the final demo level.", "That no previous levels were completed.", "That the quiz has no progress tracking."], correctOption: 1,
      explanation: "Level 10 is intentionally a demo level for presentation. Completing it demonstrates the full Level 1 → Level 10 progression and completion flow.", animationTitle: "LEVEL 10 • MASTER DEMO",
      animationSteps: ["LEVEL 1", "LEVEL 5", "LEVEL 8", "LEVEL 10 ✓"],
    )]),
  ];
}
