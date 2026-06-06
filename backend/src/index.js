const express = require('express');
const cors = require('cors');
const { seed } = require('./seed');

const authRoutes = require('./routes/api/auth');
const weddingRoutes = require('./routes/api/wedding');
const budgetRoutes = require('./routes/api/budget');
const venuesRoutes = require('./routes/api/venues');
const venueInquiriesRoutes = require('./routes/api/venue_inquiries');
const vendorsRoutes = require('./routes/api/vendors');
const bookingsRoutes = require('./routes/api/bookings');
const guestsRoutes = require('./routes/api/guests');
const seatingRoutes = require('./routes/api/seating');
const tasksRoutes = require('./routes/api/tasks');
const timelineRoutes = require('./routes/api/timeline');
const inspirationsRoutes = require('./routes/api/inspirations');
const contractsRoutes = require('./routes/api/contracts');
const notificationsRoutes = require('./routes/api/notifications');

seed();

const app = express();
const PORT = process.env.PORT || 3022;

app.use(cors({ origin: true }));
app.use(express.json());

app.get('/health', (_req, res) => res.json({ ok: true, service: 'wedding-planner' }));

app.use('/api/auth', authRoutes);
app.use('/api/wedding', weddingRoutes);
app.use('/api/budget', budgetRoutes);
app.use('/api/venues', venuesRoutes);
app.use('/api/venue-inquiries', venueInquiriesRoutes);
app.use('/api/vendors', vendorsRoutes);
app.use('/api/bookings', bookingsRoutes);
app.use('/api/guests', guestsRoutes);
app.use('/api/seating', seatingRoutes);
app.use('/api/tasks', tasksRoutes);
app.use('/api/timeline', timelineRoutes);
app.use('/api/inspirations', inspirationsRoutes);
app.use('/api/contracts', contractsRoutes);
app.use('/api/notifications', notificationsRoutes);

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Wedding planner backend running at http://localhost:${PORT}`);
    console.log(`API base: http://localhost:${PORT}/api`);
  });
}

module.exports = app;
