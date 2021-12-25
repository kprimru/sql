USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ACT_CALC_EXISTS_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ACT_CALC_EXISTS_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ACT_CALC_EXISTS_SELECT]
	@BEGIN	SMALLDATETIME = NULL,
	@END	SMALLDATETIME = NULL,
	@FILTER	NVARCHAR(256) = NULL,
	@CONFRM	BIT	= NULL
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

		IF @END IS NULL
			SET @END = DATEADD(DAY, 1, @END)

		SELECT ID, DATE, USR, STATUS, ST_TEXT, SERVICE, CONFIRM_NEED, CONFIRM_USER, CONFIRM_DATE, CALC_STATUS
		FROM
			dbo.ActCalc a
			INNER JOIN dbo.ActCalcStatus b ON a.STATUS = b.ST
		WHERE (DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (DATE < @END OR @END IS NULL)
			AND (CONFIRM_NEED = 1 AND @CONFRM = 1 OR @CONFRM = 0 OR @CONFRM IS NULL)
			AND (@FILTER IS NULL OR SERVICE LIKE @FILTER OR EXISTS
					(
						SELECT *
						FROM
							dbo.ActCalcDetail z
							INNER JOIN dbo.ClientDistrView y WITH(NOEXPAND) ON z.SYS_REG = SystemBaseName AND z.DISTR = y.DISTR AND z.COMP = y.COMP
							INNER JOIN dbo.ClientView x WITH(NOEXPAND) ON ClientID = ID_CLIENT
						WHERE z.ID_MASTER = a.ID
							AND (z.DISTR LIKE @FILTER OR ClientFullName LIKE @FILTER)

					)
				)
		ORDER BY DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_CALC_EXISTS_SELECT] TO rl_act_calc;
GO
