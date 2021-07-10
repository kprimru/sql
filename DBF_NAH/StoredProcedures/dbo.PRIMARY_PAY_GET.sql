USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей
Дата создания: 02.02.2009
Описание:	  Выбрать данные о фин. установке
*/

ALTER PROCEDURE [dbo].[PRIMARY_PAY_GET]
	@ppid INT
AS
BEGIN
	SET NOCOUNT ON

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
			DIS_ID, DIS_STR, PRP_DATE, PRP_PRICE,
			PRP_TAX_PRICE, PRP_TOTAL_PRICE, PRP_DOC,
			PRP_COMMENT, ORG_ID, ORG_PSEDO
				--, TX_ID, TX_PERCENT, TX_NAME, TX_CAPTION
		FROM
			dbo.PrimaryPayTable INNER JOIN
			dbo.DistrView WITH(NOEXPAND) ON PRP_ID_DISTR = DIS_ID LEFT OUTER JOIN
			dbo.OrganizationTable ON ORG_ID = PRP_ID_ORG
		WHERE PRP_ID = @ppid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PRIMARY_PAY_GET] TO rl_primary_pay_r;
GO