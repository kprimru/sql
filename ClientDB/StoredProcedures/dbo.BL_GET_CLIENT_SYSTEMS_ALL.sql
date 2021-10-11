USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[BL_GET_CLIENT_SYSTEMS_ALL]
     @clientid INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT
			f.ID,
			a.SystemShortName, a.SystemID, a.SystemBaseName,
			DISTR AS SystemDistrNumber, COMP AS CompNumber,
			SystemTypeName,
			a.DistrTypeName,
			a.DS_NAME AS ServiceStatusName,
			f.Complect
		FROM dbo.ClientDistrView a WITH(NOEXPAND)
		INNER JOIN Reg.RegNodeSearchView f WITH(NOEXPAND) ON	f.SystemBaseName = a.SystemBaseName
															AND f.DistrNumber = a.DISTR
															AND f.CompNumber = a.COMP
		WHERE  ID_CLIENT = @clientid
		ORDER BY a.DS_INDEX, a.SystemOrder

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[BL_GET_CLIENT_SYSTEMS_ALL] TO BL_ADMIN;
GRANT EXECUTE ON [dbo].[BL_GET_CLIENT_SYSTEMS_ALL] TO BL_EDITOR;
GRANT EXECUTE ON [dbo].[BL_GET_CLIENT_SYSTEMS_ALL] TO BL_PARAM;
GRANT EXECUTE ON [dbo].[BL_GET_CLIENT_SYSTEMS_ALL] TO BL_READER;
GRANT EXECUTE ON [dbo].[BL_GET_CLIENT_SYSTEMS_ALL] TO BL_RGT;
GO
