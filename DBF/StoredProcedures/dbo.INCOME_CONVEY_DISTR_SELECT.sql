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
CREATE PROCEDURE [dbo].[INCOME_CONVEY_DISTR_SELECT]
	@incomeid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT o_O.DIS_ID, o_O.DIS_STR, DSS_REPORT, DSS_NAME
	FROM
		(
			SELECT DIS_ID, DIS_STR
			FROM dbo.ClientDistrView
			WHERE --DSS_REPORT = 1 
				--AND 
				CD_ID_CLIENT = 
					(
						SELECT IN_ID_CLIENT
						FROM dbo.IncomeTable 
						WHERE IN_ID = @incomeid
					)
			UNION 

			SELECT a.DIS_ID, a.DIS_STR
			FROM 
				dbo.DistrView a INNER JOIN
				dbo.DistrView b ON a.DIS_NUM = b.DIS_NUM
							AND a.DIS_COMP_NUM = b.DIS_COMP_NUM
							AND a.HST_ID = b.HST_ID INNER JOIN
				dbo.ClientDistrView c ON c.DIS_ID = b.DIS_ID
			WHERE CD_ID_CLIENT = 
					(
						SELECT IN_ID_CLIENT
						FROM dbo.IncomeTable 
						WHERE IN_ID = @incomeid
					)		
			UNION 

			SELECT DIS_ID, DIS_STR
			FROM dbo.ActDistrView
			WHERE --DSS_REPORT = 1 
			--AND 
				ACT_ID_CLIENT = 
				(
					SELECT IN_ID_CLIENT
					FROM dbo.IncomeTable 
					WHERE IN_ID = @incomeid
				)
		) AS o_O LEFT OUTER JOIN
		dbo.ClientDistrView a ON a.CD_ID_DISTR = o_O.DIS_ID
	ORDER BY DSS_REPORT DESC, DIS_STR
END