-- Row Level Security Policies for Admin-Only Access
-- This file contains RLS policies that restrict all table access to admin users only

-- Enable RLS on all tables
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE phones ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_phones ENABLE ROW LEVEL SECURITY;
ALTER TABLE images ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE statuses ENABLE ROW LEVEL SECURITY;
ALTER TABLE listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE listing_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE listing_phones ENABLE ROW LEVEL SECURITY;
ALTER TABLE listing_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE opening_hours ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_networks ENABLE ROW LEVEL SECURITY;
ALTER TABLE test ENABLE ROW LEVEL SECURITY;

-- Create admin-only policies for each table

-- Roles table - Admin only
CREATE POLICY "Admins only - roles" ON roles 
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

-- Users table - Admin only
CREATE POLICY "Admins only - users" ON users 
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

-- Addresses table - Admin only
CREATE POLICY "Admins only - addresses" ON addresses 
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

-- User addresses table - Admin only
CREATE POLICY "Admins only - user_addresses" ON user_addresses 
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

-- Phones table - Admin only
CREATE POLICY "Admins only - phones" ON phones 
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

-- User phones table - Admin only
CREATE POLICY "Admins only - user_phones" ON user_phones 
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

-- Images table - Admin only
CREATE POLICY "Admins only - images" ON images 
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

-- User images table - Admin only
CREATE POLICY "Admins only - user_images" ON user_images 
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

-- Tasks table - Admin only
CREATE POLICY "Admins only - tasks" ON tasks 
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

-- Statuses table - Admin only
CREATE POLICY "Admins only - statuses" ON statuses 
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

-- Listings table - Admin only
CREATE POLICY "Admins only - listings" ON listings 
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

-- Listing images table - Admin only
CREATE POLICY "Admins only - listing_images" ON listing_images 
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

-- Listing phones table - Admin only
CREATE POLICY "Admins only - listing_phones" ON listing_phones 
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

-- Listing logs table - Admin only
CREATE POLICY "Admins only - listing_logs" ON listing_logs 
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

-- Interactions table - Admin only
CREATE POLICY "Admins only - interactions" ON interactions 
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

-- Opening hours table - Admin only
CREATE POLICY "Admins only - opening_hours" ON opening_hours 
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

-- Social networks table - Admin only
CREATE POLICY "Admins only - social_networks" ON social_networks 
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

-- Test table - Admin only
CREATE POLICY "Admins only - test" ON test 
    FOR ALL USING (is_admin()) WITH CHECK (is_admin()); 