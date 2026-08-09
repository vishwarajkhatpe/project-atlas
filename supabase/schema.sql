-- ==========================================
-- PROJECT ATLAS - SUPABASE MVP SCHEMA V1
-- ==========================================

-- 1. USERS
-- Extends the default auth.users table in Supabase
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT NOT NULL,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Trigger to automatically create a public.users row on signup
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, full_name, avatar_url)
  VALUES (new.id, COALESCE(new.raw_user_meta_data->>'full_name', 'Unknown User'), new.raw_user_meta_data->>'avatar_url');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 2. TRIPS
-- The core entity for any journey
CREATE TABLE public.trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    cover_image_url TEXT,
    start_date DATE,
    end_date DATE,
    created_by UUID REFERENCES public.users(id) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. TRIP MEMBERS
-- Handles who is in the trip and their permissions
CREATE TYPE member_role AS ENUM ('owner', 'planner', 'member');

CREATE TABLE public.trip_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    role member_role DEFAULT 'member',
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(trip_id, user_id) -- A user can only join a trip once
);

-- 4. TRIP INVITATIONS
-- Tracks pending invitations for users to join trips
CREATE TYPE invitation_status AS ENUM ('pending', 'accepted', 'declined');

CREATE TABLE public.trip_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    invited_by UUID REFERENCES public.users(id) ON DELETE CASCADE,
    role member_role DEFAULT 'member',
    status invitation_status DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(trip_id, email)
);

ALTER TABLE public.trip_invitations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Trip creators and planners can view invitations" ON public.trip_invitations FOR SELECT USING (
    trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid() AND role IN ('owner', 'planner'))
);
CREATE POLICY "Users can view invitations sent to their email" ON public.trip_invitations FOR SELECT USING (
    email = (auth.jwt()->>'email')
);
CREATE POLICY "Trip creators and planners can insert invitations" ON public.trip_invitations FOR INSERT WITH CHECK (
    trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid() AND role IN ('owner', 'planner'))
);
CREATE POLICY "Users can update their own invitations" ON public.trip_invitations FOR UPDATE USING (
    email = (auth.jwt()->>'email')
);
CREATE POLICY "Trip creators and planners can delete invitations" ON public.trip_invitations FOR DELETE USING (
    trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid() AND role IN ('owner', 'planner'))
);

-- 5. PROPOSALS (The Consensus Engine)
-- Proposals can be for a destination, dates, accommodation, or activities.
CREATE TYPE proposal_type AS ENUM ('destination', 'dates', 'accommodation', 'activity', 'other');
CREATE TYPE proposal_status AS ENUM ('pending', 'approved', 'rejected');

CREATE TABLE public.proposals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE,
    proposed_by UUID REFERENCES public.users(id) NOT NULL,
    type proposal_type NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    status proposal_status DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. VOTES
-- Tracks how members vote on proposals
CREATE TYPE vote_value AS ENUM ('approve', 'reject', 'abstain');

CREATE TABLE public.votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    proposal_id UUID REFERENCES public.proposals(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    vote vote_value NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(proposal_id, user_id) -- A user can only vote once per proposal
);
-- 6. ITINERARY
-- Official locked-in plans for a trip
CREATE TABLE public.itinerary_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    location TEXT,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    created_by UUID REFERENCES public.users(id) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trip_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.proposals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.itinerary_events ENABLE ROW LEVEL SECURITY;

-- 1. USERS POLICIES
CREATE POLICY "Users can view all profiles" ON public.users FOR SELECT USING (true);
CREATE POLICY "Users can insert their own profile" ON public.users FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update their own profile" ON public.users FOR UPDATE USING (auth.uid() = id);

-- 2. TRIPS POLICIES
CREATE POLICY "Users can view trips they are a member of or created" ON public.trips FOR SELECT USING (
    created_by = auth.uid() OR id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid())
);
CREATE POLICY "Users can create trips" ON public.trips FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Users can update their trips" ON public.trips FOR UPDATE USING (
    id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid() AND role IN ('owner', 'planner'))
);
CREATE POLICY "Owners can delete their trips" ON public.trips FOR DELETE USING (
    id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid() AND role = 'owner')
);

-- Allow authenticated users to see trip members safely via SECURITY DEFINER function
CREATE OR REPLACE FUNCTION public.is_trip_member(_trip_id uuid, _user_id uuid)
RETURNS boolean LANGUAGE sql SECURITY DEFINER STABLE AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.trip_members
    WHERE trip_id = _trip_id AND user_id = _user_id
  );
$$;

