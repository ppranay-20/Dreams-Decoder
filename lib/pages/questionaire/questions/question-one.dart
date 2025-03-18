import 'package:flutter/material.dart';

class QuestionOne extends StatelessWidget {
  final List<String> selectedEmotions;
  final Function(List<String>) onChanged;

  const QuestionOne({
    super.key,
    required this.selectedEmotions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "1. How did this dream make you feel?",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 16),

        // First row of emotions
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildEmotionChip("😌 Calm", "Calm"),
            _buildEmotionChip("😊 Happy", "Happy"),
            _buildEmotionChip("⚡ Energetic", "Energetic"),
          ],
        ),

        SizedBox(height: 8),

        // Second row of emotions
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildEmotionChip("😜 Frisky", "Frisky"),
            _buildEmotionChip("🔄 Mood Swings", "Mood Swings"),
          ],
        ),

        SizedBox(height: 8),

        // Third row of emotions
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildEmotionChip("😠 Irritated", "Irritated"),
            _buildEmotionChip("😢 Sad", "Sad"),
            _buildEmotionChip("😰 Anxious", "Anxious"),
          ],
        ),
      ],
    );
  }

  Widget _buildEmotionChip(String label, String value) {
    final isSelected = selectedEmotions.contains(value);

    return InkWell(
      onTap: () {
        // Create a new list to avoid modifying the original list directly
        List<String> updatedEmotions = List.from(selectedEmotions);

        if (isSelected) {
          updatedEmotions.remove(value);
        } else {
          updatedEmotions.add(value);
        }

        // Call the callback with the updated list
        onChanged(updatedEmotions);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF8B2359) : Color(0xFF180C12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color(0xFF8B2359),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
