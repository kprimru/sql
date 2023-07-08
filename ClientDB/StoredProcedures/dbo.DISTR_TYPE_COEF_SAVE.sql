USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DISTR_TYPE_COEF_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DISTR_TYPE_COEF_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[DISTR_TYPE_COEF_SAVE]
	@NET		Int,
	@PERIOD		UniqueIdentifier,
	@COEF		Decimal(8, 4),
	@RND		SmallInt,
	@NEXT		Bit
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@Date			SmallDateTime;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT @Date = [START]
		FROM [Common].[Period]
		WHERE [ID] = @PERIOD;

		UPDATE [dbo].[DistrTypeCoef]
		SET [Coef]	= @COEF,
			[RND]	= @RND
		WHERE [ID_NET] = @NET
			AND
			(
				[ID_MONTH] = @PERIOD
				OR
				@NEXT = 1 AND [ID_MONTH] IN
					(
						SELECT P.[ID]
						FROM [Common].[Period] AS P
						WHERE P.[TYPE] = 2
							AND P.[START] > @Date
					)
			);


		INSERT INTO [dbo].[DistrTypeCoef]([ID_NET], [ID_MONTH], [COEF], [RND])
		SELECT @NET, P.[ID], @COEF, @RND
		FROM [Common].[Period] AS P
		WHERE
			(
				P.[ID] = @PERIOD
				OR
				@NEXT = 1 AND P.[START] > @Date
			)
			AND NOT EXISTS
			(
				SELECT *
				FROM [dbo].[DistrTypeCoef] AS C
				WHERE C.[ID_NET]  = @NET
					AND C.[ID_MONTH] = @PERIOD
			);

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
