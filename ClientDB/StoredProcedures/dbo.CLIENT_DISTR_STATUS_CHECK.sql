USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DISTR_STATUS_CHECK]
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

		DECLARE @STAT UNIQUEIDENTIFIER

		SELECT @STAT = DS_ID
		FROM dbo.DistrStatus
		WHERE DS_REG = 2

		UPDATE a
		SET ID_STATUS = @STAT
		FROM dbo.ClientDistr a
		INNER JOIN dbo.SystemTable b ON a.ID_SYSTEM = b.SystemID
		INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.SystemBaseName = b.SystemBaseName AND c.DistrNumber = a.DISTR AND c.CompNumber = a.COMP
		INNER JOIN dbo.DistrStatus d ON d.DS_ID = a.ID_STATUS
		WHERE d.DS_REG = 1 AND c.DS_REG = 2 AND a.STATUS = 1

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
