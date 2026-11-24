import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'services/firebase_config_service.dart';
import 'services/hybrid_inference_engine.dart';
import 'services/inventory_repository.dart';
import 'services/offline_sync_service.dart';
import 'services/remote_config_service.dart';
import 'theme/neo_bento_theme.dart';
import 'widgets/analytics_dashboard_view.dart';
import 'widgets/copilot_view.dart';
import 'widgets/hybrid_mode_selector.dart';
import 'widgets/inventory_management_view.dart';
import 'widgets/judge_inspector_modal.dart';
import 'widgets/offline_simulator_banner.dart';
import 'widgets/scanner_view.dart';
import 'widgets/stock_pulse_logo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and foundational services
  final firebaseService = FirebaseConfigService();
  await firebaseService.initialize();

  // Initialize Inventory Catalog
  await InventoryRepository().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: firebaseService),
        ChangeNotifierProvider.value(value: RemoteConfigService()),
        ChangeNotifierProvider.value(value: HybridInferenceEngine()),
        ChangeNotifierProvider.value(value: InventoryRepository()),
        ChangeNotifierProvider.value(value: OfflineSyncService()),
      ],
      child: const StockPulseApp(),
    ),
  );
}

class StockPulseApp extends StatelessWidget {
  const StockPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockPulse Hybrid — Offline-First AI Operations Copilot',
      debugShowCheckedModeBanner: false,
      theme: NeoBentoTheme.darkTheme,
      home: const MainShellScreen(),
    );
  }
}

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedTabIndex = 0;

  final List<Widget> _views = const [
    AnalyticsDashboardView(),
    ScannerView(),
    CopilotView(),
    InventoryManagementView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopNavBar(context),
            // Offline Simulator Banner
            const OfflineSimulatorBanner(),
            // Main Content Area
            Expanded(child: _views[_selectedTabIndex]),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: Row(
        children: [
          // Custom Isometric Vector Logo
          const StockPulseLogo(
            size: 32,
            subtitle: 'Offline-First AI Operations',
          ),
          const SizedBox(width: 24),

          // Navigation Tabs
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14111827),
                      blurRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildNavTab(0, 'Analytics', Icons.dashboard_outlined),
                    _buildNavTab(1, 'Scanner', Icons.document_scanner_outlined),
                    _buildNavTab(2, 'Copilot', Icons.chat_bubble_outline_rounded),
                    _buildNavTab(3, 'Inventory', Icons.inventory_2_outlined),
                  ],
                ),
              ),
            ),
          ),

          // Hybrid Mode Selector in Top Bar
          const HybridModeSelector(),
          const SizedBox(width: 12),

          // Judge Inspector Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14111827),
                  blurRadius: 0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              tooltip: 'Judge & Architecture Inspector',
              icon: const Icon(Icons.shield_rounded, color: AppColors.cobaltBlue, size: 20),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const JudgeInspectorModal(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTab(int index, String title, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.border : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
