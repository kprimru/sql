USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PRICE_DEPEND_RECALC]
	@PR_ID	SMALLINT,
	@SYS_ID	SMALLINT,
	@PG_ID	SMALLINT
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

		UPDATE a
		SET PS_PRICE =
				(
					SELECT ROUND(PS_PRICE * PD_COEF, 2)
					FROM
						dbo.PriceSystemTable z
						INNER JOIN dbo.PriceDepend ON PD_ID_SOURCE = PS_ID_TYPE
					WHERE z.PS_ID_PERIOD = @PR_ID
						AND z.PS_ID_SYSTEM = a.PS_ID_SYSTEM
						AND PD_ID_TYPE = c.PT_ID
						AND PS_ID_PGD IS NULL
						AND PD_ID_PERIOD = @PR_ID
				)
		FROM
			dbo.PriceSystemTable a
			INNER JOIN dbo.PriceTypeTable c ON c.PT_ID = a.PS_ID_TYPE
		WHERE PS_ID_PERIOD = @PR_ID
			AND PT_ID_GROUP = @PG_ID
			AND (PS_ID_SYSTEM = @SYS_ID OR @SYS_ID IS NULL)
			AND EXISTS
				(
					SELECT *
					FROM dbo.PriceDepend b
					WHERE PD_ID_TYPE = PS_ID_TYPE
						AND PD_ID_PERIOD = @PR_ID
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
