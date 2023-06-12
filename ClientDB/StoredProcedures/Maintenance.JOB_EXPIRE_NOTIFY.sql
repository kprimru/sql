USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[JOB_EXPIRE_NOTIFY]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Maintenance].[JOB_EXPIRE_NOTIFY]  AS SELECT 1')
GO
ALTER PROCEDURE [Maintenance].[JOB_EXPIRE_NOTIFY]
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

		DECLARE
			@Prefix	NVarChar(Max),
			@Text	NVarChar(Max);

		SET @Prefix = 'Следующие задания давно не выполнялись:' + Char(10);
		SET @Text = '';

		SELECT @Text = @Text + JT.[Name] + '     последний запуск  ' + Convert(VarChar(20), Start, 104) + ' ' + Convert(VarChar(20), Start, 108) + Char(10)
		FROM Maintenance.JobType JT
		CROSS APPLY
		(
			SELECT TOP 1 Start
			FROM Maintenance.Jobs J
			WHERE JT.Id = J.Type_Id
			ORDER BY Start DESC
		) AS J
		WHERE ExpireTime IS NOT NULL
			AND DateDiff(second, Start, GetDate()) > JT.ExpireTime

		IF @Text != '' BEGIN
			SET @Text = @Prefix + @Text;

			EXEC [Maintenance].[MAIL_SEND]
				@TEXT = @Text;
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
