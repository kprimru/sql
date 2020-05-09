USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Cache].[CLIENT_CACHE_REFRESH]
	@Client_Id	Int				= NULL
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

		IF @Client_Id IS NOT NULL
		BEGIN
			UPDATE A
			SET DisplayText = CA_STR,
				DisplayTextFull = CA_FULL
			FROM dbo.ClientAddressView				AS V
			INNER JOIN [Cache].[Client?Addresses]	AS A ON V.CA_ID_CLIENT = A.Id AND V.CA_ID_TYPE = A.[Type_Id]
			WHERE CA_ID_CLIENT = @Client_Id

			INSERT INTO [Cache].[Client?Addresses]([Id], [Type_Id], [DisplayText], [DisplayTextFull])
			SELECT CA_ID_CLIENT, CA_ID_TYPE, CA_STR, CA_FULL
			FROM dbo.ClientAddressView AS V
			WHERE CA_ID_CLIENT = @Client_Id
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
							WHERE ID_CLIENT = @Client_Id
							ORDER BY NAME FOR XML PATH('')
						)), 1, 2, ''))
			WHERE Id = @Client_Id

			IF @@RowCount = 0
				INSERT INTO [Cache].[Client?Names]([Id], [Names])
				SELECT
					@Client_Id,
					REVERSE(STUFF(REVERSE(
						(
							SELECT NAME + '; '
							FROM dbo.ClientNames
							WHERE ID_CLIENT = @Client_Id
							ORDER BY NAME FOR XML PATH('')
						)), 1, 2, ''));
		END
		ELSE BEGIN
			TRUNCATE TABLE [Cache].[Client?Names];

			INSERT INTO [Cache].[Client?Names]([Id], [Names])
			SELECT
				C.ClientID,
				REVERSE(STUFF(REVERSE(
					(
						SELECT NAME + '; '
						FROM dbo.ClientNames
						WHERE ID_CLIENT = C.ClientID
						ORDER BY NAME FOR XML PATH('')
					)), 1, 2, ''))
			FROM dbo.ClientTable C
			WHERE STATUS = 1;

			TRUNCATE TABLE [Cache].[Client?Addresses];

			INSERT INTO [Cache].[Client?Addresses]([Id], [Type_Id], [DisplayText], [DisplayTextFull])
			SELECT CA_ID_CLIENT, CA_ID_TYPE, CA_STR, CA_FULL
			FROM dbo.ClientAddressView AS V
			INNER JOIN dbo.ClientTable AS C ON V.CA_ID_CLIENT = C.ClientID
			WHERE C.STATUS = 1;
		END;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
