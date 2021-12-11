USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SYSTEM_WEIGHT_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SYSTEM_WEIGHT_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SYSTEM_WEIGHT_SAVE]
	@SYSTEM	INT,
	@PERIOD	UNIQUEIDENTIFIER,
	@WEIGHT	DECIMAL(8, 4),
	@WEIGHT2 DECIMAL(8, 4),
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
		SET WEIGHT = @WEIGHT,
			WEIGHT2 = @WEIGHT2
		FROM
			dbo.SystemWeight a
			INNER JOIN Common.Period b ON a.ID_PERIOD = b.ID
		WHERE ID_SYSTEM = @SYSTEM
			AND (ID_PERIOD = @PERIOD OR START > @PR_DATE AND @NEXT = 1)

		INSERT INTO dbo.SystemWeight(ID_SYSTEM, ID_PERIOD, WEIGHT, WEIGHT2)
			SELECT @SYSTEM, ID, @WEIGHT, @WEIGHT2
			FROM Common.Period a
			WHERE (a.ID = @PERIOD OR a.START > @PR_DATE AND @NEXT = 1)
				AND TYPE = 2
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.SystemWeight b
						WHERE ID_SYSTEM = @SYSTEM AND b.ID_PERIOD = a.ID
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
GRANT EXECUTE ON [dbo].[SYSTEM_WEIGHT_SAVE] TO rl_system_u;
GO
