/**
 * Setup demo account in database
 */
import sqlite3 from 'sqlite3';
import bcryptjs from 'bcryptjs';

const db = new sqlite3.Database('./data/friend.db', (err) => {
    if (err) {
        console.error('❌ Database error:', err);
        process.exit(1);
    }
    console.log('✅ Connected to database');
});

// Create demo account
const demoUser = {
    username: 'demo',
    email: 'demo@friend.app',
    password: 'demo123',
    fullName: 'Demo User',
    bio: 'Learning with Friend App'
};

async function setupDemo() {
    try {
        const hashedPassword = await bcryptjs.hash(demoUser.password, 10);
        
        db.run(
            'INSERT OR IGNORE INTO users (username, email, password, fullName, bio) VALUES (?, ?, ?, ?, ?)',
            [demoUser.username, demoUser.email, hashedPassword, demoUser.fullName, demoUser.bio],
            function(err) {
                if (err) {
                    console.error('❌ Error creating demo account:', err.message);
                } else {
                    console.log('✅ Demo account created!');
                    console.log('');
                    console.log('📧 Email: ' + demoUser.email);
                    console.log('🔑 Password: ' + demoUser.password);
                    console.log('');
                    console.log('🌐 Go to: http://localhost:3000/login.html');
                }
                db.close();
                process.exit(0);
            }
        );
    } catch (error) {
        console.error('❌ Error:', error);
        db.close();
        process.exit(1);
    }
}

setupDemo();
