-- ==========================================
-- PROJECT ATLAS - SUPABASE MVP SCHEMA V1
-- ==========================================

-- 1. USERS
-- Extends the default auth.users table in Supabase
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    full_name TEXT NOT NULL,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

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

-- 4. PROPOSALS (The Consensus Engine)
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

-- ==========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trip_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.proposals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.votes ENABLE ROW LEVEL SECURITY;

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

-- 3. TRIP MEMBERS POLICIES
CREATE POLICY "Users can view members of their trips" ON public.trip_members FOR SELECT USING (
    trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid())
);
CREATE POLICY "Users can add members if they are owner/planner or adding themselves" ON public.trip_members FOR INSERT WITH CHECK (
    user_id = auth.uid() OR trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid() AND role IN ('owner', 'planner'))
);
