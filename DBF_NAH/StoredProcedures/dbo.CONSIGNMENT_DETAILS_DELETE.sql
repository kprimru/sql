USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:	17.06.09
Описание:		удалить несколько записей
				из таблицы накладных
*/

ALTER PROCEDURE [dbo].[CONSIGNMENT_DETAILS_DELETE]
	@rowlist VARCHAR(200)
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#dbf_consrow') IS NOT NULL
		DROP TABLE #dbf_consrow

	CREATE TABLE #dbf_consrow
		(
		ROW_ID INT NOT NULL
		)

	IF @rowlist IS NOT NULL
		BEGIN
		--парсить строчку и выбирать нужные значения
		INSERT INTO #dbf_consrow
			SELECT * FROM dbo.GET_TABLE_FROM_LIST(@rowlist, ',')
		END


	DELETE
	FROM
		dbo.ConsignmentDetailTable
	WHERE CSD_ID IN (SELECT ROW_ID FROM #dbf_consrow)

	IF OBJECT_ID('tempdb..#dbf_consrow') IS NOT NULL
		DROP TABLE #dbf_consrow

END



GO
GRANT EXECUTE ON [dbo].[CONSIGNMENT_DETAILS_DELETE] TO rl_consignment_d;
GO