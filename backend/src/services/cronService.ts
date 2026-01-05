import cron from 'node-cron';
import { syncGitHubData } from './githubService';

export const startCronJobs = () => {
    console.log('Initializing cron jobs...');

    // Her gün 00:00 ve 12:00
    cron.schedule('0 0,12 * * *', async () => {
        console.log('Running scheduled sync...');
        try {
            await syncGitHubData();
            console.log('Sync completed successfully.');
        } catch (error) {
            console.error('Sync failed:', error);
            // Eski veri veritabanında, bir şey yapmaya gerek yok.
        }
    });
};
