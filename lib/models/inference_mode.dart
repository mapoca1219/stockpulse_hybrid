enum InferenceMode {
  auto('Auto (Prefer On-Device)', 'Routes locally on Gemini Nano 4 when available; falls back to Cloud when heavy multi-doc reasoning is requested.'),
  forceOnDevice('Force On-Device', 'Strictly local NPU/Chrome Prompt API execution. Zero server egress, 0ms network dependency.'),
  forceCloud('Force Cloud', 'Direct Cloud processing via Firebase AI Logic (Gemini 2.5 Flash). Full multi-catalog reasoning.');

  final String label;
  final String description;

  const InferenceMode(this.label, this.description);
}

enum InferenceSource {
  onDevice('ON_DEVICE', 'Gemini Nano 4 (Local NPU / Built-in)', true),
  inCloud('IN_CLOUD', 'Gemini 2.5 Flash (Firebase AI Logic Cloud)', false);

  final String code;
  final String displayName;
  final bool isLocal;

  const InferenceSource(this.code, this.displayName, this.isLocal);
}
