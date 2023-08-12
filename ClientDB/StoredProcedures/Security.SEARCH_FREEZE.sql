USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[SEARCH_FREEZE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[SEARCH_FREEZE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Security].[SEARCH_FREEZE]
	@CS_ID	UNIQUEIDENTIFIER,
	@CHECK	BIT
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

		IF @CHECK = 1
			INSERT INTO Security.ClientSearch(CS_TYPE, CS_SHORT, CS_SEARCH, CS_FREEZE)
				SELECT CS_TYPE, CS_SHORT, CS_SEARCH, 1
				FROM Security.ClientSearch
				WHERE CS_ID = @CS_ID
		ELSE
			DELETE
			FROM Security.ClientSearch
			WHERE CS_ID = @CS_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[SEARCH_FREEZE] TO public;
GO