CREATE POLICY "Members can view their trip's roster" ON public.trip_members FOR SELECT USING (
    public.is_trip_member(trip_id, auth.uid())
);
-- Allow users to insert themselves, or allow trip creators to add others
CREATE POLICY "Users can insert themselves or creators can add" ON public.trip_members FOR INSERT WITH CHECK (
    user_id = auth.uid() OR trip_id IN (SELECT id FROM public.trips WHERE created_by = auth.uid())
);
CREATE POLICY "Owners can update trip members" ON public.trip_members FOR UPDATE USING (
    trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid() AND role = 'owner')
);
CREATE POLICY "Owners can delete trip members or members can leave" ON public.trip_members FOR DELETE USING (
    user_id = auth.uid() OR trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid() AND role = 'owner')
);
-- 4. PROPOSALS POLICIES
CREATE POLICY "Users can view proposals for their trips" ON public.proposals FOR SELECT USING (
    trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid())
);
CREATE POLICY "Users can insert proposals for their trips" ON public.proposals FOR INSERT WITH CHECK (
    trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid())
);
CREATE POLICY "Planners and Owners can update proposals" ON public.proposals FOR UPDATE USING (
    trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid() AND role IN ('owner', 'planner'))
);
CREATE POLICY "Creators, planners, and owners can delete proposals" ON public.proposals FOR DELETE USING (
    proposed_by = auth.uid() OR trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid() AND role IN ('owner', 'planner'))
);

-- 5. VOTES POLICIES
CREATE POLICY "Users can view votes for their trips" ON public.votes FOR SELECT USING (
    proposal_id IN (SELECT id FROM public.proposals WHERE trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid()))
);
CREATE POLICY "Users can vote on proposals for their trips" ON public.votes FOR INSERT WITH CHECK (
    proposal_id IN (SELECT id FROM public.proposals WHERE trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid()))
    AND user_id = auth.uid()
);
CREATE POLICY "Users can update their own votes" ON public.votes FOR UPDATE USING (
    user_id = auth.uid()
);
CREATE POLICY "Users can delete their own votes" ON public.votes FOR DELETE USING (
    user_id = auth.uid()
);

-- 6. ITINERARY POLICIES
CREATE POLICY "Users can view itinerary for their trips" ON public.itinerary_events FOR SELECT USING (
    trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid())
);
CREATE POLICY "Planners and Owners can insert itinerary events" ON public.itinerary_events FOR INSERT WITH CHECK (
    trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid() AND role IN ('owner', 'planner'))
);
CREATE POLICY "Planners and Owners can update itinerary events" ON public.itinerary_events FOR UPDATE USING (
    trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid() AND role IN ('owner', 'planner'))
);
CREATE POLICY "Planners and Owners can delete itinerary events" ON public.itinerary_events FOR DELETE USING (
    trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid() AND role IN ('owner', 'planner'))
);

-- 7. EXPENSES
CREATE TABLE public.expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE,
    paid_by UUID REFERENCES public.users(id) NOT NULL,
    title TEXT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    currency TEXT DEFAULT 'USD',
    expense_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view expenses for their trips" ON public.expenses FOR SELECT USING (
    trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid())
);
CREATE POLICY "Users can insert expenses for their trips" ON public.expenses FOR INSERT WITH CHECK (
    trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid())
);
CREATE POLICY "Users can update their own expenses or planners/owners can update" ON public.expenses FOR UPDATE USING (
    paid_by = auth.uid() OR trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid() AND role IN ('owner', 'planner'))
);
CREATE POLICY "Users can delete their own expenses or planners/owners can delete" ON public.expenses FOR DELETE USING (
    paid_by = auth.uid() OR trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid() AND role IN ('owner', 'planner'))
);

-- 8. MESSAGES
CREATE TABLE public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- 9. ENABLE REALTIME
alter publication supabase_realtime add table messages;
alter publication supabase_realtime add table trips;
alter publication supabase_realtime add table trip_members;
alter publication supabase_realtime add table proposals;
alter publication supabase_realtime add table votes;
alter publication supabase_realtime add table itinerary_events;
alter publication supabase_realtime add table expenses;

CREATE POLICY "Users can view messages for their trips" ON public.messages FOR SELECT USING (
    trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid())
);
CREATE POLICY "Users can insert messages for their trips" ON public.messages FOR INSERT WITH CHECK (
    trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid()) AND auth.uid() = user_id
);

-- ==========================================
-- STORED PROCEDURES (RPC)
-- ==========================================

-- Atomic Trip Creation
CREATE OR REPLACE FUNCTION public.create_trip_with_owner(
  p_title text, p_description text, p_start_date date, p_end_date date
) RETURNS public.trips LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE new_trip public.trips;
BEGIN
  INSERT INTO public.trips (title, description, start_date, end_date, created_by)
  VALUES (p_title, p_description, p_start_date, p_end_date, auth.uid())
  RETURNING * INTO new_trip;

  INSERT INTO public.trip_members (trip_id, user_id, role)
  VALUES (new_trip.id, auth.uid(), 'owner');

  RETURN new_trip;
END; $$;
