USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[Client=Tech@Select]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[Client=Tech@Select]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[Client=Tech@Select]
	@Client_Id	Int
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
		SELECT [Note]
		FROM [dbo].[Client=Tech] AS T
		WHERE T.[Client_Id] = @Client_Id;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[Client=Tech@Select] TO rl_client_tech;
GO
