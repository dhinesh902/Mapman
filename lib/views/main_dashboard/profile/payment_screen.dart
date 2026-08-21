import 'package:flutter/material.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_textfield.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late TextEditingController amountController;

  late Razorpay _razorpay;
  final List<String> _logs = [];

  @override
  void initState() {
    // TODO: implement initState
    amountController = TextEditingController();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    amountController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void _log(String msg) {
    setState(() => _logs.insert(0, '[${DateTime.now().toIso8601String().substring(11, 19)}] $msg'));
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    _log('SUCCESS — payment_id: ${response.paymentId}');
    _showDialog('Payment Success', 'Payment ID: ${response.paymentId}');
  }

  void _handleError(PaymentFailureResponse response) {
    _log('ERROR — code: ${response.code}, msg: ${response.message}, error: ${response.error}');
    _showDialog('Payment Failed', 'Code: ${response.code}\nMessage: ${response.message}\nError: ${response.error}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _log('EXTERNAL WALLET — ${response.walletName}');
    _showDialog('External Wallet', '${response.walletName}');
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  void _openCheckout() {
    var options = {
      'key': "key",
      'amount': 100,
      'name': 'FPX Crash Test',
      'description': 'Testing FPX cancellation crash',
      'send_sms_hash': true,
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      _log('EXCEPTION: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(title: "Payment"),
        body: ListView(
          padding: EdgeInsets.all(10),
          children: [
            CustomTextField(
              title: "Amount",
              controller: amountController,
              hintText: "Enter amount",
              inputType: TextInputType.number,
              inputAction: TextInputAction.done,
              onFieldChanged: (value) {
                setState(() {
                  amountController.text = value;
                });
              },
            ),
          ],
        ),
        bottomNavigationBar: CustomFullButton(
          title: "Pay ${amountController.text}",
          onTap: _openCheckout,
        ),
      ),
    );
  }
}
