import 'dart:math';

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:budget/widgets/animatedCircularProgress.dart';
import '../colors.dart';

class CategoryEntry extends StatelessWidget {
  CategoryEntry({
    Key? key,
    required this.category,
    required this.transactionCount,
    required this.categorySpent,
    required this.totalSpent,
    required this.onTap,
    required this.selected,
    required this.allSelected,
    required this.budgetColorScheme,
    this.categoryBudgetLimit,
    this.isTiled = false,
    this.onLongPress,
    this.extraText = " of budget",
    this.showIncomeExpenseIcons = false,
  }) : super(key: key);

  final TransactionCategory category;
  final int transactionCount;
  final double totalSpent;
  final double categorySpent;
  final VoidCallback onTap;
  final bool selected;
  final bool allSelected;
  final ColorScheme budgetColorScheme;
  final bool isTiled;
  final CategoryBudgetLimit? categoryBudgetLimit;
  final Function? onLongPress;
  final String extraText;
  final bool showIncomeExpenseIcons;

  @override
  Widget build(BuildContext context) {
    Widget component;
    if (isTiled) {
      component = Container(
        width: 70,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CategoryIconPercent(
                category: category,
                percent: categorySpent / totalSpent * 100,
                progressBackgroundColor: selected
                    ? getColor(context, "white")
                    : getColor(context, "lightDarkAccentHeavy"),
              ),
              SizedBox(height: 5),
              TextFont(
                autoSizeText: true,
                minFontSize: 8,
                maxLines: 1,
                text: convertToMoney(categorySpent),
                fontSize: 13,
                textColor: getColor(context, "textLight"),
              ),
            ],
          ),
        ),
      );
    } else {
      component = Padding(
        padding: EdgeInsets.symmetric(
          horizontal: getHorizontalPaddingConstrained(context),
        ),
        child: Row(
          children: [
            // CategoryIcon(
            //   category: category,
            //   size: 30,
            //   margin: EdgeInsets.zero,
            // ),
            CategoryIconPercent(
              category: category,
              percent: categoryBudgetLimit != null
                  ? (categorySpent / categoryBudgetLimit!.amount * 100).abs()
                  : (categorySpent / totalSpent * 100).abs(),
              progressBackgroundColor: selected
                  ? getColor(context, "white")
                  : getColor(context, "lightDarkAccentHeavy"),
              size: 28,
              insetPadding: 18,
            ),
            Container(
              width: 15,
            ),
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextFont(
                      text: category.name,
                      fontSize: 18,
                      maxLines: 2,
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    categoryBudgetLimit != null
                        ? Wrap(
                            direction: Axis.horizontal,
                            children: [
                              TextFont(
                                text: (categorySpent /
                                            categoryBudgetLimit!.amount *
                                            100)
                                        .toStringAsFixed(0) +
                                    "%",
                                fontSize: 14,
                                textColor: (categorySpent /
                                            categoryBudgetLimit!.amount *
                                            100) >
                                        100
                                    ? getColor(context, "unPaidOverdue")
                                    : (selected
                                        ? getColor(context, "black")
                                            .withOpacity(0.4)
                                        : getColor(context, "textLight")),
                              ),
                              TextFont(
                                text: " of " +
                                    convertToMoney(
                                        categoryBudgetLimit!.amount) +
                                    " limit",
                                fontSize: 14,
                                textColor: selected
                                    ? getColor(context, "black")
                                        .withOpacity(0.4)
                                    : getColor(context, "textLight"),
                              ),
                            ],
                          )
                        : TextFont(
                            text: (totalSpent == 0
                                    ? "0"
                                    : (categorySpent / totalSpent * 100)
                                        .abs()
                                        .toStringAsFixed(0)) +
                                "%" +
                                extraText,
                            fontSize: 14,
                            textColor: selected
                                ? getColor(context, "black").withOpacity(0.4)
                                : getColor(context, "textLight"),
                          )
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    categorySpent == 0 || showIncomeExpenseIcons == false
                        ? SizedBox.shrink()
                        : Transform.translate(
                            offset: Offset(3, 0),
                            child: Transform.rotate(
                              angle: categorySpent >= 0 ? pi : 0,
                              child: Icon(
                                Icons.arrow_drop_down_rounded,
                                color: showIncomeExpenseIcons
                                    ? categorySpent > 0
                                        ? getColor(context, "incomeAmount")
                                        : getColor(context, "expenseAmount")
                                    : getColor(context, "black"),
                              ),
                            ),
                          ),
                    TextFont(
                      fontWeight: FontWeight.bold,
                      text: convertToMoney(categorySpent.abs()),
                      fontSize: 20,
                      textColor: showIncomeExpenseIcons && categorySpent != 0
                          ? categorySpent > 0
                              ? getColor(context, "incomeAmount")
                              : getColor(context, "expenseAmount")
                          : getColor(context, "black"),
                    ),
                    // categoryBudgetLimit == null
                    //     ? SizedBox.shrink()
                    //     : Padding(
                    //         padding: const EdgeInsets.only(bottom: 1),
                    //         child: TextFont(
                    //           text: " / " +
                    //               convertToMoney(categoryBudgetLimit!.amount),
                    //           fontSize: 14,
                    //         ),
                    //       ),
                  ],
                ),
                SizedBox(
                  height: 0,
                ),
                TextFont(
                  text: transactionCount.toString() +
                      pluralString(transactionCount == 1, " transaction"),
                  fontSize: 14,
                  textColor: selected
                      ? getColor(context, "black").withOpacity(0.4)
                      : getColor(context, "textLight"),
                )
              ],
            ),
          ],
        ),
      );
    }
    return WillPopScope(
      onWillPop: () async {
        if (allSelected == false && selected) {
          onTap();
          return false;
        }
        return true;
      },
      child: AnimatedSize(
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeInOutCubicEmphasized,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: !selected && !allSelected && isTiled == false
              ? Container(
                  key: ValueKey(2),
                )
              : Tappable(
                  borderRadius: isTiled ? 15 : 0,
                  key: ValueKey(isTiled),
                  onTap: onTap,
                  onLongPress: onLongPress != null
                      ? () => onLongPress!()
                      : () => pushRoute(
                            context,
                            AddCategoryPage(
                              title: "Edit Category",
                              category: category,
                            ),
                          ),
                  color: Colors.transparent,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 300),
                    opacity: allSelected
                        ? 1
                        : selected
                            ? 1
                            : 0.3,
                    child: AnimatedContainer(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(isTiled ? 15 : 0),
                        color: selected
                            ? dynamicPastel(context, budgetColorScheme.primary,
                                    amount: 0.3)
                                .withAlpha(80)
                            : Colors.transparent,
                      ),
                      curve: Curves.easeInOut,
                      duration: Duration(milliseconds: 500),
                      padding: isTiled
                          ? null
                          : EdgeInsets.only(
                              left: 20, right: 25, top: 8, bottom: 8),
                      child: component,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class CategoryIconPercent extends StatelessWidget {
  CategoryIconPercent({
    Key? key,
    required this.category,
    this.size = 30,
    required this.percent,
    this.insetPadding = 23,
    required this.progressBackgroundColor,
  }) : super(key: key);

  final TransactionCategory category;
  final double size;
  final double percent;
  final double insetPadding;
  final Color progressBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Padding(
        padding: EdgeInsets.all(insetPadding / 2),
        child: Image(
          image: AssetImage("assets/categories/" + (category.iconName ?? "")),
          width: size - 3,
        ),
      ),
      AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: Container(
          key: ValueKey(progressBackgroundColor.toString()),
          height: size + insetPadding,
          width: size + insetPadding,
          child: AnimatedCircularProgress(
            percent: percent / 100,
            backgroundColor: progressBackgroundColor,
            foregroundColor: HexColor(category.colour,
                defaultColor: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    ]);
  }
}
