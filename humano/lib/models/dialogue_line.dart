class DialogueLine {
  final String speakerName;
  final String text;
  final String? characterImagePath;
  final String? backgroundImagePath;
  final DialogueSide side;

  const DialogueLine({
    required this.speakerName,
    required this.text,
    this.characterImagePath,
    this.backgroundImagePath,
    this.side = DialogueSide.right,
  });
}

enum DialogueSide { left, right }
