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
            [Клиент]		= [Psedo],
            [СИ]			= [ServiceName],
			[Руководитель]	= C.[ManagerName],
            [Дата акта]		= [ActDate],
            [Месяц]			= [PeriodDate]
        FROM @Result AS R
		OUTER APPLY
		(
			SELECT TOP (1) D.[DIS_NUM], D.[DIS_COMP_NUM], D.[SYS_REG_NAME]
			FROM [DBF].[dbo.ClientDistrView] AS D
			WHERE D.[CD_ID_CLIENT] = R.[Id]
			ORDER BY D.[DSS_REPORT] DESC, D.[SYS_ORDER]
		) AS CD
		OUTER APPLY
		(
			SELECT TOP (1) C.[ManagerName]
			FROM [dbo].[ClientDistrView] AS D WITH(NOEXPAND)
			INNER JOIN [dbo].[ClientView] AS C WITH(NOEXPAND) ON C.[ClientID] = D.[ID_CLIENT]
			WHERE D.[SystemBaseName] = CD.[SYS_REG_NAME]
				AND D.[DISTR] = CD.[DIS_NUM]
				AND D.[COMP] = CD.[DIS_COMP_NUM]
		) AS C
        ORDER BY 2, 3, 1, 5, 4;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
