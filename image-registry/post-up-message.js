#!/usr/bin/env node
import chalk from 'chalk';
import dotenv from 'dotenv';
import { join } from 'path';

// Load environment variables from .env file
dotenv.config({ path: join(process.cwd(), '.env') });

// Required environment variables
const requiredEnvVars = [
  'NODE_ENV',
  'DATABASE_URL',
  'MEILI_ENV',
  'MEILI_MASTER_KEY',
  'MEILI_SEARCH_HOST',
  'MEILI_TASK_WEBHOOK_URL',
  'MEILI_TASK_WEBHOOK_SECRET'
];

// Check if all required environment variables are defined
const missingVars = requiredEnvVars.filter(varName => !process.env[varName]);

if (missingVars.length > 0) {
  console.error(chalk.red.bold('\n❌ Missing required environment variables:'));
  missingVars.forEach(varName => {
    console.error(chalk.red(`  - ${varName}`));
  });
  console.error(chalk.red('\nPlease check your .env file and ensure all variables are defined.'));
  process.exit(1);
}

// Extract port from MEILI_SEARCH_HOST (no fallback)
const meilisearchPort = process.env.MEILI_SEARCH_HOST.includes('localhost') ? 
  process.env.MEILI_SEARCH_HOST.split(':')[2] : '7700';
const meilisearchUIPort = '24900'; // This is defined in docker-compose.yml

console.log(chalk.green.bold('\n✅ Meilisearch & Meilisearch UI are running!'));
console.log('\nAccess your services:');
console.log(chalk.cyan('  Meilisearch API:   ') + chalk.yellow(`http://localhost:${meilisearchPort}`));
console.log(chalk.cyan('  Meilisearch UI:    ') + chalk.yellow(`http://localhost:${meilisearchUIPort}`));

console.log('\nEnvironment Configuration:');
console.log(chalk.cyan('  Node Environment:  ') + chalk.yellow(process.env.NODE_ENV));
console.log(chalk.cyan('  Database URL:      ') + chalk.yellow(process.env.DATABASE_URL));
console.log(chalk.cyan('  Meili Environment: ') + chalk.yellow(process.env.MEILI_ENV));
console.log(chalk.cyan('  Master Key:        ') + chalk.magenta(process.env.MEILI_MASTER_KEY));
console.log(chalk.cyan('  Search Host:       ') + chalk.yellow(process.env.MEILI_SEARCH_HOST));
console.log(chalk.cyan('  Webhook URL:       ') + chalk.yellow(process.env.MEILI_TASK_WEBHOOK_URL));
console.log(chalk.cyan('  Webhook Secret:    ') + chalk.yellow(process.env.MEILI_TASK_WEBHOOK_SECRET)) ;
console.log(chalk.cyan('  Webhook Auth Header: ') + chalk.yellow(process.env.MEILI_TASK_WEBHOOK_AUTHORIZATION_HEADER || 'Not set'));

console.log('\nTo stop the services:');
console.log(chalk.cyan('  npm run docker:down'));
console.log('\nHappy developing!\n');