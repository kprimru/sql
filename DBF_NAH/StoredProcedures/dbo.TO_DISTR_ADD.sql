USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[TO_DISTR_ADD]
	@toid INT,
	@disid VARCHAR(500)
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#distr') IS NOT NULL
		DROP TABLE #distr

	CREATE TABLE #distr
		(
			DIS_ID INT
		)

	IF @disid IS NOT NULL
		BEGIN
			--парсить строчку и выбирать нужные значения
			INSERT INTO #distr
				SELECT DISTINCT * FROM dbo.GET_TABLE_FROM_LIST(@disid, ',')
		END

	INSERT INTO dbo.TODistrTable(
								TD_ID_TO, TD_ID_DISTR
							)
		SELECT @toid, DIS_ID FROM #distr

	IF OBJECT_ID('tempdb..#distr') IS NOT NULL
		DROP TABLE #distr
END
GO
GRANT EXECUTE ON [dbo].[TO_DISTR_ADD] TO rl_client_w;
GRANT EXECUTE ON [dbo].[TO_DISTR_ADD] TO rl_to_distr_w;
GO