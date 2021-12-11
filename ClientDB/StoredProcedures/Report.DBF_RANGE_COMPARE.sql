USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[DBF_RANGE_COMPARE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[DBF_RANGE_COMPARE]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[DBF_RANGE_COMPARE]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE @DBFServices TABLE
    (
        [Id]    SmallInt Primary Key Clustered
    );

    DECLARE @DBFTo Table
    (
        SysReg  VarChar(50),
        Distr   Int,
        Comp    TinyInt,
        Range   Decimal(4,2),
        Primary Key Clustered([Distr], [SysReg], [Comp])
    );

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

    INSERT INTO @DBFServices
    SELECT DISTINCT TO_ID_COUR
    FROM [PC275-SQL\DELTA].[DBF].dbo.TOTable
    WHERE TO_RANGE != 1;

    INSERT INTO @DBFTo
    SELECT D.SYS_REG_NAME, D.DIS_NUM, D.DIS_COMP_NUM, T.TO_RANGE
    FROM [PC275-SQL\DELTA].[DBF].dbo.TOTable AS T
    INNER JOIN @DBFServices AS S ON S.Id = T.TO_ID_COUR
    CROSS APPLY
    (
        SELECT TOP (1)
            SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM
        FROM [PC275-SQL\DELTA].[DBF].dbo.TODistrTable AS TD
        INNER JOIN [PC275-SQL\DELTA].[DBF].dbo.DistrView AS D WITH(NOEXPAND) ON D.DIS_ID = TD.TD_ID_DISTR
        LEFT JOIN [PC275-SQL\DELTA].[DBF].dbo.RegNodeTable AS R ON D.SYS_REG_NAME = R.RN_SYS_NAME AND D.DIS_NUM = R.RN_DISTR_NUM AND D.DIS_COMP_NUM = R.RN_COMP_NUM
        WHERE TD_ID_TO = TO_ID
        ORDER BY CASE WHEN RN_SERVICE = 0 THEN 1 ELSE 2 END, SYS_ORDER, DIS_NUM, DIS_COMP_NUM
    ) AS D;

    SELECT
        [СИ]        = C.ServiceName,
        [Клиент]    = C.ClientFullName,
        [Коэффициент удаленности|В ДК] = R.RangeValue,
        [Коэффициент удаленности|В DBF] = D.Range,
        [Осн.дистрибутив] = CD.DistrStr
    FROM @DBFTo AS D
    INNER JOIN dbo.ClientDistrView AS CD WITH(NOEXPAND) ON D.Distr = CD.DISTR AND D.Comp = CD.COMP AND D.SysReg = CD.SystemBaseName
    INNER JOIN dbo.ClientView AS C WITH(NOEXPAND) ON C.ClientID = CD.ID_CLIENT
    INNER JOIN dbo.ClientTable AS CC ON C.ClientID = CC.ClientID
    INNER JOIN dbo.RangeTable AS R ON CC.RangeID = R.RangeID
    WHERE D.Range != R.RangeValue
    ORDER BY C.Servicename, C.ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
