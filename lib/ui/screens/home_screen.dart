import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/data_provider.dart';
import '../../core/models/github_models.dart';
import '../widgets/stat_card.dart';
import '../widgets/coder_rank_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, GlobalKey> _filterKeys = {
    'yesterday': GlobalKey(),
    'this_week': GlobalKey(),
    'last_week': GlobalKey(),
    'this_month': GlobalKey(),
    'last_month': GlobalKey(),
    'last_year': GlobalKey(),
    'all_time': GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DataProvider>();
      provider.fetchData();
      _scrollToFilter(provider.currentPeriod);
    });
  }
  
  void _scrollToFilter(String period) {
    // Small delay to ensure UI builds if state changed
    Future.delayed(const Duration(milliseconds: 50), () {
      final key = _filterKeys[period];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          alignment: 0.5, // 0.5 centers the item
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  // ... existing code ...

  Widget _buildFilterChip(BuildContext context, DataProvider provider, String label, String value) {
    final isSelected = provider.currentPeriod == value;
    return Padding(
      key: _filterKeys[value], // Assign Key Here
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          if (selected) {
            provider.fetchData(period: value);
            _scrollToFilter(value);
          }
        },
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.slate400,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.slate800,
          ),
        ),
      ),
    );
  }
    final provider = context.watch<DataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(LucideIcons.code2, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Text('SkyLab Coders'),
          ],
        ),
        actions: [
          // Refresh button removed
        ],
      ),
      body: provider.isLoading
          ? _buildLoadingState(provider)
          : provider.repositories.isEmpty
              ? _buildEmptyState(provider)
              : _buildDashboard(provider),
    );
  }

  Widget _buildLoadingState(DataProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            provider.loadingMessage,
            style: GoogleFonts.inter(fontSize: 16, color: AppColors.slate400),
          ).animate().fadeIn(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(DataProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.github, size: 80, color: AppColors.slate700),
          const SizedBox(height: 24),
          Text(
            'Henüz veri yok',
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Veriler otomatik olarak güncellenmektedir.',
            style: GoogleFonts.inter(color: AppColors.slate400),
          ),
          const SizedBox(height: 32),
          if (provider.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Text(
                'Hata: ${provider.error}',
                style: const TextStyle(color: AppColors.rose400),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDashboard(DataProvider provider) {
    final contributors = provider.sortedContributors;
    final totalCommits = contributors.fold(0, (sum, item) => sum + item.totalCommits);
    final topCoder = provider.coderOfTheMonth;

    return RefreshIndicator(
      onRefresh: () => provider.fetchData(),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Period Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(context, provider, 'Dün', 'yesterday'),
                      _buildFilterChip(context, provider, 'Bu Hafta', 'this_week'),
                      _buildFilterChip(context, provider, 'Geçen Hafta', 'last_week'),
                      _buildFilterChip(context, provider, 'Bu Ay', 'this_month'),
                      _buildFilterChip(context, provider, 'Geçen Ay', 'last_month'),
                      _buildFilterChip(context, provider, 'Geçen Yıl', 'last_year'),
                      _buildFilterChip(context, provider, 'Tüm Zamanlar', 'all_time'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stats Row
                if (contributors.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Geliştiriciler',
                          value: '${contributors.length}',
                          icon: LucideIcons.users,
                          iconColor: AppColors.emerald400,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Toplam Commit',
                          value: '$totalCommits',
                          icon: LucideIcons.gitCommit,
                          iconColor: AppColors.amber400,
                        ),
                      ),
                    ],
                  ).animate().slideY(begin: 0.2, end: 0, duration: 500.ms).fadeIn(),
                  
                  const SizedBox(height: 12),
                  Row(
                    children: [
                       Expanded(
                        child: StatCard(
                          title: 'Projeler',
                          value: '${provider.repositories.length}',
                          icon: LucideIcons.folderGit2,
                          iconColor: AppColors.blue400,
                        ),
                      ),
                    ],
                  ).animate().slideY(begin: 0.2, end: 0, duration: 600.ms).fadeIn(),

                const SizedBox(height: 24),

                // Winner Section
                if (topCoder != null) ...[
                  Text(
                    _getWinnerTitle(provider.currentPeriod),
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate50,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildWinnerCard(topCoder),
                  const SizedBox(height: 32),
                ],

                // Leaderboard Header
                Text(
                  'Sıralama',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate50,
                  ),
                ),
                const SizedBox(height: 12),
              ]),
            ),
          ),
          
          // Leaderboard List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return CoderRankItem(
                    rank: index + 1,
                    stat: contributors[index],
                  ).animate().slideX(begin: 0.2, duration: 400.ms, delay: (50 * index).ms).fadeIn();
                },
                childCount: contributors.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
              child: Text(
                'Son Aktiviteler',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate50,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final commit = provider.recentCommits[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.slate800),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.slate800,
                          backgroundImage: commit.avatarUrl != null ? NetworkImage(commit.avatarUrl!) : null,
                          child: commit.avatarUrl == null ? const Icon(LucideIcons.gitCommit, size: 16, color: AppColors.slate400) : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                commit.message,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: AppColors.slate50,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${commit.authorName} • ${_formatDate(commit.date)}',
                                style: GoogleFonts.inter(
                                  color: AppColors.slate400,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (50 * index).ms);
                },
                childCount: provider.recentCommits.length > 10 ? 10 : provider.recentCommits.length,
              ),
            ),
          ),
          
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }

  // _buildFilterChip is now defined above to capture state keys.

  Widget _buildWinnerCard(ContributorStat stat) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.indigo600, AppColors.indigo900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.indigo500.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
           CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: stat.avatarUrl != null ? NetworkImage(stat.avatarUrl!) : null,
            child: stat.avatarUrl == null 
              ? Text(stat.name[0], style: GoogleFonts.outfit(fontSize: 32, color: Colors.white)) 
              : null,
          ).animate(onPlay: (c) => c.repeat(reverse: true))
            .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.4))
            .scaleXY(begin: 1, end: 1.05, duration: 1000.ms),
          
          const SizedBox(height: 16),
          Text(
            stat.name,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '${stat.totalCommits} Commits - ${stat.activeRepos.length} Repos',
            style: GoogleFonts.inter(
              color: Colors.indigo.shade100,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('🔥 Kod Makinesi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      if (difference.inDays < 7) {
        return '${difference.inDays} gün önce';
      }
      return '${date.day}.${date.month}.${date.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  String _getWinnerTitle(String period) {
    switch (period) {
      case 'yesterday':
        return '🚀 Dünün Yıldızı';
      case 'this_week':
        return '🔥 Bu Haftanın Lideri';
      case 'last_week':
        return '🌟 Geçen Haftanın Lideri';
      case 'this_month':
        return '🏆 Bu Ayın En İyisi';
      case 'last_month':
        return '👑 Geçen Ayın Kralı';
      case 'last_year':
        return '💫 Geçen Yılın Efsanesi';
      case 'all_time':
        return '♾️ Tüm Zamanların En İyisi';
      default:
        return '🏆 Lider';
    }
  }

}
