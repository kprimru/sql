USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DISTR_TYPE_COEF_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DISTR_TYPE_COEF_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[DISTR_TYPE_COEF_SELECT]
	@NET	INT,
	@PERIOD	UNIQUEIDENTIFIER
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

		SELECT NAME, DistrTypeName, COEF, WEIGHT, RND, b.ID, c.DistrTypeID
		FROM
			dbo.DistrTypeCoef a
			INNER JOIN Common.Period b ON a.ID_MONTH = b.ID
			INNER JOIN dbo.DistrTypeTable c ON c.DistrTypeID = a.ID_NET
		WHERE (DistrTypeID = @NET OR @NET IS NULL)
			AND (b.ID = @PERIOD OR @PERIOD IS NULL)
			AND START <= DATEADD(MONTH, 3, GETDATE())
		ORDER BY START DESC, DistrTypeOrder

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[DISTR_TYPE_COEF_SELECT] TO rl_distr_type_u;
GO
