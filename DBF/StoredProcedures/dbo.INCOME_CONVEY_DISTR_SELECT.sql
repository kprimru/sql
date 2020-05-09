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
ALTER PROCEDURE [dbo].[INCOME_CONVEY_DISTR_SELECT]
	@incomeid INT
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

		SELECT o_O.DIS_ID, o_O.DIS_STR, DSS_REPORT, DSS_NAME
		FROM
			(
				SELECT DIS_ID, DIS_STR
				FROM dbo.ClientDistrView
				WHERE --DSS_REPORT = 1
					--AND
					CD_ID_CLIENT =
						(
							SELECT IN_ID_CLIENT
							FROM dbo.IncomeTable
							WHERE IN_ID = @incomeid
						)
				UNION

				SELECT a.DIS_ID, a.DIS_STR
				FROM
					dbo.DistrView a WITH(NOEXPAND) INNER JOIN
					dbo.DistrView b WITH(NOEXPAND) ON a.DIS_NUM = b.DIS_NUM
								AND a.DIS_COMP_NUM = b.DIS_COMP_NUM
								AND a.HST_ID = b.HST_ID INNER JOIN
					dbo.ClientDistrView c ON c.DIS_ID = b.DIS_ID
				WHERE CD_ID_CLIENT =
						(
							SELECT IN_ID_CLIENT
							FROM dbo.IncomeTable
							WHERE IN_ID = @incomeid
						)
				UNION

				SELECT DIS_ID, DIS_STR
				FROM dbo.ActDistrView
				WHERE --DSS_REPORT = 1
				--AND
					ACT_ID_CLIENT =
					(
						SELECT IN_ID_CLIENT
						FROM dbo.IncomeTable
						WHERE IN_ID = @incomeid
					)
			) AS o_O LEFT OUTER JOIN
			dbo.ClientDistrView a ON a.CD_ID_DISTR = o_O.DIS_ID
		ORDER BY DSS_REPORT DESC, DIS_STR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[INCOME_CONVEY_DISTR_SELECT] TO rl_income_w;
GO