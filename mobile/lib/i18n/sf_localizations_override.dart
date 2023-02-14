import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:syncfusion_flutter_core/localizations.dart";

/// Allows overriding of default text values in an [SfCalendar] widget.
class SfLocalizationsOverride implements SfLocalizations {
  SfLocalizationsOverride();

  @override
  String get noSelectedDateCalendarLabel => "No selected date";

  // Overridden.
  @override
  String get noEventsCalendarLabel => "No catches or trips";

  @override
  String get daySpanCountLabel => "Day";

  @override
  String get allowedViewDayLabel => "Day";

  @override
  String get allowedViewWeekLabel => "Week";

  @override
  String get allowedViewWorkWeekLabel => "Work Week";

  @override
  String get allowedViewMonthLabel => "Month";

  @override
  String get allowedViewScheduleLabel => "Schedule";

  @override
  String get allowedViewTimelineDayLabel => "Timeline Day";

  @override
  String get allowedViewTimelineWeekLabel => "Timeline Week";

  @override
  String get allowedViewTimelineWorkWeekLabel => "Timeline Work Week";

  @override
  String get allowedViewTimelineMonthLabel => "Timeline Month";

  @override
  String get todayLabel => "Today";

  @override
  String get weeknumberLabel => "Week";

  @override
  String get allDayLabel => "All Day";

  @override
  String get muharramLabel => "Muharram";

  @override
  String get safarLabel => "Safar";

  @override
  String get rabi1Label => "Rabi' al-awwal";

  @override
  String get rabi2Label => "Rabi' al-thani";

  @override
  String get jumada1Label => "Jumada al-awwal";

  @override
  String get jumada2Label => "Jumada al-thani";

  @override
  String get rajabLabel => "Rajab";

  @override
  String get shaabanLabel => "Sha'aban";

  @override
  String get ramadanLabel => "Ramadan";

  @override
  String get shawwalLabel => "Shawwal";

  @override
  String get dhualqiLabel => "Dhu al-Qi'dah";

  @override
  String get dhualhiLabel => "Dhu al-Hijjah";

  @override
  String get shortMuharramLabel => "Muh.";

  @override
  String get shortSafarLabel => "Saf.";

  @override
  String get shortRabi1Label => "Rabi. I";

  @override
  String get shortRabi2Label => "Rabi. II";

  @override
  String get shortJumada1Label => "Jum. I";

  @override
  String get shortJumada2Label => "Jum. II";

  @override
  String get shortRajabLabel => "Raj.";

  @override
  String get shortShaabanLabel => "Sha.";

  @override
  String get shortRamadanLabel => "Ram.";

  @override
  String get shortShawwalLabel => "Shaw.";

  @override
  String get shortDhualqiLabel => "Dhu'l-Q";

  @override
  String get shortDhualhiLabel => "Dhu'l-H";

  @override
  String get ofDataPagerLabel => "of";

  @override
  String get pagesDataPagerLabel => "pages";

  @override
  String get rowsPerPageDataPagerLabel => "Rows per page";

  @override
  String get afterDataGridFilteringLabel => "After";

  @override
  String get afterOrEqualDataGridFilteringLabel => "After Or Equal";

  @override
  String get beforeDataGridFilteringLabel => "Before";

  @override
  String get beforeOrEqualDataGridFilteringLabel => "Before Or Equal";

  @override
  String get beginsWithDataGridFilteringLabel => "Begins With";

  @override
  String get containsDataGridFilteringLabel => "Contains";

  @override
  String get doesNotBeginWithDataGridFilteringLabel => "Does Not Begin With";

  @override
  String get doesNotContainDataGridFilteringLabel => "Does Not Contain";

  @override
  String get doesNotEndWithDataGridFilteringLabel => "Does Not End With";

  @override
  String get doesNotEqualDataGridFilteringLabel => "Does Not Equal";

  @override
  String get emptyDataGridFilteringLabel => "Empty";

  @override
  String get endsWithDataGridFilteringLabel => "Ends With";

  @override
  String get equalsDataGridFilteringLabel => "Equals";

