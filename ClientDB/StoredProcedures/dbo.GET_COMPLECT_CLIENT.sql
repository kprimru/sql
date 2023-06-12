USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GET_COMPLECT_CLIENT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[GET_COMPLECT_CLIENT]  AS SELECT 1')
GO

ALTER PROCEDURE [dbo].[GET_COMPLECT_CLIENT]
	@COMPLECTNAME		VarChar(50),
	@ClientShortName	VarChar(100) OUTPUT,
	@ClientFullName		VarChar(250) OUTPUT
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

		EXECUTE AS USER = 'CLAIM_VIEW';

		SELECT TOP 1
			@ClientShortName = C.[ClientFullName],
			@ClientFullName = C.[ClientFullName]
		FROM USR.USRActiveView U
		INNER JOIN dbo.ClientTable C ON C.ClientID = U.UD_ID_CLIENT
		INNER JOIN dbo.SystemTable s ON s.SystemID = u.UF_ID_SYSTEM
		WHERE dbo.DistrString(s.SystemShortName, U.UD_DISTR, U.UD_COMP) = @COMPLECTNAME

		REVERT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[GET_COMPLECT_CLIENT] TO DBService;
GRANT EXECUTE ON [dbo].[GET_COMPLECT_CLIENT] TO public;
GO
