-- Seed data for the database

-- Define UUIDs for reuse
DO $$
DECLARE
    -- Role IDs
    admin_role_id UUID := '11111111-1111-1111-1111-111111111111';
    partner_role_id UUID := '22222222-2222-2222-2222-222222222222';
    customer_role_id UUID := '33333333-3333-3333-3333-333333333333';

    -- User IDs
    admin_user_id UUID := '44444444-4444-4444-4444-444444444444';
    partner_user_id UUID := '55555555-5555-5555-5555-555555555555';
    customer_user_id UUID := '10101010-1010-1010-1010-101010101010';

    -- Address IDs
    address_id UUID := '66666666-6666-6666-6666-666666666666';

    -- Phone IDs
    phone_id UUID := '77777777-7777-7777-7777-777777777777';

    -- Image IDs
    image_id1 UUID := '88888888-8888-8888-8888-888888888888';
    image_id2 UUID := '99999999-9999-9999-9999-999999999999';

    -- Task IDs
    task_id UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

    -- Status IDs
    status_draft_id UUID := 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
    status_ready_for_review_id UUID := 'cccccccc-cccc-cccc-cccc-cccccccccccc';
    status_under_review_id UUID := 'dddddddd-dddd-dddd-dddd-dddddddddddd';
    status_changes_requested_id UUID := 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee';
    status_approved_id UUID := 'ffffffff-ffff-ffff-ffff-ffffffffffff';
    status_published_id UUID := 'a6a6a6a6-a6a6-a6a6-a6a6-a6a6a6a6a6a6';
    status_rejected_id UUID := 'a7a7a7a7-a7a7-a7a7-a7a7-a7a7a7a7a7a7';
    status_expired_id UUID := 'a8a8a8a8-a8a8-a8a8-a8a8-a8a8a8a8a8a8';
    status_archived_id UUID := 'a9a9a9a9-a9a9-a9a9-a9a9-a9a9a9a9a9a9';
    status_canceled_id UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1';

    -- Listing IDs
    listing_id UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2';
BEGIN

-- Insert roles
INSERT INTO roles (id, name) VALUES
(admin_role_id, 'admin'),
(partner_role_id, 'partner'),
(customer_role_id, 'customer');

-- Create auth.users
PERFORM create_user(admin_user_id, 'admin@example.com', 'Mente_0Unica123');
PERFORM create_user(partner_user_id, 'partner@example.com', 'Mente_0Unica123');
PERFORM create_user(customer_user_id, 'customer@example.com', 'Mente_0Unica123');

-- Insert users
INSERT INTO users (id, email, role_id, username) VALUES
(admin_user_id, 'admin@example.com', admin_role_id, 'admin'),
(partner_user_id, 'partner@example.com', partner_role_id, 'partner'),
(customer_user_id, 'customer@example.com', customer_role_id, 'customer');

-- Insert addresses
INSERT INTO addresses (id, latitude, longitude, city, district, street_number, street, region, country, postal_code, formatted_address) VALUES
(address_id, 19.432608, -99.133209, 'Mexico City', 'Centro', '123', 'Reforma Avenue', 'CDMX', 'Mexico', '06000', '123 Reforma Avenue, Centro, Mexico City, CDMX, Mexico 06000');

-- Insert user_addresses
INSERT INTO user_addresses (id, user_id, address_id, is_primary) VALUES
('66666666-6666-6666-6666-666666666666', admin_user_id, address_id, TRUE);

-- Insert phones
INSERT INTO phones (id, number, is_primary, is_verified, country_code) VALUES
(phone_id, '5551234567', TRUE, TRUE, '+52');

-- Insert user_phones
INSERT INTO user_phones (id, user_id, phone_id) VALUES
('88888888-8888-8888-8888-888888888888', admin_user_id, phone_id);

-- Insert images
INSERT INTO images (id, url, is_primary) VALUES
(image_id1, 'https://example.com/images/restaurant.jpg', TRUE),
(image_id2, 'https://example.com/images/restaurant2.jpg', FALSE);

-- Insert user_images
INSERT INTO user_images (id, user_id, image_id) VALUES
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', admin_user_id, image_id1);

-- Insert tasks
INSERT INTO tasks (id, task_uid, task_type, task_status) VALUES
(task_id, 1001, 'listing_creation', 'succeeded');

-- Insert statuses
INSERT INTO statuses (id, name, description) VALUES
(status_draft_id, 'Draft', 'The listing is being created or updated by the partner'),
(status_ready_for_review_id, 'Ready for Review', 'The partner has finished editing and submitted the draft for admin review'),
(status_under_review_id, 'Under Review', 'The admin is actively reviewing the draft'),
(status_changes_requested_id, 'Changes Requested', 'The admin has completed the review and requires changes from the partner'),
(status_approved_id, 'Approved', 'The admin has approved the draft, and it is ready for the partner to publish'),
(status_published_id, 'Published', 'The listing is live and visible to customers'),
(status_rejected_id, 'Rejected', 'The admin has rejected the draft due to violations or critical issues, preventing further updates'),
(status_expired_id, 'Expired', 'The draft has been automatically archived due to inactivity (e.g., no updates or actions for 30 days)'),
(status_archived_id, 'Archived', 'A previously published listing has been replaced by a new version or is no longer active'),
(status_canceled_id, 'Canceled', 'The draft or listing has been canceled by the partner or admin');

-- Insert listings
INSERT INTO listings (id, name, owner_id, address_id, description, status, task_id) VALUES
(listing_id, 'Taqueria El Buen Sabor', admin_user_id, address_id, 'Authentic Mexican taqueria with the best tacos in town. We offer a variety of traditional Mexican dishes in a cozy atmosphere.', 'published', task_id);

-- Insert listing_images
INSERT INTO listing_images (id, listing_id, image_id) VALUES
('b6b6b6b6-b6b6-b6b6-b6b6-b6b6b6b6b6b6', listing_id, image_id1),
('c7c7c7c7-c7c7-c7c7-c7c7-c7c7c7c7c7c7', listing_id, image_id2);

-- Insert listing_phones
INSERT INTO listing_phones (id, listing_id, phone_id) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', listing_id, phone_id);

-- Insert listing_logs
INSERT INTO listing_logs (id, listing_id, status, task_id, changed_by_id, version, comment) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', listing_id, 'published', task_id, admin_user_id, 1, 'Initial creation of listing');

-- Insert interactions
INSERT INTO interactions (id, name, listing_id, user_id) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'view', listing_id, admin_user_id);

-- Insert opening_hours
INSERT INTO opening_hours (id, listing_id, day_of_week, open_time, close_time, is_closed) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6', listing_id, 1, '09:00:00', '21:00:00', FALSE),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa7', listing_id, 2, '09:00:00', '21:00:00', FALSE),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa8', listing_id, 3, '09:00:00', '21:00:00', FALSE),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa9', listing_id, 4, '09:00:00', '21:00:00', FALSE),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', listing_id, 5, '09:00:00', '22:00:00', FALSE),
('cccccccc-cccc-cccc-cccc-cccccccccccc', listing_id, 6, '10:00:00', '22:00:00', FALSE),
('dddddddd-dddd-dddd-dddd-dddddddddddd', listing_id, 0, '10:00:00', '20:00:00', FALSE);

-- Insert social_networks
INSERT INTO social_networks (id, listing_id, network, url, handle) VALUES
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', listing_id, 'instagram', 'https://instagram.com/elbuensabor', 'elbuensabor'),
('ffffffff-ffff-ffff-ffff-ffffffffffff', listing_id, 'facebook', 'https://facebook.com/elbuensabor', 'elbuensabor');

END $$;