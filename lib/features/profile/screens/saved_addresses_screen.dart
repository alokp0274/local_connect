// features/profile/screens/saved_addresses_screen.dart
// Feature: User Profile & Account
//
// Manage saved addresses for service delivery locations.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});
  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  final List<Map<String, dynamic>> _addresses = [
    {'label': 'Home', 'address': '42, MG Road, Sector 14, New Delhi - 110001', 'icon': Icons.home_rounded, 'isDefault': true, 'tag': 'Home'},
    {'label': 'Office', 'address': 'Tower B, 5th Floor, Cyber City, Gurugram - 122002', 'icon': Icons.business_rounded, 'isDefault': false, 'tag': 'Work'},
    {'label': 'Gym', 'address': 'FitLife, Block C, Saket, New Delhi - 110017', 'icon': Icons.fitness_center_rounded, 'isDefault': false, 'tag': 'Other'},
  ];

  void _addAddress() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Add address form coming soon'),
      backgroundColor: AppTheme.surfaceElevated,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSM)),
    ));
  }

  void _setDefault(int index) {
    setState(() {
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i]['isDefault'] = i == index;
      }
    });
    HapticFeedback.selectionClick();
  }

  void _deleteAddress(int index) {
    final removed = _addresses[index];
    setState(() => _addresses.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${removed['label']} removed'),
      backgroundColor: AppTheme.surfaceElevated,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSM)),
      action: SnackBarAction(
        label: 'Undo', textColor: AppTheme.accentGold,
        onPressed: () => setState(() => _addresses.insert(index, removed)),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent, foregroundColor: Colors.white, elevation: 0,
        title: const Text('Saved Addresses'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAddress,
        backgroundColor: AppTheme.accentGold,
        icon: const Icon(Icons.add_rounded, color: AppTheme.textOnAccent),
        label: const Text('Add Address', style: TextStyle(color: AppTheme.textOnAccent, fontWeight: FontWeight.w700)),
      ),
      body: AnimatedMeshBackground(
        subtle: true,
        child: _addresses.isEmpty
            ? Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(color: AppTheme.accentTeal.withAlpha(15), shape: BoxShape.circle),
                    child: const Icon(Icons.location_off_rounded, size: 40, color: AppTheme.accentTeal),
                  ),
                  const SizedBox(height: 16),
                  Text('No saved addresses', style: tt.headlineMedium),
                  const SizedBox(height: 4),
                  Text('Add your home or office address', style: tt.bodyMedium?.copyWith(color: AppTheme.textMuted)),
                ]).animate().fadeIn(duration: 400.ms),
              )
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(pad, pad, pad, 100),
                itemCount: _addresses.length,
                itemBuilder: (context, index) {
                  final addr = _addresses[index];
                  final isDefault = addr['isDefault'] == true;
                  return GlassContainer(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    border: Border.all(
                      color: isDefault ? AppTheme.accentGold.withAlpha(80) : AppTheme.border,
                      width: isDefault ? 0.8 : 0.5,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold.withAlpha(20),
                                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                              ),
                              child: Icon(addr['icon'] as IconData, color: AppTheme.accentGold, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Text(addr['label'] as String, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentBlue.withAlpha(20),
                                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                      ),
                                      child: Text(addr['tag'] as String, style: const TextStyle(color: AppTheme.accentBlue, fontSize: 10, fontWeight: FontWeight.w600)),
                                    ),
                                    if (isDefault) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentGold.withAlpha(25),
                                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                        ),
                                        child: const Text('Default', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.accentGold)),
                                      ),
                                    ],
                                  ]),
                                  const SizedBox(height: 4),
                                  Text(addr['address'] as String, style: tt.bodyMedium?.copyWith(fontSize: 13, color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Map preview mock
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                            border: Border.all(color: AppTheme.border, width: 0.5),
                          ),
                          child: const Center(
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.map_rounded, color: AppTheme.textMuted, size: 18),
                              SizedBox(width: 6),
                              Text('Map Preview', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (!isDefault)
                              Expanded(child: _AddrAction(label: 'Set Default', icon: Icons.check_circle_outline_rounded, color: AppTheme.accentTeal,
                                onTap: () => _setDefault(index))),
                            if (!isDefault) const SizedBox(width: 8),
                            Expanded(child: _AddrAction(label: 'Edit', icon: Icons.edit_outlined, color: AppTheme.accentBlue, onTap: () {})),
                            const SizedBox(width: 8),
                            Expanded(child: _AddrAction(label: 'Delete', icon: Icons.delete_outline_rounded, color: AppTheme.accentCoral,
                              onTap: () => _deleteAddress(index))),
                          ],
                        ),
                      ],
                    ),
                  ).animate(delay: (index * 80).ms).fadeIn(duration: 300.ms).slideY(begin: 0.08);
                },
              ),
      ),
    );
  }
}

class _AddrAction extends StatelessWidget {
  final String label; final IconData icon; final Color color; final VoidCallback onTap;
  const _AddrAction({required this.label, required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onTap(); },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(color: color.withAlpha(50), width: 0.5),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
