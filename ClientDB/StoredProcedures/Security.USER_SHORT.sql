USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[USER_SHORT]
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
				FROM Security.Users
				WHERE US_LOGIN = ORIGINAL_LOGIN()
			)
			SELECT
				CASE ISNULL(US_SHORT, '')
					WHEN '' THEN ORIGINAL_LOGIN()
					ELSE US_SHORT
				END AS US_SHORT
			FROM Security.Users
			WHERE US_LOGIN = ORIGINAL_LOGIN()
		ELSE
			SELECT ORIGINAL_LOGIN() AS US_SHORT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Security].[USER_SHORT] TO public;
GO