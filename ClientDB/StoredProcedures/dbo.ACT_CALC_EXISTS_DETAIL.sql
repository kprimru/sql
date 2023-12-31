USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACT_CALC_EXISTS_DETAIL]
	@ID		UNIQUEIDENTIFIER,
	@CONFRM	BIT = NULL
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

		SELECT ClientFullName, DistrStr, MON, CALC_NOTE, CALC_DATE
		FROM
			dbo.ActCalcDetail a
			INNER JOIN dbo.SystemTable d ON a.SYS_REG = d.SystemBaseName
			INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON d.HostID = b.HostID AND a.DISTR = b.DISTR AND a.COMP = b.COMP
			INNER JOIN dbo.ClientTable c ON c.ClientID = b.ID_CLIENT
		WHERE a.ID_MASTER = @ID
			AND (a.CONFRM = 1 AND @CONFRM = 1 OR @CONFRM = 0 OR @CONFRM IS NULL)
		ORDER BY ClientFullName, MON, b.SystemOrder, a.DISTR, a.COMP

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_CALC_EXISTS_DETAIL] TO rl_act_calc;
GO
