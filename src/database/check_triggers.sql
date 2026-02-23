
-- Check for triggers on feature_requests table
SELECT 
    event_object_schema as table_schema,
    event_object_table as table_name,
    trigger_name,
    event_manipulation as trigger_event,
    action_statement as trigger_action,
    action_timing as trigger_timing
FROM information_schema.triggers
WHERE event_object_table = 'feature_requests';
