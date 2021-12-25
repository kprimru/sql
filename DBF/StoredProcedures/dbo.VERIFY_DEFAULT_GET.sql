USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:
Дата создания:
Описание:
*/

ALTER PROCEDURE [dbo].[VERIFY_DEFAULT_GET]
	@clientid INT,
	@date SMALLDATETIME
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

		SELECT
			ORG_ID, ORG_SHORT_NAME, dbo.GET_SETTING('ORG_BUH') AS BUH_NAME,
			CL_FULL_NAME,
			(
				SELECT SUM(SL_REST)
				FROM
					(
						SELECT
							ISNULL((
								SELECT TOP 1 SL_REST
								FROM dbo.SaldoTable b
								WHERE SL_ID_CLIENT = @clientid
									AND a.SL_ID_DISTR = b.SL_ID_DISTR
									AND SL_DATE < @date
								ORDER BY SL_DATE DESC, SL_TP DESC, SL_ID DESC
								), 0) AS SL_REST
						FROM
							(
								SELECT DISTINCT SL_ID_DISTR
								FROM dbo.SaldoTable
								WHERE SL_ID_CLIENT = @clientid
							) AS a
					) AS O_O
			) AS SL_REST,
			Cast (CASE
			        WHEN EXISTS
			            (
			                SELECT TOP (1) *
			                FROM dbo.DistrFinancingView AS D
			                INNER JOIN dbo.SystemNetTable AS SN ON D.SN_ID = SN.SN_ID
				            INNER JOIN dbo.SystemNetCountTable AS SNC ON SNC_ID_SN = SN.SN_ID
				            WHERE SNC_TECH IN (3, 4, 6, 7, 9, 10, 11, 13)
			                    AND D.CD_ID_CLIENT = @clientid
			                    AND DSS_REPORT = 1
			            )
			            THEN 1
			        ELSE 0
			    END AS Bit)AS IsOnline,
			CO_DATE, CO_NUM
		FROM dbo.ClientTable
		LEFT JOIN dbo.OrganizationTable ON CL_ID_ORG = ORG_ID
		OUTER APPLY
		(
		    SELECT TOP (1) CO_DATE, CO_NUM
		    FROM
		    (
		        SELECT TOP (1)
		            1 AS TP, CO_NUM, CO_DATE
		        FROM dbo.ContractTable
		        WHERE CO_ID_CLIENT = CL_ID
		            AND @date BETWEEN CO_BEG_DATE AND ISNULL(CO_END_DATE, '20500101')
		        ORDER BY CO_DATE DESC, CO_ACTIVE DESC

		        UNION ALL

				SELECT TOP (1)
				    2 AS TP, CO_NUM, CO_DATE
				FROM dbo.ContractTable
				WHERE CO_ID_CLIENT = CL_ID
				    AND CO_ACTIVE = 1
		    ) AS C
		) AS C
		WHERE CL_ID = @clientid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[VERIFY_DEFAULT_GET] TO rl_report_verify_r;
GO
