USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACT_UNSIGN_SELECT]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@COUR	INT,
	@PSEDO	NVARCHAR(128)
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
			ACT_ID, CONVERT(BIT, 0) AS CHECKED, ACT_DATE, CL_PSEDO,
			DIS_NUM, DIS_STR, COUR_NAME
		FROM
			dbo.ActTable
			INNER JOIN dbo.ClientTable ON ACT_ID_CLIENT = CL_ID
			INNER JOIN dbo.CourierTable ON ACT_ID_COUR = COUR_ID
			OUTER APPLY
				(
					SELECT TOP 1 DIS_STR, DIS_NUM
					FROM
						dbo.ActDistrTable
						INNER JOIN dbo.DistrView WITH(NOEXPAND) ON DIS_ID = AD_ID_DISTR
					WHERE AD_ID_ACT = ACT_ID
					ORDER BY SYS_ORDER, DIS_NUM, DIS_COMP_NUM
				) AS o_O
		WHERE ACT_SIGN IS NULL
			AND (ACT_DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (ACT_DATE <= @END OR @END IS NULL)
			AND (ACT_ID_COUR = @COUR OR @COUR IS NULL)
			AND (CL_PSEDO LIKE @PSEDO OR @PSEDO IS NULL)
			AND EXISTS
				(
					SELECT *
					FROM dbo.ActDistrTable
					WHERE AD_ID_ACT = ACT_ID
				)
		ORDER BY COUR_NAME, DIS_NUM, CL_PSEDO

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[ACT_UNSIGN_SELECT] TO rl_act_w;
GO