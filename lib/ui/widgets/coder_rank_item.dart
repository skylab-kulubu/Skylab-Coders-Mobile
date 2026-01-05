import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/github_models.dart';
import 'package:google_fonts/google_fonts.dart';

class CoderRankItem extends StatelessWidget {
  final int rank;
  final ContributorStat stat;

  const CoderRankItem({
    super.key,
    required this.rank,
    required this.stat,
  });

  Color get _rankColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.slate500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rank <= 3 ? _rankColor.withOpacity(0.5) : AppColors.slate800,
          width: rank <= 3 ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#$rank',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _rankColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundImage: stat.avatarUrl != null 
              ? NetworkImage(stat.avatarUrl!) 
              : null,
            backgroundColor: AppColors.slate700,
            child: stat.avatarUrl == null
              ? Text(stat.name[0].toUpperCase(), style: const TextStyle(color: Colors.white))
              : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate50,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${stat.reposContributedTo} proje • ${stat.activeRepos.join(", ")}',
                  style: GoogleFonts.inter(
                    color: AppColors.slate400,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${stat.totalCommits}',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primaryLight,
                ),
              ),
              Text(
                'Commits',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.slate500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
