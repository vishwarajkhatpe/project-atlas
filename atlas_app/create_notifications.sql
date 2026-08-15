-- ==========================================
-- ATLAS MVP IN-APP NOTIFICATIONS
-- ==========================================

-- 1. Create the notifications table
CREATE TABLE public.notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE NOT NULL,
    type TEXT NOT NULL, -- e.g., 'trip_invite', 'new_proposal', 'new_vote', 'proposal_finalized', 'new_event', 'new_expense', 'new_message'
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    reference_id UUID, -- For linking to a specific proposal, expense, etc.
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Enable RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notifications"
ON public.notifications FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications (mark as read)"
ON public.notifications FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own notifications"
ON public.notifications FOR DELETE
USING (auth.uid() = user_id);

-- System can insert (we use security definer triggers, so no insert policy needed for users)

-- 3. Helper function to notify all trip members EXCEPT a specific user
CREATE OR REPLACE FUNCTION notify_trip_members(
    p_trip_id UUID,
    p_exclude_user_id UUID,
    p_type TEXT,
    p_title TEXT,
    p_body TEXT,
    p_ref_id UUID
) RETURNS VOID AS $$
BEGIN
    INSERT INTO public.notifications (user_id, trip_id, type, title, body, reference_id)
    SELECT tm.user_id, p_trip_id, p_type, p_title, p_body, p_ref_id
    FROM public.trip_members tm
    WHERE tm.trip_id = p_trip_id AND tm.user_id != p_exclude_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ==========================================
-- TRIGGERS
-- ==========================================

-- Trigger: Added to Trip
CREATE OR REPLACE FUNCTION trigger_notify_trip_member() RETURNS TRIGGER AS $$
BEGIN
    -- Do not notify if the person adding them is themselves (e.g. creating the trip)
    IF NEW.user_id != auth.uid() THEN
        INSERT INTO public.notifications (user_id, trip_id, type, title, body)
        VALUES (NEW.user_id, NEW.trip_id, 'trip_invite', 'Added to Trip', 'You have been added to a new trip.');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_trip_member_added ON public.trip_members;
CREATE TRIGGER on_trip_member_added
AFTER INSERT ON public.trip_members
FOR EACH ROW EXECUTE FUNCTION trigger_notify_trip_member();


-- Trigger: New Proposal & Finalized
CREATE OR REPLACE FUNCTION trigger_notify_proposal() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        PERFORM notify_trip_members(NEW.trip_id, NEW.proposed_by, 'new_proposal', 'New Proposal', 'A new proposal "' || NEW.title || '" was added.', NEW.id);
    ELSIF TG_OP = 'UPDATE' THEN
        IF NEW.status != OLD.status AND NEW.status IN ('approved', 'rejected') THEN
            PERFORM notify_trip_members(NEW.trip_id, auth.uid(), 'proposal_finalized', 'Proposal ' || initcap(NEW.status), 'The proposal "' || NEW.title || '" was ' || NEW.status || '.', NEW.id);
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_proposal_change ON public.proposals;
CREATE TRIGGER on_proposal_change
AFTER INSERT OR UPDATE ON public.proposals
FOR EACH ROW EXECUTE FUNCTION trigger_notify_proposal();


-- Trigger: Someone Voted
CREATE OR REPLACE FUNCTION trigger_notify_vote() RETURNS TRIGGER AS $$
DECLARE
    v_trip_id UUID;
    v_proposed_by UUID;
    v_title TEXT;
BEGIN
    SELECT trip_id, proposed_by, title INTO v_trip_id, v_proposed_by, v_title 
    FROM public.proposals WHERE id = NEW.proposal_id;

    -- Only notify the proposer, and only if the proposer isn't the one voting
    IF v_proposed_by != NEW.user_id THEN
        INSERT INTO public.notifications (user_id, trip_id, type, title, body, reference_id)
        VALUES (v_proposed_by, v_trip_id, 'new_vote', 'New Vote', 'Someone voted on your proposal: ' || v_title, NEW.proposal_id);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_vote_added ON public.votes;
CREATE TRIGGER on_vote_added
AFTER INSERT ON public.votes
FOR EACH ROW EXECUTE FUNCTION trigger_notify_vote();


-- Trigger: New Itinerary Event
CREATE OR REPLACE FUNCTION trigger_notify_itinerary_event() RETURNS TRIGGER AS $$
BEGIN
    PERFORM notify_trip_members(NEW.trip_id, NEW.created_by, 'new_event', 'New Itinerary Event', 'An event "' || NEW.title || '" was added to the itinerary.', NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_itinerary_added ON public.itinerary_events;
CREATE TRIGGER on_itinerary_added
AFTER INSERT ON public.itinerary_events
FOR EACH ROW EXECUTE FUNCTION trigger_notify_itinerary_event();


-- Trigger: New Expense
CREATE OR REPLACE FUNCTION trigger_notify_expense() RETURNS TRIGGER AS $$
BEGIN
    PERFORM notify_trip_members(NEW.trip_id, NEW.paid_by, 'new_expense', 'New Expense', 'A new expense "' || NEW.description || '" was added.', NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_expense_added ON public.expenses;
CREATE TRIGGER on_expense_added
AFTER INSERT ON public.expenses
FOR EACH ROW EXECUTE FUNCTION trigger_notify_expense();


-- Trigger: New Chat Message
CREATE OR REPLACE FUNCTION trigger_notify_chat_message() RETURNS TRIGGER AS $$
BEGIN
    -- For MVP, notify on every message (can be noisy, but satisfies requirements)
    PERFORM notify_trip_members(NEW.trip_id, NEW.user_id, 'new_message', 'New Message', 'Someone sent a new message in the trip chat.', NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_chat_message_added ON public.messages;
CREATE TRIGGER on_chat_message_added
AFTER INSERT ON public.messages
FOR EACH ROW EXECUTE FUNCTION trigger_notify_chat_message();

-- Enable Realtime for notifications table
alter publication supabase_realtime add table public.notifications;
