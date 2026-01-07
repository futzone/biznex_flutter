import 'package:biznex/src/core/database/audit_log_database/audit_log.dart';
import 'package:biznex/src/core/database/audit_log_database/logger_service.dart';
import 'package:biznex/src/core/database/employee_database/employee_database.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';
import 'package:biznex/src/ui/widgets/helpers/app_simple_button.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../biznex.dart';
import '../../widgets/helpers/app_text_field.dart';

class ActionsPage extends StatefulWidget {
  const ActionsPage({super.key});

  @override
  State<ActionsPage> createState() => _ActionsPageState();
}

class _ActionsPageState extends State<ActionsPage> {
  LogType? _logType;
  ActionType? _actionType;
  DateTime? _selectedDate;
  Employee? _selectedEmployee;
  List<Employee> _employees = [];

  List<AuditLogIsar> _logsList = [];
  int _page = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _onLoadLogs();
  }

  Future<void> _loadEmployees() async {
    final employees = await EmployeeDatabase().get();
    setState(() {
      _employees = employees;
    });
  }

  void _onLoadLogs() async {
    setState(() {
      _isLoading = true;
    });
    final logsList = await LoggerService.getLogs(
      page: _page,
      logType: _logType?.name,
      actionType: _actionType?.name,
      employeeId: _selectedEmployee?.id,
      date: _selectedDate,
    );

    _logsList = [...logsList];

    setState(() {
      _isLoading = false;
    });
  }

  void _onLoadNextPage() {
    if (_logsList.length < 20) return;
    _page++;
    _onLoadLogs();
  }

  void _onLoadPreviousPage() {
    if (_page == 0) return;
    _page--;
    _onLoadLogs();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateWrapper(builder: (theme, state) {
      return Scaffold(
        body: Column(
          children: [
            Padding(
              padding: Dis.only(
                lr: context.w(24),
                top: context.h(24),
                bottom: context.h(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: context.w(16),
                children: [
                  Expanded(
                    child: Text(
                      AppLocales.actions.tr(),
                      style: TextStyle(
                        fontSize: context.s(24),
                        fontFamily: mediumFamily,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  0.w,

                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                          _page = 0;
                        });
                        _onLoadLogs();
                      }
                    },
                    child: Container(
                      height: 48,
                      padding: Dis.only(lr: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        children: [
                          Icon(Iconsax.calendar_1_copy,
                              size: 20,
                              color: _selectedDate != null
                                  ? theme.mainColor
                                  : Colors.black54),
                          8.w,
                          Text(
                            _selectedDate != null
                                ? DateFormat('yyyy-MM-dd')
                                    .format(_selectedDate!)
                                : AppLocales.date.tr(),
                            style: TextStyle(fontFamily: mediumFamily),
                          ),
                          if (_selectedDate != null) ...[
                            8.w,
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDate = null;
                                  _page = 0;
                                });
                                _onLoadLogs();
                              },
                              child: Icon(Icons.close, size: 16),
                            )
                          ]
                        ],
                      ),
                    ),
                  ),
                  // Employee Dropdown
                  // PopupMenuButton<Employee>(
                  //   itemBuilder: (context) {
                  //     return [
                  //       PopupMenuItem(
                  //         onTap: () {
                  //           setState(() {
                  //             _selectedEmployee = null;
                  //             _page = 0;
                  //           });
                  //           _onLoadLogs();
                  //         },
                  //         child: Text("All Employees".tr()),
                  //       ),
                  //       for (final item in _employees)
                  //         PopupMenuItem(
                  //           onTap: () {
                  //             setState(() {
                  //               _selectedEmployee = item;
                  //               _page = 0;
                  //             });
                  //             _onLoadLogs();
                  //           },
                  //           child: Row(
                  //             children: [
                  //               if (_selectedEmployee?.id == item.id)
                  //                 Icon(Icons.check_circle_rounded,
                  //                     color: theme.mainColor, size: 20)
                  //               else
                  //                 Icon(Icons.circle_outlined, size: 20),
                  //               8.w,
                  //               Text(item.fullname),
                  //             ],
                  //           ),
                  //         ),
                  //     ];
                  //   },
                  //   child: Container(
                  //     height: 48,
                  //     padding: Dis.only(lr: 12),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       borderRadius: BorderRadius.circular(12),
                  //       border: Border.all(color: Colors.black12),
                  //     ),
                  //     child: Row(
                  //       children: [
                  //         Icon(Iconsax.profile_circle_copy,
                  //             size: 20,
                  //             color: _selectedEmployee != null
                  //                 ? theme.mainColor
                  //                 : Colors.black54),
                  //         8.w,
                  //         Text(
                  //           _selectedEmployee?.fullname ??
                  //               AppLocales.employee.tr(),
                  //           style: TextStyle(fontFamily: mediumFamily),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // Action Type Dropdown
                  PopupMenuButton<ActionType>(
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          onTap: () {
                            setState(() {
                              _actionType = null;
                              _page = 0;
                            });
                            _onLoadLogs();
                          },
                          child: Text("All Actions".tr()),
                        ),
                        for (final item in ActionType.values)
                          PopupMenuItem(
                            onTap: () {
                              setState(() {
                                _actionType = item;
                                _page = 0;
                              });
                              _onLoadLogs();
                            },
                            child: Row(
                              children: [
                                if (_actionType == item)
                                  Icon(Icons.check_circle_rounded,
                                      color: theme.mainColor, size: 20)
                                else
                                  Icon(Icons.circle_outlined, size: 20),
                                8.w,
                                Text(item.name.tr()),
                              ],
                            ),
                          ),
                      ];
                    },
                    child: Container(
                      height: 48,
                      padding: Dis.only(lr: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        children: [
                          Icon(Iconsax.activity_copy,
                              size: 20,
                              color: _actionType != null
                                  ? theme.mainColor
                                  : Colors.black54),
                          8.w,
                          Text(
                            _actionType?.name.tr() ??
                                AppLocales.actionType.tr(),
                            style: TextStyle(fontFamily: mediumFamily),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Log Type Dropdown (Existing, updated style)
                  PopupMenuButton<LogType>(
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          onTap: () {
                            setState(() {
                              _logType = null;
                              _page = 0;
                            });
                            _onLoadLogs();
                          },
                          child: Text("All Logs".tr()),
                        ),
                        for (final item in LogType.values)
                          PopupMenuItem(
                            onTap: () {
                              setState(() {
                                if (item == _logType) {
                                  _logType = null;
                                } else {
                                  _logType = item;
                                }
                                _page = 0;
                              });
                              _onLoadLogs();
                            },
                            child: Row(
                              spacing: 8,
                              children: [
                                if (_logType == item)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: theme.mainColor,
                                    size: 20,
                                  )
                                else
                                  Icon(
                                    Icons.circle_outlined,
                                    size: 20,
                                  ),
                                Text(item.name.tr()),
                              ],
                            ),
                          ),
                      ];
                    },
                    child: Container(
                      height: 48,
                      padding: Dis.only(lr: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        children: [
                          Icon(Iconsax.folder_copy,
                              size: 20,
                              color: _logType != null
                                  ? theme.mainColor
                                  : Colors.black54),
                          8.w,
                          Text(
                            _logType?.name.tr() ?? "Log Type".tr(),
                            style: TextStyle(fontFamily: mediumFamily),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading) Expanded(child: AppLoadingScreen()),
            if (!_isLoading && _logsList.isEmpty)
              Expanded(child: AppEmptyWidget()),
            if (!_isLoading && _logsList.isNotEmpty)
              Container(
                margin: Dis.only(lr: 24, top: 8),
                padding: Dis.only(lr: 16, tb: 12),
                decoration: BoxDecoration(
                    color: theme.accentColor,
                    border: Border(
                      right: BorderSide(color: Colors.black12, width: 8),
                    ),
                    borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: [
                    Icon(Icons.numbers, size: 20),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.activity_copy, size: 20),
                          4.w,
                          Text(AppLocales.actionType.tr()),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.info_circle_copy, size: 20),
                          4.w,
                          Text(AppLocales.action.tr()),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.profile_circle_copy, size: 20),
                          4.w,
                          Text(AppLocales.employee.tr()),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.calendar_1_copy, size: 20),
                          4.w,
                          Text(AppLocales.createdDate.tr()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: Dis.only(top: 16),
                itemCount: _logsList.length,
                itemBuilder: (context, index) {
                  final audit = _logsList[index];
                  return Container(
                    margin: Dis.only(lr: 24, tb: 4),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      border: Border(
                        right: BorderSide(
                            color: getActionColor(audit.actionType ?? ''),
                            width: 8),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: Dis.only(lr: 16, tb: 12),
                    child: Row(
                      children: [
                        Text(
                          audit.id.toString(),
                          style: TextStyle(
                            fontFamily: boldFamily,
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              audit.logType?.tr() ?? '',
                              style: TextStyle(fontFamily: mediumFamily),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              audit.actionType?.tr() ?? '',
                              style: TextStyle(fontFamily: mediumFamily),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              audit.employee?.fullname ?? '',
                              style: TextStyle(fontFamily: mediumFamily),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              audit.createdDate != null
                                  ? DateFormat("yyyy.MM.dd, HH:mm")
                                      .format(audit.createdDate!)
                                  : '',
                              style: TextStyle(fontFamily: mediumFamily),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(
                  top: BorderSide(
                    color: Colors.black12,
                  ),
                ),
              ),
              padding: Dis.only(lr: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SimpleButton(
                    onPressed: _onLoadPreviousPage,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                        8.w,
                        Text(AppLocales.previous.tr()),
                      ],
                    ),
                  ),
                  Text(
                      "${(_page * 20) + 1} - ${(_page * 20) + _logsList.length}"),
                  if (_logsList.length >= 20)
                    SimpleButton(
                      onPressed: _onLoadNextPage,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(AppLocales.next.tr()),
                          8.w,
                          Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      width: 80,
                    ), // Placeholder to balance row
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
