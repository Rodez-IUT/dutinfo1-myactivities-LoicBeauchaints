CREATE OR REPLACE FUNCTION add_activity(in_title character varying(200),in_description text,in_owner_id bigint) RETURNS activity AS $$
	DECLARE
		defaultOwner "user"%rowtype;
		id_owner bigint;
		new_activity activity%rowtype;
	BEGIN
		defaultOwner = getDefaultOwner();
		
		IF in_owner_id IS NULL THEN
			id_owner = defaultOwner.id;
		ELSE
			id_owner = in_owner_id;
		END IF; 
		
		INSERT INTO activity (id, title, description, creation_date, modification_date, owner_id)
		VALUES (nextval('id_generator'), in_title, in_description, now(), now(), id_owner)
		RETURNING * INTO new_activity;
		
		RETURN new_activity;	
	END
$$ LANGUAGE plpgsql;