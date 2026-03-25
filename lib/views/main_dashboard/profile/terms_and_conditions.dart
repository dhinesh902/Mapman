import 'package:flutter/material.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({super.key});

  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  late WebViewController _controller;
  bool _isLoading = true;
  final String _url =
      'https://mapman-production.up.railway.app/terms-and-condtions';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWebView();
    });
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('Loading progress: $progress%');
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            debugPrint('Page finished loading: $url');
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (request) async {
            if (request.url.startsWith('mailto:') ||
                request.url.startsWith('tel:')) {
              if (await canLaunchUrl(Uri.parse(request.url))) {
                await launchUrl(Uri.parse(request.url));
                return NavigationDecision.prevent;
              } else {
                print('Could not launch ${request.url}');
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_url));
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.clearCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(title: 'Terms & Conditions'),
        body: Stack(
          children: [
            if (_isLoading) const CustomLoadingIndicator(),
            if (!_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.all(0),
                  child: WebViewWidget(controller: _controller),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
