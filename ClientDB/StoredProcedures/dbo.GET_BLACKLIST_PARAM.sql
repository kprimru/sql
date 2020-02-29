USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GET_BLACKLIST_PARAM]
@PARAMNAME varchar(50),
@paramValue varchar(2048) OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @paramValue = ''
		SET NOCOUNT ON
		SET @paramValue=(SELECT PARAMVALUE
		FROM dbo.BLACK_LIST_PARAMS
		WHERE PARAMNAME=@PARAMNAME)
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END