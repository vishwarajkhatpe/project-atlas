DROP POLICY IF EXISTS "Users can insert themselves or creators can add" ON public.trip_members;
CREATE POLICY "Users can insert themselves via invitation or creators can add" ON public.trip_members FOR INSERT WITH CHECK (
    trip_id IN (SELECT id FROM public.trips WHERE created_by = auth.uid()) OR 
    (
        user_id = auth.uid() AND 
        EXISTS (
            SELECT 1 FROM public.trip_invitations 
            WHERE trip_id = trip_members.trip_id 
            AND email = (auth.jwt()->>'email')::text 
        )
    )
);

DROP POLICY IF EXISTS "Users can update their own invitations" ON public.trip_invitations;
CREATE POLICY "Users can update their own invitations" ON public.trip_invitations FOR UPDATE USING (
    email = (auth.jwt()->>'email')::text
);
