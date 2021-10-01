USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ClientTypeRules@Select]
	@SystemsIDs     VarChar(Max) = NULL,
	@DistrTypesIDs  VarChar(Max) = NULL,
	@ClientTypesIDs VarChar(Max) = NULL
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

		SELECT [System_Id], [DistrType_Id], [ClientType_Id]
		FROM dbo.ClientTypeRules AS R
		WHERE   (@SystemsIDs IS NULL OR R.[System_Id] IN (SELECT ID FROM dbo.TableIDFromXML(@SystemsIDs)))
		    AND (@DistrTypesIDs IS NULL OR R.[DistrType_Id] IN (SELECT ID FROM dbo.TableIDFromXML(@DistrTypesIDs)))
		    AND (@ClientTypesIDs IS NULL OR R.[ClientType_Id] IN (SELECT ID FROM dbo.TableIDFromXML(@ClientTypesIDs)))

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ClientTypeRules@Select] TO rl_client_type_r;
GO
