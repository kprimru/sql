USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_PAY_REPORT]
	@ID	INT
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
			D.DistrStr,
			P.LAST_ACT,
			P.LAST_PAY_MON,
			/*c.NEXT_MONTH AS 'ближайшие незакрытый мес€ц', */
			P.PAY_DELTA,
			P.LAST_BILL_SUM
		FROM dbo.ClientDistrView AS D WITH(NOEXPAND)
		OUTER APPLY
		(
			SELECT TOP (1) *
			FROM dbo.DBFDistrLastPayView AS P
			WHERE	P.SYS_REG_NAME = D.SystemBaseName
				AND P.DIS_NUM = D.DISTR
				AND P.DIS_COMP_NUM = D.COMP
		) AS P
		WHERE	D.ID_CLIENT = @ID
			AND D.DS_REG = 0
		ORDER BY D.SystemOrder, D.DISTR, D.COMP
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
