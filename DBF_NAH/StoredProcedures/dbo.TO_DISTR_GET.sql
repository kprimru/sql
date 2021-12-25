USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[TO_DISTR_GET]
	@tdid VARCHAR(MAX)
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

		DECLARE @td TABLE
			(
				TD_ID INT
			)

		INSERT INTO @td
			SELECT *
			FROM dbo.GET_TABLE_FROM_LIST(@tdid, ',')

		DECLARE @dislist VARCHAR(MAX)
		SET @dislist = ''

		SELECT @dislist = @dislist + DIS_STR + ','
		FROM dbo.TODistrView
		WHERE TD_ID IN
			(
				SELECT TD_ID
				FROM @td
			)

		IF LEN(@dislist) > 0
			SET @dislist = LEFT(@dislist, LEN(@dislist) - 1)

		SELECT @dislist AS DIS_STR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[TO_DISTR_GET] TO rl_client_r;
GRANT EXECUTE ON [dbo].[TO_DISTR_GET] TO rl_to_distr_r;
GO