  @override
  String get greaterThanDataGridFilteringLabel => "Greater Than";

  @override
  String get greaterThanOrEqualDataGridFilteringLabel =>
      "Greater Than Or Equal";

  @override
  String get lessThanDataGridFilteringLabel => "Less Than";

  @override
  String get lessThanOrEqualDataGridFilteringLabel => "Less Than Or Equal";

  @override
  String get notEmptyDataGridFilteringLabel => "Not Empty";

  @override
  String get notNullDataGridFilteringLabel => "Not Null";

  @override
  String get nullDataGridFilteringLabel => "Null";

  @override
  String get sortSmallestToLargestDataGridFilteringLabel =>
      "Sort Smallest to Largest";

  @override
  String get sortLargestToSmallestDataGridFilteringLabel =>
      "Sort Largest to Smallest";

  @override
  String get sortAToZDataGridFilteringLabel => "Sort A to Z";

  @override
  String get sortZToADataGridFilteringLabel => "Sort Z to A";

  @override
  String get sortOldestToNewestDataGridFilteringLabel =>
      "Sort Oldest to Newest";

  @override
  String get sortNewestToOldestDataGridFilteringLabel =>
      "Sort Newest to Oldest";

  @override
  String get clearFilterDataGridFilteringLabel => "Clear Filter";

  @override
  String get fromDataGridFilteringLabel => "From";

  @override
  String get textFiltersDataGridFilteringLabel => "Text Filters";

  @override
  String get numberFiltersDataGridFilteringLabel => "Number Filters";

  @override
  String get dateFiltersDataGridFilteringLabel => "Date Filters";

  @override
  String get searchDataGridFilteringLabel => "Search";

  @override
  String get noMatchesDataGridFilteringLabel => "No matches";

  @override
  String get okDataGridFilteringLabel => "OK";

  @override
  String get cancelDataGridFilteringLabel => "Cancel";

  @override
  String get showRowsWhereDataGridFilteringLabel => "Show rows where";

  @override
  String get andDataGridFilteringLabel => "And";

  @override
  String get orDataGridFilteringLabel => "Or";

  @override
  String get selectAllDataGridFilteringLabel => "Select All";

  @override
  String get sortAndFilterDataGridFilteringLabel => "Sort and Filter";

  @override
  String get pdfBookmarksLabel => "Bookmarks";

  @override
  String get pdfNoBookmarksLabel => "No bookmarks found";

  @override
  String get pdfScrollStatusOfLabel => "of";

  @override
  String get pdfGoToPageLabel => "Go to page";

  @override
  String get pdfEnterPageNumberLabel => "Enter page number";

  @override
  String get pdfInvalidPageNumberLabel => "Please enter a valid number";

  @override
  String get pdfPaginationDialogOkLabel => "OK";

  @override
  String get pdfPaginationDialogCancelLabel => "CANCEL";

  @override
  String get pdfHyperlinkLabel => "Open Web Page";

  @override
  String get pdfHyperlinkContentLabel => "Do you want to open the page at";

  @override
  String get pdfHyperlinkDialogOpenLabel => "OPEN";

  @override
  String get pdfHyperlinkDialogCancelLabel => "CANCEL";

  @override
  String get passwordDialogHeaderTextLabel => "Password Protected";

  @override
  String get passwordDialogContentLabel =>
      "Enter the password to open this PDF file";

  @override
  String get passwordDialogHintTextLabel => "Enter Password";

  @override
  String get passwordDialogInvalidPasswordLabel => "Invalid Password";

  @override
  String get pdfPasswordDialogOpenLabel => "OPEN";

  @override
  String get pdfPasswordDialogCancelLabel => "CANCEL";

  @override
  String get series => "Series";
}

class SfLocalizationsOverrideDelegate
    extends LocalizationsDelegate<SfLocalizations> {
  const SfLocalizationsOverrideDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == "en";

  @override
  Future<SfLocalizations> load(Locale locale) {
    return SynchronousFuture<SfLocalizations>(SfLocalizationsOverride());
  }

  @override
  bool shouldReload(LocalizationsDelegate<SfLocalizations> old) => false;
}
