USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[PERIOD_WEEK_GET_BY_NUMBER]
	@YEAR	UniqueIdentifier,
	@Week	SmallInt
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

		DECLARE @Year_Num SmallInt;
		SELECT @Year_Num = DatePart(yy, START)
		FROM Common.Period
		WHERE ID = @YEAR;

		SELECT ID
		FROM Common.Period
		WHERE TYPE = 1
			AND START = ISNULL(
							(
								SELECT TOP(1) START
								FROM Common.Period
								WHERE TYPE=1 AND DATEPART(yy, START)=DATEPART(yy, GETDATE()) AND DATEPART(ww, START)=@Week
								ORDER BY START DESC
							),
							(
								SELECT TOP(1) START
								FROM Common.Period
								WHERE TYPE=1 AND DATEPART(yy, FINISH)=DATEPART(yy, GETDATE()) AND DATEPART(ww, FINISH)=@Week
								ORDER BY START DESC
							)
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
GRANT EXECUTE ON [Common].[PERIOD_WEEK_GET_BY_NUMBER] TO public;
GO
