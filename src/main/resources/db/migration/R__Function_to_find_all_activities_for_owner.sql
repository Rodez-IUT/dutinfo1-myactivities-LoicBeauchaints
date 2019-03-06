CREATE OR REPLACE FUNCTION find_all_activities_for_owner(ownername varchar(100)) RETURNS SETOF activity AS 
$BODY$
  	SELECT a.*
  	FROM activity a
  	JOIN "user" u
  	ON owner_id = u.id
  	WHERE username = ownername;
$BODY$ LANGUAGE SQL;

 