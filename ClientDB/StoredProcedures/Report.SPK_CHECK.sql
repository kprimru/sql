USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[SPK_CHECK]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[SPK_CHECK]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[SPK_CHECK]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE @ClientsWithSPK Table
    (
        CL_ID       Int         PRIMARY KEY CLUSTERED,
        SPK_CNT     TinyInt
    );

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

        INSERT INTO @ClientsWithSPK
        SELECT C.CL_ID, SPK.CNT
        FROM [PC275-SQL\DELTA].DBF.dbo.ClientTable AS C
        CROSS APPLY
        (
            SELECT CNT = COUNT(*)
            FROM [PC275-SQL\DELTA].DBF.dbo.ClientDistrView AS D WITH(NOEXPAND)
            INNER JOIN [PC275-SQL\DELTA].DBF.dbo.RegNodeView AS R WITH(NOEXPAND) ON D.SYS_REG_NAME = R.RN_SYS_NAME AND D.DIS_NUM = R.RN_DISTR_NUM AND D.DIS_COMP_NUM = R.RN_COMP_NUM
            WHERE D.CD_ID_CLIENT = C.CL_ID
                AND D.SYS_REG_NAME IN ('SPK-V', 'SPK-IV', 'SPK-III', 'SPK-II', 'SPK-I')
                AND R.RN_SERVICE = 0
                AND R.RN_DISTR_TYPE NOT IN ('DSP')
        ) AS SPK
        WHERE SPK.CNT != 0;


        SELECT
            [Клиент] = CL_PSEDO,
            [СПК|Количество] = SPK_CNT,
            [СПК|Разрешено] = SPK_AVAILABLE,
            [Перечень СПК] = REVERSE(STUFF(REVERSE(
            (
                SELECT D.DIS_STR + ', '
                FROM [PC275-SQL\DELTA].DBF.dbo.ClientDistrView AS D WITH(NOEXPAND)
                INNER JOIN [PC275-SQL\DELTA].DBF.dbo.RegNodeView AS R WITH(NOEXPAND) ON D.SYS_REG_NAME = R.RN_SYS_NAME AND D.DIS_NUM = R.RN_DISTR_NUM AND D.DIS_COMP_NUM = R.RN_COMP_NUM
                WHERE D.CD_ID_CLIENT = C.CL_ID
                    AND D.SYS_REG_NAME IN ('SPK-V', 'SPK-IV', 'SPK-III', 'SPK-II', 'SPK-I')
                    AND R.RN_SERVICE = 0
                    AND R.RN_DISTR_TYPE NOT IN ('DSP')
                ORDER BY SYS_ORDER, DIS_NUM, DIS_COMP_NUM FOR XML PATH('')
            )), 1, 2, '')),
            [Перечень основных дистрибутивов] = REVERSE(STUFF(REVERSE(
            (
                SELECT D.DIS_STR + ' (' +
                    CASE RN_TECH_TYPE
						WHEN 0 THEN
							CASE RN_NET_COUNT
								WHEN 0 THEN 'лок'
								WHEN 1 THEN '1/с'
								WHEN 5 THEN 'м/с'
								ELSE 'сеть'
							END
						WHEN 1 THEN 'флэш'
						WHEN 7 THEN 'ОВК'
						WHEN 3 THEN 'ОВП'
                        WHEN 4 THEN 'ОИВ'
						WHEN 6 THEN 'ОВПИ'
						WHEN 9 THEN 'ОВМ'
						WHEN 10 THEN 'ОВК-Ф'
                        WHEN 11 THEN 'ОВМ-Ф'
                        WHEN 13 THEN 'ОВС ' + CAST(RN_ODON AS VarCHar(100))
						ELSE 'Неизвестно'
					END + ')' + ', '
                FROM [PC275-SQL\DELTA].DBF.dbo.ClientDistrView AS D WITH(NOEXPAND)
                INNER JOIN [PC275-SQL\DELTA].DBF.dbo.RegNodeTable AS R ON D.SYS_REG_NAME = R.RN_SYS_NAME AND D.DIS_NUM = R.RN_DISTR_NUM AND D.DIS_COMP_NUM = R.RN_COMP_NUM
                WHERE D.CD_ID_CLIENT = C.CL_ID
                    AND D.SYS_REG_NAME NOT IN ('SPK-V', 'SPK-IV', 'SPK-III', 'SPK-II', 'SPK-I')
                    AND R.RN_SERVICE = 0
                    AND R.RN_DISTR_TYPE NOT IN ('DSP')
                    AND R.RN_REPORT_CODE = 'LAW'
                ORDER BY SYS_ORDER, DIS_NUM, DIS_COMP_NUM FOR XML PATH('')
            )), 1, 2, '')),
            [Все правильно] = Cast(CASE WHEN SPK_CNT > SPK_AVAILABLE THEN 0 ELSE 1 END AS Bit)
        FROM
        (
            SELECT C.CL_ID, C.SPK_CNT, SPK.SPK_AVAILABLE
            FROM @ClientsWithSPK AS C
            CROSS APPLY
            (
                SELECT [SPK_AVAILABLE] = SUM(SPK_AVAILABLE)
                FROM
                (
                    SELECT
                        SPK_AVAILABLE = CASE
                                            -- сеть или м/с
                                            WHEN RN_TECH_TYPE = 0 AND RN_NET_COUNT > 1 THEN 3
                                            -- ОВС
                                            WHEN RN_TECH_TYPE = 13 THEN 3
                                            -- с/о
                                            WHEN RN_TECH_TYPE = 0 AND RN_NET_COUNT = 1 THEN 1
                                            -- ОВМ-Ф
                                            WHEN RN_TECH_TYPE = 11 THEN 1
                                            ELSE 0
                                        END
                    FROM [PC275-SQL\DELTA].DBF.dbo.ClientDistrView AS D WITH(NOEXPAND)
                    INNER JOIN [PC275-SQL\DELTA].DBF.dbo.RegNodeView AS R WITH(NOEXPAND) ON D.SYS_REG_NAME = R.RN_SYS_NAME AND D.DIS_NUM = R.RN_DISTR_NUM AND D.DIS_COMP_NUM = R.RN_COMP_NUM
                    WHERE D.CD_ID_CLIENT = C.CL_ID
                        AND D.SYS_REG_NAME NOT IN ('SPK-V', 'SPK-IV', 'SPK-III', 'SPK-II', 'SPK-I')
                        AND R.RN_SERVICE = 0
                        AND R.RN_DISTR_TYPE NOT IN ('DSP')
                        AND R.RN_REPORT_CODE = 'LAW'
                ) AS SPK
            ) AS SPK
        ) AS SPK
        INNER JOIN [PC275-SQL\DELTA].DBF.dbo.ClientTable AS C ON C.CL_ID = SPK.CL_ID
        --WHERE SPK_CNT > SPK_AVAILABLE
        ORDER BY CL_PSEDO

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[SPK_CHECK] TO rl_report;
GO
