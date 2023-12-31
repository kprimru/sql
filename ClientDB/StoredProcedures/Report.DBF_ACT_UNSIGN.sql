USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[DBF_ACT_UNSIGN]
	@PARAM	NVARCHAR(MAX) = NULL
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
        EXEC [PC275-SQL\DELTA].[DBF].[dbo].[ACT_UNSIGN_REPORT] @Date;

        SELECT
            [������]    = [Psedo],
            [��]        = [ServiceName],
            [���� ����] = [ActDate],
            [�����]     = [PeriodDate]
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
