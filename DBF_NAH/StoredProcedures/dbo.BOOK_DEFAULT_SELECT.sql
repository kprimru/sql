USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[BOOK_DEFAULT_SELECT]
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

		DECLARE @d DATETIME
		SET @d = DATEADD(M, -3, GETDATE())

		SELECT TOP 1 ORG_ID, ORG_PSEDO,
			/*
			CONVERT(DATETIME,CONVERT(VARCHAR(2),CONVERT(VARCHAR(2),(DATEPART(quarter,@d)-1)*3)+1)+'/1/'+convert(char(4),year(@d)),101) AS BOOK_START,
			dateadd(month,3,convert(datetime,convert(varchar(2),(month(@d)-1)/3*3+1)+'/1/'+convert(char(4),year(@d)),101))-1 AS BOOK_END
			*/
			CONVERT(SMALLDATETIME,
				(
					SELECT GS_VALUE
					FROM dbo.GlobalSettingsTable
					WHERE GS_NAME = 'BOOK_START'
				), 104) AS BOOK_START,
			CONVERT(SMALLDATETIME,
				(
					SELECT GS_VALUE
					FROM dbo.GlobalSettingsTable
					WHERE GS_NAME = 'BOOK_FINISH'
				), 104) AS BOOK_END
		FROM dbo.OrganizationTable
		--WHERE ORG_PSEDO = 'Базис'
		ORDER BY ORG_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[BOOK_DEFAULT_SELECT] TO rl_book_buy_p;
GRANT EXECUTE ON [dbo].[BOOK_DEFAULT_SELECT] TO rl_book_sale_p;
GO
