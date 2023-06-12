USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[TO_DISTR_STATUS_CHANGE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[TO_DISTR_STATUS_CHANGE]  AS SELECT 1')
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[TO_DISTR_STATUS_CHANGE]
	@tdid VARCHAR(MAX),
	@status SMALLINT
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

		DECLARE @list TABLE
			(
				TD_ID INT
			)

		INSERT INTO @list
			SELECT *
			FROM dbo.GET_TABLE_FROM_LIST(@tdid, ',')

		UPDATE dbo.ClientDistrTable
		SET
			CD_ID_SERVICE = @STATUS
		WHERE CD_ID_DISTR IN
			(
				SELECT TD_ID_DISTR
				FROM
					@list a
					INNER JOIN dbo.TODistrTable b ON a.TD_ID = b.TD_ID
			)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[TO_DISTR_STATUS_CHANGE] TO rl_client_distr_w;
GO
