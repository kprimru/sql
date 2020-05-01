USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[REFERENCE_LAST_NEW]
	@REF	NVARCHAR(60) = NULL,
	@DATE	DATETIME = NULL
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

		SELECT ReferenceSchema + '.' + ReferenceName AS [Reference], ReferenceLast AS [Last]
		FROM Common.Reference
		WHERE
			(@REF = ReferenceSchema+'.'+ReferenceName OR @REF IS NULL) AND
			(@DATE < ReferenceLast OR @DATE IS NULL)
		ORDER BY ReferenceSchema, ReferenceName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Common].[REFERENCE_LAST_NEW] TO public;
GO