import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/copilot_message.dart';
import '../services/hybrid_inference_engine.dart';
import '../services/inventory_repository.dart';
import 'bento_card.dart';
import 'hybrid_routing_visualizer.dart';
import 'telemetry_badge.dart';

class CopilotView extends StatefulWidget {
  const CopilotView({super.key});

  @override
  State<CopilotView> createState() => _CopilotViewState();
}

class _CopilotViewState extends State<CopilotView> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<CopilotMessage> _messages = [];
  bool _isAwaitingResponse = false;

  final List<String> _quickPrompts = [
    'Log 15 units of Trail Runner X9, flag low stock below 5, and summarize today margin',
    'Registrar 20 unidades de TR-X9 con umbral mínimo 5',
    'Auditar productos con bajo stock y calcular reposición',
    'Check all items with stock under minimum threshold and calculate reorder cost',
    'Audit Bay 12 for missing thermal labels and update inventory',
    'Perform deep margin analysis across all warehouse shoe categories',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      CopilotMessage(
        id: 'welcome-001',
        sender: MessageSender.assistant,
        text: 'StockPulse Hybrid Copilot initialized. Operating in PREFER_ON_DEVICE mode (Gemini Nano 4 primary + Cloud Gemini 2.5 Flash fallback). Ask an inventory query or execute a natural warehouse command below.',
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _handleSend(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    _inputController.clear();

    final userMsg = CopilotMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: MessageSender.user,
      text: query,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isAwaitingResponse = true;
    });
    _scrollToBottom();

    final engine = context.read<HybridInferenceEngine>();
    final inventory = context.read<InventoryRepository>();

    final response = await engine.processCopilotCommand(query);

    if (response.telemetry != null) {
      await inventory.recordAuditLog(
        action: response.structuredAction?['action'] ?? 'COPILOT_COMMAND',
        details: response.text,
        telemetry: response.telemetry!,
        extraData: response.structuredAction,
      );
    }

    setState(() {
      _messages.add(response);
      _isAwaitingResponse = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Natural Language Inventory & Order Copilot',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'STRUCTURED JSON EXTRACTOR',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Live Hybrid Routing Visualizer
          const HybridRoutingVisualizer(),
          const SizedBox(height: 12),

          // Quick Prompts Chips
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final prompt = _quickPrompts[idx];
                return ActionChip(
                  label: Text(prompt, maxLines: 1, overflow: TextOverflow.ellipsis),
                  backgroundColor: Colors.white,
                  labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                  side: const BorderSide(color: AppColors.border, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  onPressed: () => _handleSend(prompt),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Chat Messages List
          Expanded(
            child: BentoCard(
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, idx) {
                  final msg = _messages[idx];
                  return _buildMessageItem(context, msg);
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Input Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  onSubmitted: _handleSend,
                  decoration: const InputDecoration(
                    hintText: 'e.g. "Registrar 20 unidades de TR-X9 con umbral 5" or "Log 15 units of Trail Runner X9"',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _isAwaitingResponse ? null : () => _handleSend(_inputController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.border,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                child: _isAwaitingResponse
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, CopilotMessage msg) {
    final isUser = msg.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(color: AppColors.cobaltBlue, shape: BoxShape.circle),
              child: const Icon(Icons.bolt_rounded, size: 14, color: Colors.white),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser ? AppColors.surfaceSubtle : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.border,
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10111827),
                    blurRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                  ),
                  if (msg.structuredAction != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border, width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.data_object_rounded, size: 12, color: AppColors.cobaltBlue),
                              const SizedBox(width: 6),
                              Text(
                                'STRUCTURED INVENTORY ACTION',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.cobaltBlue,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            msg.structuredAction.toString(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(fontFamily: 'JetBrainsMono', fontSize: 9.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (msg.telemetry != null) ...[
                    const SizedBox(height: 10),
                    TelemetryBadge(telemetry: msg.telemetry!, compact: true),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(color: AppColors.border, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, size: 14, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}
