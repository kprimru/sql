USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DISTR_TYPE_COEF_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DISTR_TYPE_COEF_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[DISTR_TYPE_COEF_SAVE]
	@NET	INT,
	@PERIOD	UNIQUEIDENTIFIER,
	@COEF	DECIMAL(8, 4),
	@WEIGHT	DECIMAL(8, 4),
	@RND	SMALLINT,
	@NEXT	BIT
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

		DECLARE @PR_DATE SMALLDATETIME

		SELECT @PR_DATE = START
		FROM Common.Period
		WHERE ID = @PERIOD

		UPDATE a
		SET COEF = @COEF,
			WEIGHT = @WEIGHT,
			RND = @RND
		FROM
			dbo.DistrTypeCoef a
			INNER JOIN Common.Period b ON a.ID_MONTH = b.ID
		WHERE a.ID_NET = @NET
			AND (b.ID = @PERIOD OR b.START > @PR_DATE AND @NEXT = 1)

		INSERT INTO dbo.DistrTypeCoef(ID_NET, ID_MONTH, COEF, WEIGHT, RND)
			SELECT @NET, ID, @COEF, @WEIGHT, @RND
			FROM Common.Period a
			WHERE (a.ID = @PERIOD OR a.START > @PR_DATE AND @NEXT = 1)
				AND TYPE = 2
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DistrTypeCoef z
						WHERE z.ID_NET = @NET
							AND z.ID_MONTH = a.ID
					)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISTR_TYPE_COEF_SAVE] TO rl_distr_type_u;
GO
