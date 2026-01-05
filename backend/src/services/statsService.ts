import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const getLeaderboard = async (period: string) => {
    let startDate = new Date(0); // All time start
    let endDate = new Date();    // Now

    const now = new Date();
    // Reset time part to midnight for cleaner calculations
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    // Helper to get start of week (Monday)
    const getStartOfWeek = (d: Date) => {
        const day = d.getDay();
        const diff = d.getDate() - day + (day === 0 ? -6 : 1); // adjust when day is sunday
        return new Date(d.setDate(diff));
    };

    switch (period) {
        case 'yesterday':
            startDate = new Date(today);
            startDate.setDate(today.getDate() - 1);
            endDate = new Date(today); // Until start of today (midnight)
            break;

        case 'last_week':
            // Move to last week
            const lastWeek = new Date(today);
            lastWeek.setDate(lastWeek.getDate() - 7);
            const startOfLastWeek = getStartOfWeek(new Date(lastWeek));
            startDate = new Date(startOfLastWeek.getFullYear(), startOfLastWeek.getMonth(), startOfLastWeek.getDate());

            // End of last week is start of this week
            const startOfThisWeek = getStartOfWeek(new Date(today));
            endDate = new Date(startOfThisWeek.getFullYear(), startOfThisWeek.getMonth(), startOfThisWeek.getDate());
            break;

        case 'this_week':
            const thisWeekStart = getStartOfWeek(new Date(today));
            startDate = new Date(thisWeekStart.getFullYear(), thisWeekStart.getMonth(), thisWeekStart.getDate());
            endDate = new Date(); // To now
            break;

        case 'last_month':
            startDate = new Date(today.getFullYear(), today.getMonth() - 1, 1);
            endDate = new Date(today.getFullYear(), today.getMonth(), 1);
            break;

        case 'this_month':
            startDate = new Date(today.getFullYear(), today.getMonth(), 1);
            endDate = new Date(); // To now
            break;

        case 'last_year':
            startDate = new Date(today.getFullYear() - 1, 0, 1);
            endDate = new Date(today.getFullYear(), 0, 1);
            break;

        case 'all_time':
        default:
            // Default is All Time, but user requested Default 'This Month' in UI, wait, logic for 'all_time' stays same.
            // If function called with 'this_month', it hits case above.
            break;
    }

    // Using Raw SQL for better performance and grouping capabilities
    // This query counts commits per user within range
    // It joins User table to get details.

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
        WHERE c.date >= ${startDate} AND c.date < ${endDate}
        GROUP BY u.id, u.login, u.name, u."avatarUrl"
        ORDER BY "totalCommits" DESC
        LIMIT 50;
    `;

    // Cast BigInt to Number for JSON serialization
    const safeResults = (results as any[]).map(r => ({
        ...r,
        totalCommits: Number(r.totalCommits),
        repoCount: Number(r.repoCount)
    }));

    return safeResults;
};
