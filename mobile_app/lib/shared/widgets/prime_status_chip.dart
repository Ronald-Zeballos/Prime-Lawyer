import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class PrimeStatusChip extends StatelessWidget {
  const PrimeStatusChip({
    super.key,
    required this.label,
    required this.palette,
  });

  final String label;
  final PrimeChipPalette palette;

  factory PrimeStatusChip.caseStatus({
    required String status,
    required String label,
  }) {
    return PrimeStatusChip(
      label: label,
      palette: PrimeChipStyles.caseStatus(status),
    );
  }

  factory PrimeStatusChip.knowledgeStatus({
    required String status,
    required String label,
  }) {
    return PrimeStatusChip(
      label: label,
      palette: PrimeChipStyles.knowledgeStatus(status),
    );
  }

  factory PrimeStatusChip.confidentiality({
    required String level,
    required String label,
  }) {
    return PrimeStatusChip(
      label: label,
      palette: PrimeChipStyles.confidentiality(level),
    );
  }

  factory PrimeStatusChip.neutral(String label) {
    return PrimeStatusChip(
      label: label,
      palette: PrimeChipStyles.neutral,
    );
  }

  factory PrimeStatusChip.accent(String label) {
    return PrimeStatusChip(
      label: label,
      palette: PrimeChipStyles.accent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: palette.foreground,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class PrimeChipPalette {
  const PrimeChipPalette({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}

class PrimeChipStyles {
  const PrimeChipStyles._();

  static const PrimeChipPalette neutral = PrimeChipPalette(
    background: AppTheme.neutralSoft,
    foreground: AppTheme.neutralText,
    border: AppTheme.softBorder,
  );

  static const PrimeChipPalette accent = PrimeChipPalette(
    background: AppTheme.softBeige,
    foreground: AppTheme.primaryNavy,
    border: AppTheme.softBorder,
  );

  static PrimeChipPalette caseStatus(String status) {
    switch (status.trim().toUpperCase()) {
      case 'OPEN':
        return const PrimeChipPalette(
          background: AppTheme.successSoft,
          foreground: AppTheme.successText,
          border: Color(0xFFCAE1CF),
        );
      case 'IN_PROGRESS':
        return const PrimeChipPalette(
          background: AppTheme.warningSoft,
          foreground: AppTheme.warningText,
          border: Color(0xFFE7D19E),
        );
      case 'CLOSED':
        return const PrimeChipPalette(
          background: AppTheme.infoSoft,
          foreground: AppTheme.infoText,
          border: Color(0xFFC5D6F0),
        );
      case 'ARCHIVED':
        return neutral;
      default:
        return accent;
    }
  }

  static PrimeChipPalette knowledgeStatus(String status) {
    switch (status.trim().toUpperCase()) {
      case 'PUBLISHED':
        return const PrimeChipPalette(
          background: AppTheme.successSoft,
          foreground: AppTheme.successText,
          border: Color(0xFFCAE1CF),
        );
      case 'IN_PROGRESS':
        return const PrimeChipPalette(
          background: AppTheme.warningSoft,
          foreground: AppTheme.warningText,
          border: Color(0xFFE7D19E),
        );
      case 'DRAFT':
        return accent;
      case 'EXCLUDED':
        return neutral;
      default:
        return const PrimeChipPalette(
          background: AppTheme.infoSoft,
          foreground: AppTheme.infoText,
          border: Color(0xFFC5D6F0),
        );
    }
  }

  static PrimeChipPalette confidentiality(String level) {
    switch (level.trim().toUpperCase()) {
      case 'CONFIDENTIAL':
        return const PrimeChipPalette(
          background: Color(0xFFF0E8DA),
          foreground: AppTheme.primaryNavy,
          border: AppTheme.softBorder,
        );
      case 'HIGHLY_CONFIDENTIAL':
        return const PrimeChipPalette(
          background: AppTheme.neutralSoft,
          foreground: AppTheme.primaryNavy,
          border: AppTheme.softBorder,
        );
      default:
        return accent;
    }
  }
}
