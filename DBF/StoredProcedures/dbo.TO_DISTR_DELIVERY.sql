USE [DBF]
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

ALTER PROCEDURE [dbo].[TO_DISTR_DELIVERY]
	@tdid VARCHAR(MAX),
	@toid INT
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
		
		UPDATE dbo.TODistrTable
		SET							
			TD_ID_TO = @toid
		WHERE TD_ID IN
			(
				SELECT TD_ID
				FROM @list
			)
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[TO_DISTR_DELIVERY] TO rl_to_distr_w;
GO