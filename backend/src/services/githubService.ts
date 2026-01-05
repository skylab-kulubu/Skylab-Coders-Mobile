import axios from 'axios';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const ORG_NAME = 'skylab-kulubu';
const GITHUB_API = 'https://api.github.com';
const TOKEN = process.env.GITHUB_TOKEN;

const headers = TOKEN ? { Authorization: `Bearer ${TOKEN}` } : {};

export const syncGitHubData = async () => {
    console.log('Starting GitHub Sync...');
    // 1. Fetch Repos
    const repos = await fetchRepos();

    // 2. Upsert Repos & Fetch Commits
    for (const repo of repos) {
        await prisma.repository.upsert({
            where: { githubId: repo.id },
            update: {
                name: repo.name,
                fullName: repo.full_name,
                stargazersCount: repo.stargazers_count,
                updatedAt: new Date(repo.updated_at),
            },
            create: {
                githubId: repo.id,
                name: repo.name,
                fullName: repo.full_name,
                htmlUrl: repo.html_url,
                description: repo.description,
                language: repo.language,
                stargazersCount: repo.stargazers_count,
                updatedAt: new Date(repo.updated_at),
            }
        });

        // Fetch commits for this repo (last 100 or since last sync?)
        // For simplicity in this demo, fetching recent commits.
        await fetchAndStoreCommits(repo);
    }
};

async function fetchRepos() {
    let allRepos: any[] = [];
    let page = 1;
    while (true) {
        try {
            const res = await axios.get(`${GITHUB_API}/orgs/${ORG_NAME}/repos?per_page=100&page=${page}`, { headers });
            const data = res.data;
            if (data.length === 0) break;
            allRepos.push(...data);
            if (data.length < 100) break;
            page++;
        } catch (e) {
            console.error('Error fetching repos:', e);
            break;
        }
    }
    return allRepos;
}

async function fetchAndStoreCommits(repo: any) {
    // Get DB repo ID
    const dbRepo = await prisma.repository.findUnique({ where: { githubId: repo.id } });
    if (!dbRepo) return;

    // Check last commit date
    const lastCommit = await prisma.commit.findFirst({
        where: { repoId: dbRepo.id },
        orderBy: { date: 'desc' }
    });

    let sinceParams = '';
    if (lastCommit) {
        // Add 1 second to avoid duplicate fetch of the last commit
        const lastDate = new Date(lastCommit.date.getTime() + 1000);
        sinceParams = `&since=${lastDate.toISOString()}`;
        console.log(`Fetching commits for ${repo.name} since ${lastDate.toISOString()}`);
    } else {
        console.log(`Fetching all commits for ${repo.name}`);
    }

    try {
        const res = await axios.get(`${GITHUB_API}/repos/${repo.full_name}/commits?per_page=100${sinceParams}`, { headers });
        const commits = res.data;

        for (const c of commits) {
            const sha = c.sha;
            const author = c.commit.author;
            const user = c.author; // GitHub User object (login, id, avatar_url)

            let userId = null;

            if (user) {
                // Upsert User
                const dbUser = await prisma.user.upsert({
                    where: { githubId: user.id },
                    update: {
                        login: user.login,
                        avatarUrl: user.avatar_url,
                        email: author.email, // Best effort
                    },
                    create: {
                        githubId: user.id,
                        login: user.login,
                        avatarUrl: user.avatar_url,
                        name: author.name,
                        email: author.email,
                    }
                });
                userId = dbUser.id;
            }

            // Upsert Commit
            await prisma.commit.upsert({
                where: { sha: sha },
                update: {},
                create: {
                    sha: sha,
                    message: c.commit.message,
                    date: new Date(author.date),
                    htmlUrl: c.html_url,
                    repoId: dbRepo.id,
                    userId: userId,
                    authorName: author.name,
                    authorEmail: author.email
                }
            });
        }
    } catch (e: any) {
        if (e.response && e.response.status === 409) {
            console.warn(`Repo ${repo.name} is empty (No commits). Skipping.`);
        } else if (e.response && e.response.status === 404) {
            console.warn(`Repo ${repo.name} not found or private. Skipping.`);
        } else {
            console.error(`Error fetching commits for ${repo.name}:`, e.message || e);
        }
    }
}
