import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/utils/search_timer.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class SearchPage extends StatefulWidget {
  final String hint;
  final Widget Function(BuildContext) suggestionsBuilder;
  final Widget Function(BuildContext, String) resultsBuilder;

  SearchPage({
    this.hint,
    @required this.suggestionsBuilder,
    @required this.resultsBuilder,
  }) : assert(suggestionsBuilder != null),
       assert(resultsBuilder != null);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  SearchTimer _timer;
  bool _suggesting = true;

  @override
  void initState() {
    super.initState();
    _timer = SearchTimer(showResults);
  }

  @override
  void dispose() {
    super.dispose();
    _timer.finish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        leading: CloseButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hint,
            border: InputBorder.none,
          ),
          style: Theme.of(context).textTheme.headline6,
          autofocus: true,
          onChanged: (text) {
            setState(() {});
            _timer.reset(text);
          },
        ),
        actions: [
          AnimatedVisibility(
            visible: isNotEmpty(_controller.text),
            child: ActionButton(
              text: Strings.of(context).clear,
              onPressed: () {
                _controller.text = "";
                showSuggestions();
              },
            ),
          ),
        ],
      ),
      body: _suggesting
          ? widget.suggestionsBuilder(context)
          : widget.resultsBuilder(context, _controller.text),
    );
  }

  void showSuggestions() {
    setState(() {
      _suggesting = true;
    });
  }

  void showResults() {
    setState(() {
      _suggesting = false;
    });
  }
}