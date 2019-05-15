CREATE OR REPLACE FUNCTION add_activity(in_title character varying(200),in_description text,in_owner_id bigint) RETURNS activity AS $$
	DECLARE
		add_activity activity%ROWTYPE;
	BEGIN
		
	END
$$ LANGUAGE plpgsql;