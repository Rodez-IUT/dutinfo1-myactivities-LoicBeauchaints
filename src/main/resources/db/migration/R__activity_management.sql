CREATE OR REPLACE FUNCTION add_activity(in_title character varying(200),in_description text,in_owner_id bigint default null) RETURNS activity AS $$
	DECLARE
		defaultOwner "user"%rowtype;
		id_new_activity bigint;
		new_activity activity%rowtype;
	BEGIN
		defaultOwner := get_default_owner();
		id_new_activity := nextval('id_generator');
		
		IF in_owner_id IS NULL THEN
			in_owner_id := defaultOwner.id;
		END IF; 
		
		INSERT INTO activity (id, title, description, creation_date, modification_date, owner_id)
		VALUES (id_new_activity, in_title, in_description, now(), now(), in_owner_id);
		
		SELECT * INTO new_activity
		FROM activity
		WHERE id = id_new_activity;
		
		RETURN new_activity;	
	END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION find_all_activities(OUT activities_cursor refcursor) AS $$
BEGIN
	OPEN activities_cursor FOR
        SELECT act.id AS id, title, description, creation_date, modification_date, owner_id, username
        FROM activity act 
        LEFT JOIN "user" owner
        ON act.owner_id = owner.id
        ORDER BY title, username;
END
$$ LANGUAGE plpgsql;