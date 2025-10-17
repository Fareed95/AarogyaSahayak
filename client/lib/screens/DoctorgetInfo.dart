import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'DoctorInfo.dart';

class Doctorgetinfo
    extends
        StatefulWidget {
  final String data;
  const Doctorgetinfo({
    super.key,
    required this.data,
  });

  @override
  State<
    Doctorgetinfo
  >
  createState() => _DoctorgetinfoState();
}

class _DoctorgetinfoState
    extends
        State<
          Doctorgetinfo
        > {
  List<
    dynamic
  >
  reportInstances = [];
  bool isLoading = true;
  String errorMessage = '';
  String path = '';

  @override
  void initState() {
    super.initState();
    fetchReportData();
  }

  Future<
    void
  >
  fetchReportData() async {
    setState(
      () {
        isLoading = true;
        errorMessage = '';
        path = widget.data;
      },
    );
    try {
      final response = await http.post(
        Uri.parse(
          'http://192.168.0.107:8000/api/reports/get_user_instances/',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'email': widget.data,
          },
        ),
      );
      if (response.statusCode ==
          200) {
        final data = json.decode(
          response.body,
        );
        setState(
          () {
            reportInstances =
                data['report_instances'] ??
                [];
            isLoading = false;
          },
        );
      } else {
        setState(
          () {
            errorMessage = 'Failed to load data: ${response.statusCode}';
            isLoading = false;
          },
        );
      }
    } catch (
      e
    ) {
      setState(
        () {
          errorMessage = 'Error: $e';
          isLoading = false;
        },
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Reports',
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
          ? Center(
              child: Text(
                errorMessage,
              ),
            )
          : reportInstances.isEmpty
          ? const Center(
              child: Text(
                'No reports found',
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(
                16,
              ),
              itemCount: reportInstances.length,
              itemBuilder:
                  (
                    context,
                    index,
                  ) {
                    final report = reportInstances[index];
                    return ReportCard(
                      report: report,
                      email: widget.data, // pass email here
                    );
                  },
            ),
    );
  }
}

class ReportCard
    extends
        StatelessWidget {
  final dynamic report;
  final String email; // receive email from parent

  const ReportCard({
    super.key,
    required this.report,
    required this.email,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Title and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    report['report_title'] ??
                        'Untitled Report',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Text(
                  _formatDate(
                    report['date_of_the_report'],
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            if (report['name_of_the_doctor'] !=
                null)
              _buildInfoRow(
                'Doctor',
                report['name_of_the_doctor'],
              ),
            if (report['address_of_the_doctor'] !=
                null)
              _buildInfoRow(
                'Address',
                report['address_of_the_doctor'],
              ),
            const SizedBox(
              height: 12,
            ),
            Text(
              'Summary:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              report['instance_summary'] ??
                  'No summary available',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            if (report['json'] !=
                    null &&
                report['json']['test_details'] !=
                    null)
              _buildTestResults(
                report['json']['test_details'],
              ),
            const SizedBox(
              height: 8,
            ),
            if (report['file'] !=
                null)
              Row(
                children: [
                  const Icon(
                    Icons.insert_drive_file,
                    size: 16,
                    color: Colors.blue,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    'File: ${report['file']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            const SizedBox(
              height: 16,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (
                            context,
                          ) => Doctorinfo(
                            data: email,
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                  ),
                ),
                child: const Text(
                  'Prescribe Medications',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestResults(
    List<
      dynamic
    >
    testDetails,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Test Results:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.blue,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        ...testDetails.map(
          (
            page,
          ) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (testDetails.length >
                    1)
                  Text(
                    'Page ${page['page_number']}:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ...(page['tests']
                        as List)
                    .map(
                      (
                        test,
                      ) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  test['Name'] ??
                                      'Unknown Test',
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  test['Found']?.toString() ??
                                      'N/A',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _getValueColor(
                                      test,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  test['Range']?.toString() ??
                                      'No range specified',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                    .toList(),
                const SizedBox(
                  height: 8,
                ),
              ],
            );
          },
        ).toList(),
      ],
    );
  }

  Color _getValueColor(
    Map<
      String,
      dynamic
    >
    test,
  ) {
    final found = test['Found'];
    final range = test['Range'];
    if (found ==
            null ||
        range ==
            null ||
        range
            is! String) {
      return Colors.black;
    }
    final rangeParts = range.split(
      '-',
    );
    if (rangeParts.length ==
        2) {
      try {
        final lower = double.parse(
          rangeParts[0],
        );
        final upper = double.parse(
          rangeParts[1],
        );
        if (found <
                lower ||
            found >
                upper) {
          return Colors.red;
        }
      } catch (
        _
      ) {
        return Colors.black;
      }
    }
    return Colors.green;
  }

  String _formatDate(
    String dateString,
  ) {
    try {
      final date = DateTime.parse(
        dateString,
      );
      return '${date.day}/${date.month}/${date.year}';
    } catch (
      _
    ) {
      return dateString;
    }
  }
}
