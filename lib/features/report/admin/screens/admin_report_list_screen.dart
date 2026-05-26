// report/admin/screens/admin_report_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resolv/features/auth/presentation/controllers/auth_controller.dart';
import 'package:resolv/features/report/providers/admin_report_providers.dart';
import 'package:resolv/features/report/admin/widgets/admin_report_card.dart';

class AdminReportListScreen extends ConsumerStatefulWidget {
  const AdminReportListScreen({super.key});

  @override
  ConsumerState<AdminReportListScreen> createState() => _AdminReportListScreenState();
}

class _AdminReportListScreenState extends ConsumerState<AdminReportListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Trigger load more when 200px from bottom
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(adminReportListProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(adminReportListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminReportListProvider),
          ),
          MaterialButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
            child: const Text('Log out'),
          ),
        ],
      ),
      body: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load reports: $e'),
              TextButton(
                onPressed: () => ref.invalidate(adminReportListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (reports) {
          if (reports.isEmpty) {
            return const Center(child: Text('No reports yet.'));
          }

          final notifier = ref.read(adminReportListProvider.notifier);

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminReportListProvider),
            child: ListView.builder(
              controller: _scrollController,
              // +1 for the load-more indicator at the bottom
              itemCount: reports.length + (notifier.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == reports.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final report = reports[index];
                return AdminReportCard(
                  report: report,
                  onTap: () => context.push('/admin/reports/${report.id}', extra: report),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
