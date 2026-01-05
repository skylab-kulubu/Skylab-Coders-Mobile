import express from 'express';
import cors from 'cors';
import { PrismaClient } from '@prisma/client';
import { startCronJobs } from './services/cronService';
import { getLeaderboard } from './services/statsService';

const app = express();
const prisma = new PrismaClient();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Basic endpoint
app.get('/', (req, res) => {
  res.send('SkyLab Coders API is running');
});

// Stats Endpoints
app.get('/stats', async (req, res) => {
  const { period } = req.query; // 'daily', 'weekly', 'monthly', 'all_time'
  // TODO: Fetch from CacheLog or compute
  try {
    const data = await getLeaderboard(period as string || 'monthly');
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch stats' });
  }
});



// Users Endpoint
app.get('/users', async (req, res) => {
  try {
    const users = await prisma.user.findMany({
      orderBy: {
        commits: {
          _count: 'desc'
        }
      }
    });
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

// Repositories Endpoint
app.get('/repos', async (req, res) => {
  try {
    const repos = await prisma.repository.findMany({
      orderBy: { updatedAt: 'desc' }
    });
    res.json(repos);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch repositories' });
  }
});

// Recent Commits Endpoint
app.get('/commits', async (req, res) => {
  try {
    const commits = await prisma.commit.findMany({
      take: 100,
      orderBy: { date: 'desc' },
      include: {
        repo: true,
        user: true
      }
    });
    res.json(commits);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch commits' });
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
  startCronJobs();

  // Initial Sync on Restart
  console.log('Triggering initial data sync...');
  import('./services/githubService').then(m => m.syncGitHubData());
});
