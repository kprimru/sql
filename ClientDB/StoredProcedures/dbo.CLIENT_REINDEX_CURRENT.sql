USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_REINDEX_CURRENT]
	@ID				INT
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS
		(
			SELECT *
			FROM dbo.ClientStudyClaim a
			WHERE ID_CLIENT = @ID
				AND UPD_USER = 'Автомат'
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.ClientStudyClaimPeople b
						WHERE a.ID = b.ID_CLAIM
					)
		)
	BEGIN
		INSERT INTO dbo.ClientStudyClaimPeople(ID_CLAIM, SURNAME, NAME, PATRON, POSITION, PHONE, GR_COUNT, NOTE)
			SELECT 
				(
					SELECT TOP 1 ID 
					FROM dbo.ClientStudyClaim a
					WHERE ID_CLIENT = @ID
						AND UPD_USER = 'Автомат'
						AND NOT EXISTS
							(
								SELECT *
								FROM dbo.ClientStudyClaimPeople b
								WHERE a.ID = b.ID_CLAIM
							)
				), CP_SURNAME, CP_NAME, CP_PATRON, CP_POS, CP_PHONE, NULL, ''
			FROM
				(
					SELECT CP_SURNAME, CP_NAME, CP_PATRON, CP_POS, CP_PHONE
					FROM dbo.ClientPersonalResView WITH(NOEXPAND)
					WHERE CP_ID_CLIENT = @ID
					
					UNION
					
					SELECT CP_SURNAME, CP_NAME, CP_PATRON, CP_POS, CP_PHONE
					FROM dbo.ClientPersonalBuhView WITH(NOEXPAND)
					WHERE CP_ID_CLIENT = @ID
				) AS o_O		
					
	END
	
	EXEC dbo.CLIENT_REINDEX @ID, NULL
END