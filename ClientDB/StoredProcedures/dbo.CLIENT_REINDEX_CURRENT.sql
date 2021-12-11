USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_REINDEX_CURRENT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_REINDEX_CURRENT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_REINDEX_CURRENT]
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

		EXEC [Cache].[CLIENT_CACHE_REFRESH] @Client_Id = @ID;

		/*
		UPDATE A
		SET A.DisplayText = CA_STR
		FROM dbo.ClientAddressView				AS V
		INNER JOIN [Cache].[Client?Addresses]	AS A ON V.CA_ID_CLIENT = A.Id AND V.CA_ID_TYPE = A.[Type_Id]
		WHERE CA_ID_CLIENT = @ID

		INSERT INTO [Cache].[Client?Addresses]([Id], [Type_Id], [DisplayText])
		SELECT CA_ID_CLIENT, CA_ID_TYPE, CA_STR
		FROM dbo.ClientAddressView AS V
		WHERE CA_ID_CLIENT = @ID
			AND NOT EXISTS
				(
					SELECT *
					FROM [Cache].[Client?Addresses]	AS A
					WHERE V.CA_ID_CLIENT = A.Id AND V.CA_ID_TYPE = A.[Type_Id]
				);

		UPDATE [Cache].[Client?Names]
		SET [Names] =
				REVERSE(STUFF(REVERSE(
					(
						SELECT NAME + '; '
						FROM dbo.ClientNames
						WHERE ID_CLIENT = @ID
						ORDER BY NAME FOR XML PATH('')
					)), 1, 2, ''))
		WHERE Id = @ID

		IF @@RowCount = 0
			INSERT INTO [Cache].[Client?Names]([Id], [Names])
			SELECT
				@ID,
				REVERSE(STUFF(REVERSE(
					(
						SELECT NAME + '; '
						FROM dbo.ClientNames
						WHERE ID_CLIENT = @ID
						ORDER BY NAME FOR XML PATH('')
					)), 1, 2, ''));
		*/

		EXEC dbo.CLIENT_REINDEX @ID, NULL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_REINDEX_CURRENT] TO rl_client_save;
GO
