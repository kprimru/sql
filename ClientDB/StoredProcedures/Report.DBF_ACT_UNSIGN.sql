USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[DBF_ACT_UNSIGN]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[DBF_ACT_UNSIGN]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[DBF_ACT_UNSIGN]
	@PARAM	NVARCHAR(MAX) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE @Date SmallDateTime;
    DECLARE @Result Table
    (
        [Id]            Int,
        [Psedo]         VarChar(100),
        [ServiceName]   VarChar(100),
        [ActDate]       SmallDateTime,
        [PeriodDate]    SmallDateTime
    );

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @Date = GetDate()

        INSERT INTO @Result
        EXEC [DBF].[dbo].[ACT_UNSIGN_REPORT] @Date;

        SELECT
            [Клиент]    = [Psedo],
            [СИ]        = [ServiceName],
            [Дата акта] = [ActDate],
            [Месяц]     = [PeriodDate]
        FROM @Result
        ORDER BY 2, 1, 4, 3

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
