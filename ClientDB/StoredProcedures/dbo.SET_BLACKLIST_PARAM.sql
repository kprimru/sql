USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SET_BLACKLIST_PARAM]
@PARAMNAME varchar(50),
@ParamValue varchar(2048)
WITH EXECUTE AS OWNER
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

		if EXISTS (
		SELECT ID
		FROM dbo.BLACK_LIST_PARAMS
		WHERE PARAMNAME=@PARAMNAME)
		BEGIN
			UPDATE dbo.BLACK_LIST_PARAMS SET PARAMVALUE=@ParamValue
			WHERE PARAMNAME=@PARAMNAME
		END
		ELSE
		BEGIN
			INSERT INTO dbo.BLACK_LIST_PARAMS (PARAMNAME,PARAMVALUE)
			VALUES (@PARAMNAME, @ParamValue)
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[SET_BLACKLIST_PARAM] TO BL_ADMIN;
GRANT EXECUTE ON [dbo].[SET_BLACKLIST_PARAM] TO BL_PARAM;
GO