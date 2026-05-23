import 'package:flutter/material.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildShortcutItem(String keys, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              keys,
              style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(description),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInstructionItem(String instruction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0, right: 8.0),
            child: Icon(Icons.circle, size: 6, color: Colors.white54),
          ),
          Expanded(child: Text(instruction)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            // Title Bar
            Container(
              color: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text('Help & Shortcuts', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  _buildSectionTitle(context, 'Main Shortcuts'),
                  _buildShortcutItem('Q', 'Open song search'),
                  _buildShortcutItem('S', 'Open scripture search'),
                  _buildShortcutItem('L', 'Jump to slides section'),

                  const Divider(height: 32),
                  _buildSectionTitle(context, 'Bible Search Shortcuts'),
                  _buildShortcutItem('Enter + Enter', 'Immediately display the searched verse (if exists)'),
                  _buildShortcutItem('Enter + Tab + Enter', 'Add the verse to slides but avoid immediate display'),

                  const Divider(height: 32),
                  _buildSectionTitle(context, 'SetList Shortcuts'),
                  _buildInstructionItem('Click the SetList item to move the scroll to related slide in slides pane'),
                  _buildShortcutItem('Enter', 'Press on the SetList item to display the related slide in live screens'),

                  const Divider(height: 32),
                  _buildSectionTitle(context, 'Slides Shortcuts'),
                  _buildShortcutItem('Tab', 'Jump to next immediate blank screens and next blank screens'),
                  _buildShortcutItem('Space bar', 'Jump to next immediate slide'),
                  _buildShortcutItem('V1, C, etc.', 'Jump to specific slide in the songs (e.g., Verse 1, Chorus)'),
                  _buildShortcutItem('F', 'Freeze and unfreeze slides'),

                  const Divider(height: 32),
                  _buildSectionTitle(context, 'General Usage'),
                  _buildInstructionItem('Add/Edit/Delete SetList names and options from the "Manage Setlists" menu in the top bar.'),
                  _buildInstructionItem('Modify presentation settings via Settings -> Presentation Settings in the top bar.'),
                  _buildInstructionItem('Change settings of Monitors (monitor 1 and 2) using the monitor bottom bar and general settings.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
