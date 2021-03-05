import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile/res/style.dart';
import 'package:quiver/strings.dart';

/// An actionable widget meant to be used to ask the user a question, and give
/// them an action to take. For example, "Already have an account? Sign up.",
/// where "Sign up." is styled as a hyperlink and is clickable.
class QuestionAnswerLink extends StatelessWidget {
  final String question;
  final String actionText;
  final VoidCallback action;

  QuestionAnswerLink({
    @required this.question,
    @required this.actionText,
    this.action,
  })  : assert(isNotEmpty(question)),
        assert(isNotEmpty(actionText));

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: question,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        TextSpan(text: " "),
        TextSpan(
          text: actionText,
          style: styleHyperlink,
          recognizer: TapGestureRecognizer()..onTap = action,
        )
      ]),
    );
  }
}
