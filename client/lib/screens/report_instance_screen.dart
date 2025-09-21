import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/secure_storage_service.dart';

class ReportInstancesScreen
    extends
        StatefulWidget {
  const ReportInstancesScreen({
    super.key,
  });

  @override
  State<
    ReportInstancesScreen
  >
  createState() => _ReportInstancesScreenState();
}

class _ReportInstancesScreenState
    extends
        State<
          ReportInstancesScreen
        > {
  final SecureStorageService _storageService = SecureStorageService();
  List<
    dynamic
  >
  _reportInstances = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchReportInstances();
  }

  Future<
    void
  >
  fetchReportInstances() async {
    try {
      String? token = await _storageService.getJwtToken();
      if (token ==
          null) {
        throw Exception(
          'JWT Token not found',
        );
      }

      final response = await http.get(
        Uri.parse(
          'http://localhost:8000/api/reports/get_user_instances/',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
      );

      if (response.statusCode ==
          200) {
        final data = json.decode(
          response.body,
        );
        setState(
          () {
            _reportInstances =
                data['report_instances'] ??
                [];
            _loading = false;
          },
        );
      } else {
        throw Exception(
          'Failed to fetch reports: ${response.statusCode}',
        );
      }
    } catch (
      e
    ) {
      print(
        'Error: $e',
      );
      setState(
        () {
          _loading = false;
        },
      );
    }
  }

  void showSummaryDialog(
    String title,
    String summary,
  ) {
    showDialog(
      context: context,
      builder:
          (
            _,
          ) => AlertDialog(
            title: Text(
              title,
            ),
            content: SingleChildScrollView(
              child: Text(
                summary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                ),
                child: const Text(
                  'Close',
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report Instances',
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _reportInstances.isEmpty
          ? const Center(
              child: Text(
                'No reports found',
              ),
            )
          : ListView.builder(
              itemCount: _reportInstances.length,
              itemBuilder:
                  (
                    context,
                    index,
                  ) {
                    final report = _reportInstances[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: ListTile(
                        title: Text(
                          report['report_title'] ??
                              'Untitled',
                        ),
                        subtitle: Text(
                          report['name_of_the_doctor'] ??
                              '',
                        ),
                        onTap: () {
                          showSummaryDialog(
                            report['report_title'] ??
                                'Summary',
                            report['instance_summary'] ??
                                'No summary available',
                          );
                        },
                      ),
                    );
                  },
            ),
    );
  }
}
