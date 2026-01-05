import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const getLeaderboard = async (inputPeriod: string) => {
    const period = (inputPeriod || 'all_time').toLowerCase().trim();
    console.log(`[StatsService] Processing period: '${period}'`);

    let startDate = new Date(0); // All time start
    let endDate = new Date();    // Now

    // Use local time construction to align with user expectation "This Month" = Calendar Month
    const now = new Date();

    // Rolling Window Logic (Last X Days) - Guarantees data visibility
    const ONE_DAY = 24 * 60 * 60 * 1000;

    switch (period) {
        case 'daily':
        case 'yesterday':
            // Last 24 Hours
            startDate = new Date(now.getTime() - ONE_DAY);
            break;

        case 'weekly':
        case 'this_week':
        case 'last_week':
            // Last 7 Days
            startDate = new Date(now.getTime() - 7 * ONE_DAY);
            break;

        case 'monthly':
        case 'this_month':
        case 'last_month':
            // Last 30 Days
            startDate = new Date(now.getTime() - 30 * ONE_DAY);
            break;

        case 'yearly':
        case 'last_year':
            // Last 365 Days
            startDate = new Date(now.getTime() - 365 * ONE_DAY);
            break;

        case 'all_time':
        default:
            console.log(`[StatsService] Defaulting to All Time for period: '${period}'`);
            startDate = new Date(0);
            break;
    }

    endDate = new Date(); // Always to Now for rolling window

    // console.log(`[StatsService] Date Range: ${startDate.toISOString()} -> ${endDate.toISOString()}`);

    try {
        const results = await prisma.$queryRaw`
            SELECT 
                u.id, 
                u.login, 
                u.name, 
                u."avatarUrl", 
                COUNT(c.sha) as "totalCommits",
                COUNT(DISTINCT c."repoId") as "repoCount"
            FROM "Commit" c
            JOIN "User" u ON c."userId" = u.id
            WHERE c.date >= ${startDate} AND c.date <= ${endDate}
            GROUP BY u.id, u.login, u.name, u."avatarUrl"
            ORDER BY "totalCommits" DESC
            LIMIT 50;
        `;

        const safeResults = (results as any[]).map(r => ({
            ...r,
            totalCommits: Number(r.totalCommits),
            repoCount: Number(r.repoCount)
        }));

        return safeResults;
    } catch (error) {
        console.error('[StatsService] Query Error:', error);
        throw error;
    }
};
