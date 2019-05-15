-- Fonction pour inscrire un utilisateur sur une activité
CREATE OR REPLACE FUNCTION register_user_on_activity(inscr_user_id bigint, inscr_activity_id bigint) RETURNS registration AS $$
	DECLARE
		user_on_activity registration%rowtype;
	BEGIN
		IF EXISTS (SELECT * FROM registration WHERE user_id = inscr_user_id AND activity_id = inscr_activity_id) THEN
			RAISE EXCEPTION 'registration_already_exists';
		ELSE
			INSERT INTO registration (id,registration_date,user_id,activity_id)
			VALUES (nextval('id_generator'),now(),inscr_user_id, inscr_activity_id);
		END IF;	
		SELECT * INTO user_on_activity 
		FROM registration 
		WHERE user_id = inscr_user_id AND activity_id = inscr_activity_id;
		
		RETURN user_on_activity;
	END
$$ LANGUAGE plpgsql;

-- Fonction trigger pour register_user_on_activity
CREATE OR REPLACE FUNCTION log_insert_activity() RETURNS TRIGGER AS $$
	BEGIN
    	INSERT INTO action_log (id, action_name, entity_name, entity_id, author, action_date)
        VALUES  (nextval('id_generator'),'insert', 'registration',NEW.id, user, now());
    RETURN NULL; -- le résultat est ignoré car il s'agit d'un trigger AFTER
	END
$$ language plpgsql;

DROP TRIGGER IF EXISTS log_insert_activity ON registration;

-- Trigger lorsque l'on enregistre une activité dans registration
CREATE TRIGGER log_insert_activity 
	AFTER INSERT ON registration
FOR EACH ROW EXECUTE PROCEDURE log_insert_activity();

-- Fonction pour désinscrire un utilisateur sur une activité
CREATE OR REPLACE FUNCTION unregister_user_on_activity(desincr_user_id bigint, desincr_activity_id bigint) RETURNS void AS $$
	BEGIN
		IF NOT EXISTS (SELECT * FROM registration WHERE user_id = desincr_user_id AND activity_id = desincr_activity_id) THEN
			RAISE EXCEPTION 'registration_not_found';
		ELSE
			DELETE FROM registration
			WHERE user_id = desincr_user_id AND activity_id = desincr_activity_id;
		END IF;
	END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS log_delete_activity ON registration;

-- Trigger lorsque l'on enlève une activité dans registration
CREATE OR REPLACE FUNCTION log_delete_activity()
    RETURNS TRIGGER AS $$
BEGIN
     INSERT INTO action_log (id, action_name, entity_name, entity_id, author, action_date)
     VALUES (nextval('id_generator'),'delete', 'registration', OLD.id, user, now());
     RETURN NULL; -- le résultat est ignoré car il s'agit d'un trigger AFTER
END;
$$ language plpgsql;

-- Trigger lorsque l'on désinscrit une activité dans registration
CREATE TRIGGER log_delete_activity
    AFTER DELETE ON registration
FOR EACH ROW EXECUTE PROCEDURE log_delete_activity();