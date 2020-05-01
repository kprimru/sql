USE [DBF]
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

ALTER PROCEDURE [dbo].[BILL_CREATE_CHECK]
	@clientid INT,
	@periodid SMALLINT,
	@soid SMALLINT
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

		DECLARE @res INT
		DECLARE @txt VARCHAR(MAX)

		SET @res = 0
		SET @txt = ''

		IF NOT EXISTS
			(
				SELECT *
				FROM dbo.PriceSystemTable
				WHERE PS_ID_PERIOD = @periodid
			)
		BEGIN
			SET @res = 1
			SELECT @txt = @txt + 'Отсутствует прейскурант за ' + DATENAME(MONTH, PR_DATE) + ' ' + DATENAME(YEAR, PR_DATE) + ' года' + CHAR(13)
			FROM dbo.PeriodTable
			WHERE PR_ID = @periodid
		END

		IF NOT EXISTS
			(
				SELECT *
				FROM
					dbo.ClientDistrView a INNER JOIN
					dbo.DistrDocumentView b ON a.DIS_ID = b.DIS_ID
				WHERE DOC_PSEDO = 'BILL'
					--AND DD_PRINT = 1
					AND DSS_REPORT = 1
					AND SYS_ID_SO = @soid
					AND CD_ID_CLIENT = ISNULL(@clientid, CD_ID_CLIENT)
			)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Отсутствуют дистрибутивы, для которых возможно формирование счета. Проверьте фин.установки и статус сопровождения дистрибутива'
		END


		SELECT @res AS RES, @txt AS TXT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END


GRANT EXECUTE ON [dbo].[BILL_CREATE_CHECK] TO rl_bill_w;
GO