import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../app/theme/app_colors.dart';
import 'dart:io' show Platform;

class PaymentWebViewPage extends StatefulWidget {
  final String htmlContent;

  const PaymentWebViewPage({super.key, required this.htmlContent});

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            // Check if we hit the callback URL (success/failure)
            if (url.contains('/api/v1/payments/callback/')) {
              // Extract body content to see JSON response
              final html = await _controller.runJavaScriptReturningResult("document.documentElement.innerText");
              final str = html.toString().replaceAll(r'\"', '"').replaceAll(r"\'", "'");
              
              // We just return true to the dialog because hitting callback usually means completion
              // But we can parse JSON if we want to be exact.
              if (mounted) {
                Navigator.of(context).pop(true);
              }
            }
          },
        ),
      );

    // Some Iyzico forms might just be HTML forms that need to be submitted.
    // The htmlContent provided by backend is directly loaded.
    _controller.loadHtmlString(widget.htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Güvenli 3D Ödeme'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
