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

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

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
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END