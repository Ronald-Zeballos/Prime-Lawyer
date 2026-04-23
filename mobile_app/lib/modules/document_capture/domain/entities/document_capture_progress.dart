enum DocumentCaptureStage {
  optimizingPages,
  recognizingText,
  generatingPdf,
  completed,
}

class DocumentCaptureProgress {
  const DocumentCaptureProgress({
    required this.stage,
    required this.completedSteps,
    required this.totalSteps,
  });

  final DocumentCaptureStage stage;
  final int completedSteps;
  final int totalSteps;

  double get fraction {
    if (totalSteps <= 0) {
      return 0;
    }

    final normalizedValue = completedSteps / totalSteps;

    if (normalizedValue < 0) {
      return 0;
    }

    if (normalizedValue > 1) {
      return 1;
    }

    return normalizedValue;
  }
}
