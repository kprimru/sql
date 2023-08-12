USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[Client=Tech@Save]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[Client=Tech@Save]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[Client=Tech@Save]
	@Client_Id	Int,
	@Note		VarChar(Max)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE @AddressType_Id	UniqueIdentifier;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY
		WITH T AS
		(
			SELECT [Client_Id], [Note]
			FROM [dbo].[Client=Tech]
		)
		MERGE T
		USING
		(
			SELECT
				[Client_Id] = @Client_Id,
				[Note]		= @Note
		) AS V ON V.[Client_Id] = T.[Client_Id]
		WHEN NOT MATCHED BY TARGET THEN
			INSERT ([Client_Id], [Note])
			VALUES(V.[Client_Id], V.[Note])
		WHEN MATCHED THEN
			UPDATE SET
				[Note] = V.[Note];

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[Client=Tech@Save] TO rl_client_tech;
GO
