USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Tender].[PLACEMENT_FILTER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Tender].[PLACEMENT_FILTER]  AS SELECT 1')
GO
ALTER PROCEDURE [Tender].[PLACEMENT_FILTER]
	@CLIENT				NVARCHAR(50) = NULL,
	@DATE_S				DATETIME = NULL,
	@DATE_F				DATETIME = NULL,
	@CLAIM_DATE_S		DATETIME = NULL,
	@CLAIM_DATE_F		DATETIME = NULL,
	@GK_DATE_S			DATETIME = NULL,
	@GK_DATE_F			DATETIME = NULL,
	@INVOICE_NUM		NVARCHAR(50) = NULL,
	@INVOICE_DATE_S		DATETIME = NULL,
	@INVOICE_DATE_F		DATETIME = NULL
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

		IF LTRIM(RTRIM(@CLIENT)) = ''
			SET @CLIENT = NULL
		IF LTRIM(RTRIM(@INVOICE_NUM)) = ''
			SET @INVOICE_NUM = NULL

		SELECT
			t.CLIENT, p.DATE, CONVERT(NVARCHAR, p.CLAIM_START, 4) + ' - ' + CONVERT(NVARCHAR, p.CLAIM_FINISH, 4) AS 'CLAIM_DATE',
			p.GK_DATE, p.INVOICE_NUM, p.ID_TENDER, t.ID_CLIENT, p.INVOICE_DATE, p.COLOR_IGN
		FROM
			Tender.Tender t
			LEFT OUTER JOIN Tender.Placement p ON t.ID = p.ID_TENDER
		WHERE
			(t.CLIENT LIKE '%'+@CLIENT+'%' OR @CLIENT IS NULL)
			AND (p.INVOICE_NUM LIKE '%'+@INVOICE_NUM+'%' OR @INVOICE_NUM IS NULL)
			AND
				(
					(p.DATE > @DATE_S AND p.DATE < @DATE_F)
					OR
					(@DATE_S IS NULL AND p.DATE < @DATE_F)
					OR
					(p.DATE > @DATE_S AND @DATE_F IS NULL)
					OR
					(@DATE_S IS NULL AND @DATE_F IS NULL)
				)
			AND
			(
				(
					@CLAIM_DATE_S < @CLAIM_DATE_F
					OR
					@CLAIM_DATE_S IS NULL
					OR
					@CLAIM_DATE_F IS NULL
				)
				AND
				(
					@CLAIM_DATE_S < p.CLAIM_FINISH
					OR
					@CLAIM_DATE_S IS NULL
				)
				AND
				(
					@CLAIM_DATE_F > p.CLAIM_START
					OR
					@CLAIM_DATE_F IS NULL
				)
			)
			AND
			(
				(p.GK_DATE > @GK_DATE_S AND p.GK_DATE < @GK_DATE_F)
				OR
				(@GK_DATE_S IS NULL AND p.GK_DATE < @GK_DATE_F)
				OR
				(p.GK_DATE > @GK_DATE_S AND @GK_DATE_F IS NULL)
				OR
				(@GK_DATE_S IS NULL AND @GK_DATE_F IS NULL)
			)
			AND
			(
				(p.INVOICE_DATE > @INVOICE_DATE_S AND p.INVOICE_DATE < @INVOICE_DATE_F)
				OR
				(@INVOICE_DATE_S IS NULL AND p.INVOICE_DATE < @INVOICE_DATE_F)
				OR
				(p.INVOICE_DATE > @INVOICE_DATE_S AND @INVOICE_DATE_F IS NULL)
				OR
				(@INVOICE_DATE_S IS NULL AND @INVOICE_DATE_F IS NULL)
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
GRANT EXECUTE ON [Tender].[PLACEMENT_FILTER] TO rl_tender_placement;
GO
